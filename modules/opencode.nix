{ config, lib, ... }:

let
  opencodeDir = ../opencode;
  cfg = config.opencode.variants or {};

  mkAgentVariant = { skill, name, model, description }:
    let
      content = ''
        ---
        description: ${description}
        mode: subagent
        model: ${model}
        permission:
          edit: deny
          bash: deny
          read: allow
          webfetch: allow
          ai_venice_web_search: allow
          skill: allow
        ---

        Load and follow the `${skill}` skill. Apply the framework to the user's request. Return structured findings with sources.
      '';
    in
    {
      name = "opencode/agents/${name}.md";
      value = {
        source = builtins.toFile "${name}.md" content;
      };
    };

  variants = lib.flatten (lib.mapAttrsToList
    (suffix: model:
      map
        (entry: mkAgentVariant {
          skill = entry.skill;
          name = "${entry.agent}-${suffix}";
          inherit model;
          description = "${entry.desc} (${suffix}).";
        })
        [
          { agent = "research-red-team"; skill = "red-team"; desc = "Red team"; }
          { agent = "research-ach"; skill = "ach"; desc = "ACH"; }
          { agent = "research-inversion"; skill = "inversion"; desc = "Inversion"; }
          { agent = "research-premortem"; skill = "premortem"; desc = "Premortem"; }
          { agent = "research-cynefin"; skill = "cynefin"; desc = "Cynefin"; }
          { agent = "research-wrap"; skill = "wrap"; desc = "WRAP"; }
          { agent = "research-ooda"; skill = "ooda-loop"; desc = "OODA"; }
          { agent = "research-first-principles"; skill = "first-principles"; desc = "First principles"; }
          { agent = "research-systems-thinking"; skill = "systems-thinking"; desc = "Systems thinking"; }
          { agent = "research-toc"; skill = "theory-of-constraints"; desc = "Theory of constraints"; }
          { agent = "research-triz"; skill = "triz"; desc = "TRIZ"; }
          { agent = "research-investigation"; skill = "structured-investigation"; desc = "Investigation"; }
          { agent = "research-hilp"; skill = "high-impact-low-probability"; desc = "HILP"; }
          { agent = "research-link-analysis"; skill = "link-analysis"; desc = "Link analysis"; }
          { agent = "research-alternative-futures"; skill = "alternative-futures"; desc = "Alternative futures"; }
          { agent = "research-negotiate"; skill = "negotiate"; desc = "Negotiate"; }
          { agent = "research-scientific"; skill = "scientific-method"; desc = "Scientific method"; }
          { agent = "research-decision-record"; skill = "decision-record"; desc = "Decision record"; }
          { agent = "research-ppdac"; skill = "research-ppdac"; desc = "PPDAC"; }
          { agent = "research-polya"; skill = "research-polya"; desc = "Polya"; }
          { agent = "research-io-uncertainty-quadrant"; skill = "io-uncertainty-quadrant"; desc = "IO uncertainty"; }
          { agent = "research-coverage-audit"; skill = "coverage-audit"; desc = "Coverage audit"; }
          { agent = "research-design"; skill = "software-design"; desc = "Software design"; }
          { agent = "research-microservices"; skill = "microservices"; desc = "Microservices"; }
          { agent = "research-testing"; skill = "ai-testing"; desc = "AI testing"; }
          { agent = "research-debug"; skill = "debugging"; desc = "Debug"; }
        ])
    cfg);
in
{
  options.opencode.variants = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Model variants for research agents. Key = suffix, value = model id. e.g. { fast = \"provider/model-id\"; }";
  };

  config.xdg.configFile = builtins.listToAttrs (
    builtins.concatLists [
      # tui.json (theme + keybindings)
      [{
        name = "opencode/tui.json";
        value = { source = "${opencodeDir}/tui.json"; };
      }]

      # commands/*.md
      (map
        (name: {
          name = "opencode/commands/${name}";
          value = { source = "${opencodeDir}/commands/${name}"; };
        })
        (builtins.attrNames (builtins.readDir "${opencodeDir}/commands")))

      # agents/research-*.md (base agents from filesystem)
      (map
        (name: {
          name = "opencode/agents/${name}";
          value = { source = "${opencodeDir}/agents/${name}"; };
        })
        (builtins.attrNames (builtins.readDir "${opencodeDir}/agents")))

      # agents generated from model variants (nix-generated, no file on disk)
      variants

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
