{ ... }:

let
  opencodeDir = ../opencode;
in
{
  # Auto-link all generic opencode files (commands, agents, skills)
  # Personal files (opencode.json, AGENTS.md, assistant.md, caveman.md,
  # telegram/sops/coinglass/venice skills) are managed by dotfiles separately
  xdg.configFile = builtins.listToAttrs (
    builtins.concatLists [
      # commands/*.md
      (map
        (name: {
          name = "opencode/commands/${name}";
          value = { source = "${opencodeDir}/commands/${name}"; };
        })
        (builtins.attrNames (builtins.readDir "${opencodeDir}/commands")))

      # agents/research-*.md
      (map
        (name: {
          name = "opencode/agents/${name}";
          value = { source = "${opencodeDir}/agents/${name}"; };
        })
        (builtins.attrNames (builtins.readDir "${opencodeDir}/agents")))

      # skills/<name>/ (each skill is a directory)
      (map
        (skillName: {
          name = "opencode/skills/${skillName}";
          value = {
            source = "${opencodeDir}/skills/${skillName}";
            recursive = true;
          };
        })
        (builtins.attrNames (builtins.readDir "${opencodeDir}/skills")))
    ]
  );
}
