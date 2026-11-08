// ai-commit generates a Conventional Commits message for staged changes using
// the Venice-backed opencode CLI.
//
// The model comes from AI_MODEL_FAST in $XDG_CONFIG_HOME/ai/models (written by
// home-manager from nix/home/models.nix). If that is absent opencode's default
// model is used.
package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/spf13/pflag"
)

const prompt = `Generate a Conventional Commits message for this diff.
Template:
<type>(<scope>): <summary>
<blank line>
<body explaining why the change was made, wrapped at 72 columns>

Rules: type is one of feat, fix, refactor, perf, docs, test, build, ci, chore, style. Scope is optional. Summary is imperative mood, lower-case, no trailing period, at most 72 characters. Add a body only when the summary alone does not explain the change, and wrap it at 72 columns. Output ONLY the commit message, with no code fences.`

func main() {
	var (
		wantCommit = pflag.BoolP("commit", "c", false, "commit the generated message instead of printing it")
		wantHelp   = pflag.BoolP("help", "h", false, "show this help")
	)
	pflag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: ai-commit [flags]\n\n")
		fmt.Fprintf(os.Stderr, "Generate a Conventional Commits message for staged changes.\n\nFlags:\n")
		pflag.PrintDefaults()
	}
	pflag.Parse()

	if *wantHelp {
		pflag.Usage()
		return
	}
	if pflag.NArg() > 0 {
		fmt.Fprintf(os.Stderr, "ai-commit: unexpected argument %q\n", pflag.Arg(0))
		pflag.Usage()
		os.Exit(2)
	}

	diff, err := exec.Command("git", "diff", "--cached").Output()
	if err != nil {
		fmt.Fprintln(os.Stderr, "ai-commit: git diff --cached failed")
		os.Exit(1)
	}
	if len(bytes.TrimSpace(diff)) == 0 {
		style("1", "No staged changes")
		os.Exit(1)
	}

	diffFile, err := os.CreateTemp("", "ai-commit-diff-*")
	if err != nil {
		fmt.Fprintf(os.Stderr, "ai-commit: %v\n", err)
		os.Exit(1)
	}
	defer os.Remove(diffFile.Name())
	if _, err := diffFile.Write(diff); err != nil {
		fmt.Fprintf(os.Stderr, "ai-commit: %v\n", err)
		os.Exit(1)
	}
	diffFile.Close()

	msg, err := generate(diffFile.Name())
	if err != nil {
		fmt.Fprintf(os.Stderr, "ai-commit: %v\n", err)
		os.Exit(1)
	}
	if msg == "" {
		fmt.Fprintln(os.Stderr, "ai-commit: empty commit message")
		os.Exit(1)
	}

	if !*wantCommit {
		fmt.Println(msg)
		return
	}

	style("2", msg)
	commit := exec.Command("git", "commit", "-m", msg)
	commit.Stdin, commit.Stdout, commit.Stderr = os.Stdin, os.Stdout, os.Stderr
	if err := commit.Run(); err != nil {
		os.Exit(1)
	}
}

// generate runs opencode over the staged diff and returns the cleaned message.
func generate(diffPath string) (string, error) {
	args := []string{"ai", "opencode", "run", "--auto"}
	if model := fastModel(); model != "" {
		args = append(args, "-m", model)
	}
	args = append(args, "--format", "json", prompt, "-f", diffPath)

	cmd := exec.Command("with-secrets", args...)
	cmd.Env = proxyEnv(os.Environ())

	var stdout bytes.Buffer
	cmd.Stdout = &stdout

	stop := spinner()
	err := cmd.Run()
	stop()

	msg, apiErr := parseEvents(stdout.String())
	if apiErr != "" {
		return "", fmt.Errorf("%s", apiErr)
	}
	if err != nil && msg == "" {
		return "", fmt.Errorf("opencode run failed: %w", err)
	}
	return msg, nil
}

type event struct {
	Type string `json:"type"`
	Part struct {
		Text string `json:"text"`
	} `json:"part"`
	Error struct {
		Message string `json:"message"`
	} `json:"error"`
}

