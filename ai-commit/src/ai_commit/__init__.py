"""AI-powered conventional commit message generator using pydantic-ai."""

import os
import subprocess
import sys

from pydantic_ai import Agent, RunContext
from pydantic_ai.models.openai import OpenAIChatModel
from pydantic_ai.providers.openai import OpenAIProvider


def _run_git(*args: str) -> str:
    """Run a git command and return stdout."""
    result = subprocess.run(
        ["git", *args],
        capture_output=True,
        text=True,
        timeout=10,
    )
    return result.stdout


def create_agent(model: str) -> Agent[str, str]:
    """Create the commit message agent with tools for project exploration."""
    provider = OpenAIProvider(
        base_url=os.environ["OPENAI_BASE_URL"],
        api_key=os.environ["OPENAI_API_KEY"],
    )
    llm = OpenAIChatModel(model, provider=provider)

    agent = Agent(
        llm,
        output_type=str,
        instructions=(
            "You are a commit message generator following Conventional Commits format: "
            "type(scope): description\n\n"
            "Rules:\n"
            "- Use the appropriate type: feat, fix, refactor, chore, docs, test, style, perf, ci, build\n"
            "- Scope is optional but encouraged when changes are focused\n"
            "- Description is lowercase, imperative mood, no trailing period\n"
            "- Keep it concise (ideally under 72 chars for the subject line)\n"
            "- Match the style of recent commits in this repo\n"
            "- Return ONLY the commit message, no explanation, no markdown fences\n"
        ),
    )

    @agent.tool_plain
    def recent_commits(count: int = 10) -> str:
        """Get recent commit messages to match repo's commit style."""
        return _run_git("log", f"--oneline=-{count}")

    @agent.tool_plain
    def list_changed_files() -> str:
        """List files changed in the staged diff."""
        return _run_git("diff", "--cached", "--name-only")

    @agent.tool_plain
    def list_project_files() -> str:
        """List tracked files in the project for context."""
        return _run_git("ls-files")

    @agent.tool_plain
    def read_file(path: str) -> str:
        """Read a project file for additional context."""
        try:
            with open(path, encoding="utf-8", errors="replace") as f:
                return f.read()[:5000]  # cap at 5k chars
        except (OSError, FileNotFoundError):
            return f"Error: cannot read {path}"

    return agent


def main() -> None:
    # Source AI model config if present (XDG-compliant, works in non-interactive shells)
    config_path = os.path.expanduser(
        os.environ.get("XDG_CONFIG_HOME", "~/.config") + "/ai/models"
    )
    if os.path.isfile(config_path):
        with open(config_path) as f:
            for line in f:
                line = line.strip()
                if "=" in line and not line.startswith("#"):
                    key, _, value = line.partition("=")
                    value = value.strip().strip('"').strip("'")
                    os.environ.setdefault(key.strip(), value)

    model = os.environ.get("AI_MODEL_FAST")
    if not model:
        print("AI_MODEL_FAST not set", file=sys.stderr)
        sys.exit(1)

    # Strip provider prefix (e.g. "venice/mercury-2" → "mercury-2")
    # pydantic-ai OpenAIChatModel takes bare model name, provider set via OpenAIProvider
    if "/" in model:
        model = model.split("/", 1)[1]

    # Get staged diff
    diff = _run_git("diff", "--cached")
    if not diff.strip():
        print("No staged changes")
        sys.exit(1)

    # Smart proxy detection: if proxy is running on port 12334, route through it
    try:
        result = subprocess.run(
            ["ss", "-tlnH", "sport = :12334"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.stdout.strip():
            os.environ["http_proxy"] = "http://127.0.0.1:12334"
            os.environ["https_proxy"] = "http://127.0.0.1:12334"
    except (OSError, subprocess.TimeoutExpired):
        pass

    agent = create_agent(model)

    prompt = f"Generate a conventional commit message for this staged diff:\n\n{diff}"

    try:
        result = agent.run_sync(prompt)
        msg = result.output.strip()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    # Check for --commit flag
    if "--commit" in sys.argv or "-c" in sys.argv:
        print(msg)
        subprocess.run(["git", "commit", "-m", msg], check=True)
    else:
        print(msg)


if __name__ == "__main__":
    main()
