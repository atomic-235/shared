import type { Plugin } from "@opencode-ai/plugin"

/**
 * rl-decision objective gate — deterministic enforcement.
 *
 * The failure this exists to prevent is model-independent: a weak model (or a
 * strong one, less visibly) writes the *decision* or the user's *question* as
 * the objective — e.g. "decide whether to walk or drive" — and a tautology as
 * success — e.g. "a clear, actionable recommendation". Then it asks the human to
 * confirm, and the human's correction gets misread as consent.
 *
 * Prompting cannot fix this reliably. This plugin blocks the gate question
 * before it reaches the user whenever the objective reads like a decision and/or
 * the success reads like the deliverable, forcing the orchestrator to rewrite it.
 * It runs for every model.
 */

// An objective must be the user's GOAL, not the decision or the question.
const DECISION =
  /(\bdecide\b|\bwhether\b|\bshould (i|we|you|they)\b|\bwhich (one|option)\b|\bwalk or drive\b|\b[a-z]+ or [a-z]+\?)/i

// A success criterion must be a world state, not the deliverable.
const DELIVERABLE =
  /(\brecommendation\b|\brecommend\b|\banswer\b|\badvice\b|\bplan\b|\bactionable\b|\bclear\b|\bresponse\b|\bexplanation\b|\breasoning you can\b)/i

function gateText(args: any): string {
  const questions = args?.questions ?? []
  return questions
    .map((q: any) => {
      const opts = (q.options ?? [])
        .map((o: any) => `${o.label ?? ""} ${o.description ?? ""}`)
        .join("\n")
      return `${q.header ?? ""}\n${q.question ?? ""}\n${opts}`
    })
    .join("\n")
}

function isGate(text: string): boolean {
  return /\bobjective\b/i.test(text) && /\bsuccess\b/i.test(text)
}

export const RlDecisionGate: Plugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "question") return

      const text = gateText(output.args)
      if (!isGate(text)) return

      const problems: string[] = []
      if (DECISION.test(text)) {
        problems.push(
          "the objective reads like the decision or the user's question " +
            "('decide'/'whether'/'should …'/'X or Y?'). The objective must be the " +
            "user's GOAL — what they want to be true when this is done.",
        )
      }
      if (DELIVERABLE.test(text)) {
        problems.push(
          "the success criterion reads like the deliverable " +
            "('recommendation'/'answer'/'plan'/'actionable'). Success must be a " +
            "world state — what must be true when this is done — never the output itself.",
        )
      }

      if (problems.length > 0) {
        throw new Error(
          "rl-decision objective gate blocked (rewrite and re-ask):\n- " +
            problems.join("\n- ") +
            "\nFind the user's intent ('I want to …' / 'I need to …') — that is the goal. " +
            "The question they ask is only how to reach it.",
        )
      }
    },
  }
}