// parseEvents collects the text parts of the run and surfaces API errors.
func parseEvents(raw string) (string, string) {
	var text strings.Builder
	apiErr := ""

	scanner := bufio.NewScanner(strings.NewReader(raw))
	scanner.Buffer(make([]byte, 0, 64*1024), 16*1024*1024)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		var ev event
		if err := json.Unmarshal([]byte(line), &ev); err != nil {
			continue
		}
		switch ev.Type {
		case "text":
			text.WriteString(ev.Part.Text)
		case "error":
			apiErr = ev.Error.Message
		}
	}
	return trimMessage(text.String()), apiErr
}

// trimMessage strips trailing whitespace, code fences and surrounding blank
// lines while keeping the blank line that separates summary and body.
func trimMessage(raw string) string {
	var lines []string
	for _, line := range strings.Split(raw, "\n") {
		line = strings.TrimRight(line, " \t\r")
		if strings.HasPrefix(strings.TrimSpace(line), "```") {
			continue
		}
		lines = append(lines, line)
	}

	start, end := 0, len(lines)
	for start < end && strings.TrimSpace(lines[start]) == "" {
		start++
	}
	for end > start && strings.TrimSpace(lines[end-1]) == "" {
		end--
	}
	return strings.Join(lines[start:end], "\n")
}

// fastModel reads AI_MODEL_FAST from the generated ai/models file.
func fastModel() string {
	dir := os.Getenv("XDG_CONFIG_HOME")
	if dir == "" {
		dir = filepath.Join(os.Getenv("HOME"), ".config")
	}

	file, err := os.Open(filepath.Join(dir, "ai", "models"))
	if err != nil {
		return ""
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimPrefix(strings.TrimSpace(scanner.Text()), "export ")
		key, value, ok := strings.Cut(line, "=")
		if !ok || strings.TrimSpace(key) != "AI_MODEL_FAST" {
			continue
		}
		return strings.Trim(strings.TrimSpace(value), `"'`)
	}
	return ""
}

// proxyEnv routes the request through $PROXY_PORT when something listens there.
func proxyEnv(env []string) []string {
	port := os.Getenv("PROXY_PORT")
	if port == "" {
		port = "20172"
	}

	conn, err := net.DialTimeout("tcp", net.JoinHostPort("127.0.0.1", port), 250*time.Millisecond)
	if err != nil {
		return env
	}
	conn.Close()

	proxy := "http://127.0.0.1:" + port
	env = setEnv(env, "http_proxy", proxy)
	env = setEnv(env, "https_proxy", proxy)
	env = setEnv(env, "no_proxy", "127.0.0.1,localhost,::1")
	env = setEnv(env, "NO_PROXY", "127.0.0.1,localhost,::1")
	return env
}

func setEnv(env []string, key, value string) []string {
	out := make([]string, 0, len(env)+1)
	for _, entry := range env {
		if !strings.HasPrefix(entry, key+"=") {
			out = append(out, entry)
		}
	}
	return append(out, key+"="+value)
}

// spinner shows a dot spinner on stderr while the model runs; it is silent when
// stderr is not a terminal (piped output, hm-switch).
func spinner() func() {
	if info, err := os.Stderr.Stat(); err != nil || info.Mode()&os.ModeCharDevice == 0 {
		return func() {}
	}

	done := make(chan struct{})
	var wg sync.WaitGroup
	wg.Add(1)

	go func() {
		defer wg.Done()
		frames := []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}
		ticker := time.NewTicker(100 * time.Millisecond)
		defer ticker.Stop()
		for i := 0; ; i++ {
			select {
			case <-done:
				fmt.Fprint(os.Stderr, "\r\033[K")
				return
			case <-ticker.C:
				fmt.Fprintf(os.Stderr, "\r%s Generating...", frames[i%len(frames)])
			}
		}
	}()

	return func() {
		close(done)
		wg.Wait()
	}
}

// style prints text in a gum style, falling back to plain output without gum.
func style(colour, text string) {
	cmd := exec.Command("gum", "style", "--foreground", colour, text)
	cmd.Stdout, cmd.Stderr = os.Stdout, os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Println(text)
	}
}
