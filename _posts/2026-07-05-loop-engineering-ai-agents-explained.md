---
title: "What Is Loop Engineering? A Plain-English Guide to Prompt, Context, Harness, and Loop Engineering"
description: "A practical walkthrough of the AI engineering stack, from prompt engineering to the brand-new idea of loop engineering, using a small online store instead of the usual demo examples."
author: s-gryt
date: 2026-07-05 12:00:00 CDT
categories:
  - AI Agents
  - AI Development
  - Developer Productivity
  - Automation
  - Software Engineering
tags:
  - Loop Engineering
  - Harness Engineering
  - Context Engineering
  - Prompt Engineering
  - Claude Code
  - AI Agents
  - Agent Automation
  - Sub-agents
  - Git Worktree
  - AI Coding
  - Developer Tools
  - Vibe Coding
image:
  path: /assets/img/posts/2026-07-05-loop-engineering-ai-agents-explained/cover.png
  alt: "A self-running loop for a small online store: automations, a harness, worktrees, skills, sub-agents, and state working together"
---

## From prompt to loop: four layers, one job

Prompt engineering, context engineering, harness engineering, and loop engineering arrived a few years apart, each building on the one before it. The easiest way to see what each one adds is to run one small job through all four and watch where each stops being enough.

So take a small online store. Every morning, someone has to check whether the supplier's prices moved overnight, whether anything sold out, and whether a customer flagged a broken checkout step in a support ticket. That is the job. Walking it through prompt, context, harness, and loop engineering in order shows what each layer does in practice.

## Prompt engineering: writing the one good instruction

Prompt engineering is the oldest and simplest layer. You write an instruction, the model responds, done. If you tell an agent "you are a helpful customer support assistant, be polite and concise," you are prompt engineering. The model has no memory beyond the conversation and no way to go get information it does not already have. It answers from what it already knows plus whatever you typed.

This is fine for a huge number of tasks. If someone asks a general knowledge question, there is nothing to fetch and nothing to plan. The instruction is the whole job.

![Prompt engineering: an instruction goes in, an agent answers from what it already knows, with no files, tools, or memory involved](/assets/img/posts/2026-07-05-loop-engineering-ai-agents-explained/prompt-engineering-example.png){: width="1024" height="256" .w-75 .normal}
_One instruction, one answer. Nothing gets fetched, so there is nothing that can go stale._

## Context engineering: letting the agent go get its own information

The store example breaks prompt engineering immediately. If you ask an agent "did the supplier change any prices overnight," it cannot answer from memory. It needs to open the supplier's feed, read it, and compare it to what you had before.

That is context engineering: giving the agent the ability to fill its own context window during the conversation, by reading files, calling tools, or searching the web, rather than relying only on what you typed. Simon Willison, who did as much as anyone to popularize the term in 2025, framed it as deliberately assembling the system prompt, retrieved documents, and tool outputs into one coherent package for the model to work from ([simonwillison.net, June 2025](https://simonwillison.net/2025/jun/27/context-engineering/)). Andrej Karpathy made a similar point around the same time: in a real application, the skill that matters is curating what goes into the context window, not polishing a single sentence of instruction.

![Three sources, a supplier price feed, stock levels, and a support ticket queue, feeding into a context window that produces the agent's answer](/assets/img/posts/2026-07-05-loop-engineering-ai-agents-explained/context-sources.png){: width="940" height="437" .w-75 .normal}
_Reading files, calling tools, checking a feed. The context window fills with whatever the agent goes and gets, not just what you typed._

Once an agent can pull its own context, "check the supplier feed" becomes something it can actually attempt. It reads the feed, reads your current price list, and reports the differences.

### Where context engineering runs out of road

Context engineering has a real limit, and it shows up on anything that takes longer than a few minutes. A context window is finite. A long task pulls in more files, more tool output, and more back-and-forth than the window can hold, so at some point the agent has to summarize its own history to make room. Summarization is lossy. Details that mattered three steps ago quietly disappear, and the agent starts working from an increasingly thin picture of what it already did.

![A context window filling with three steps that each get summarized, with a warning that details from the first step are gone by the third, next to a stack of tasks still waiting](/assets/img/posts/2026-07-05-loop-engineering-ai-agents-explained/context-decay.png){: width="695" height="455" .w-75 .normal}
_Every round of summarizing buys room, and loses a little of what came before it._

Checking a price feed fits comfortably in one context window. Rebuilding your entire product catalog page, with an image gallery, a variant picker, live reviews, and a recommendations panel, does not. That is the gap the next layer fills.

![Four-stage stack: prompt engineering, context engineering, harness engineering, and loop engineering, each with increasing scope and autonomy](/assets/img/posts/2026-07-05-loop-engineering-ai-agents-explained/engineering-stack.png){: width="804" height="580" .w-75 .normal}
_The stack so far. Each layer keeps the one below it and adds a way to handle more scope without losing the plot._

## Harness engineering: a system that remembers the plan for you

Ask an agent to build a product page with the same moving parts as a major marketplace listing, a hero image gallery, size and color variants, a reviews section, related items, and a sticky buy box that follows you down the page. That is not one task. It is dozens of small tasks that depend on each other, and it will not fit in a single pass of context engineering before something gets dropped or contradicted.

Harness engineering is the answer: a system outside the conversation that tracks the task list, checkpoints progress, and retries the parts that fail, so the agent's working memory never has to hold the entire job at once. Mitchell Hashimoto, the HashiCorp co-founder, described the underlying discipline plainly in February 2026: whenever an agent makes a mistake, you build a fix into its environment so that mistake becomes structurally impossible to repeat, summarized as "Agent = Model + Harness" ([mitchellh.com](https://mitchellh.com/writing/my-ai-adoption-journey)). A few weeks later, Thoughtworks' Birgitta Böckeler expanded the idea for coding agents specifically, describing a harness as a combination of guides that steer the agent before it acts and sensors that catch problems after it acts ([martinfowler.com, April 2026](https://martinfowler.com/articles/harness-engineering.html)).

![A prompt and context flowing into a harness that holds a five-item numbered checklist: scaffold the layout, wire up the gallery, add the variant picker logic, populate reviews, test it and fix what broke](/assets/img/posts/2026-07-05-loop-engineering-ai-agents-explained/harness-checklist.png){: width="920" height="472" .w-75 .normal}
_The harness turns one big, fuzzy job into a checklist small enough for each step to fit in its own context window._

In Claude Code, this shows up as the built-in task tracking during a long session, plus features like Agent Skills and subagents that split a big job into pieces with their own focused context (see the [Claude Code documentation](https://code.claude.com/docs/en/agent-sdk/overview)). The product-page build becomes a checklist: scaffold the layout, wire up the gallery, add the variant logic, populate reviews, test it, fix what broke. None of those steps needs the full history of the others in its own context window. The harness is what remembers the plan.

## So what is loop engineering

Everything above still needs a human to start it. You type "check the supplier feed" or "build the product page." Loop engineering is what people are starting to call the layer where the agent's own schedule replaces that first prompt.

Addy Osmani put it directly in a post published in June 2026: "loop engineering is replacing yourself as the person who prompts the agent. You design the system that does it instead" ([addyosmani.com/blog/loop-engineering](https://addyosmani.com/blog/loop-engineering/)). Worth being precise about what this is and is not: it is not a new model capability, and it is not specific to one vendor. Osmani's own post maps the same six pieces to both the Codex app and Claude Code, because the idea is about how you wire existing primitives together, not a new kind of intelligence.

![Two scenes side by side: a human sending a prompt into a harness, versus an automation looping back into the same harness on a schedule while a human only checks in occasionally](/assets/img/posts/2026-07-05-loop-engineering-ai-agents-explained/self-guided-vs-human-guided.png){: width="896" height="397" .w-75 .normal}
_The model and the harness stay the same either way. What changes is who starts the run._

### The six pieces that make a loop hold together

![Table of six loop primitives, automations, worktrees, skills, plugins and connectors, sub-agents, and state, with their job in the loop and how each shows up in the Codex app and in Claude Code](/assets/img/posts/2026-07-05-loop-engineering-ai-agents-explained/six-components.png){: width="1270" height="648" .w-75 .normal}
_Six pieces, laid out the way Osmani's own post does it, that decide whether a loop holds together or quietly leaks details every run._

Osmani's post breaks a working loop into six pieces, and each one answers a specific way things go wrong when an agent runs unattended:

- **Automations** run the agent on a schedule instead of waiting for you to type something. Without this, there is no loop, just a very good assistant you still have to remember to open.
- **Worktrees** give each parallel task its own isolated copy of the working files, so two fixes running at the same time cannot overwrite each other. This is the same idea covered in an [earlier post on parallel AI development with Git worktrees](/posts/git-worktree-parallel-ai-development/).
- **Skills** are the rules and conventions written down once, in a file the agent reads every run, instead of re-explained in every conversation.
- **Plugins and connectors** wire the agent to the actual systems it needs to touch: a supplier's price feed, a support ticket queue, a code repository.
- **Sub-agents** split drafting from checking. One agent proposes a change, a separate one reviews it against the skill file before anything ships.
- **State** is a plain file that tracks what already ran, what passed, and what is still open, so tomorrow's run does not repeat today's work or forget an unfinished fix.

## Putting a loop to work on a small online store

Back to the store. Instead of you opening three tabs every morning, imagine the same three checks wired into a loop:

An **automation** fires every hour. It kicks off a **harness** with a short checklist: check the supplier's price feed, check stock levels, check any new support tickets tagged as bugs. A **plugin** gives it read access to the supplier feed and the ticket queue. If the price feed shows a change, a **sub-agent** drafts the update to the product page. Before that change goes live, a second sub-agent checks the draft against a **skill** file that encodes your actual pricing rules and the tone your listings use, so a bad feed entry or an over-eager discount does not slip through unchecked. The price fix and any stock-level fix run in separate **worktrees**, so a bug fix in progress does not collide with a price update in progress. A **state** file, something as plain as a markdown checklist, records what ran, what passed review, and what is still waiting on a human to glance at it.

![Diagram of the six components wired together into a self-guided loop for a small online store, checking a price feed, stock levels, and bug reports every hour](/assets/img/posts/2026-07-05-loop-engineering-ai-agents-explained/loop-architecture.png){: width="907" height="595" .w-75 .normal}
_The same six pieces, wired to one small store's actual morning routine instead of a generic diagram._

Nobody had to sit down and type "please check the price feed" at 9am. The loop already ran four times before the store owner opened their laptop, and the one thing that genuinely needed a person, an unusual discount request from the price feed, is sitting in the state file waiting for a decision instead of quietly going live.

## Is this actually useful, or just automation for its own sake

Worth noting where this stands in mid-2026: loop engineering is a very new term, and there is a fair case for skepticism. One concern is that "let the agent prompt itself" can end up meaning the agent runs unattended on a schedule without producing correspondingly more value, particularly without the guardrails described above. A loop with automations but no skill file, no review sub-agent, and no state tracking is not a safer version of the store example. It carries the same failure mode as before, just unattended and unsupervised.

The counterpoint is that the six pieces exist specifically to address that concern: worktrees and sub-agent review are what keep an unattended loop from doing damage that a human would have caught. Whether that is enough in practice is still mostly anecdotal as of this writing. There is no large body of measured production data yet, the way there now is for something like parallel worktree development. The store example above is best read as a design pattern worth trying on a low-stakes task, rather than as a proven return on investment.

## Which layer do you actually need

Most day-to-day tasks never need to go past context engineering, and that is fine. A quick decision path:

- **One-off question, nothing to fetch:** prompt engineering is enough.
- **The answer depends on current information, a file, or a tool call, but it fits in one sitting:** context engineering.
- **The job has enough steps that the agent would lose track of earlier ones, but a person is still driving it:** harness engineering.
- **The same check needs to happen repeatedly, unattended, on things that change on their own schedule, like a price feed or a bug queue:** that is the case loop engineering is actually for.

Reaching for the last one by default, for a task you only run once, adds moving parts (schedules, worktrees, a state file) that a single prompt would have handled in thirty seconds.

## Closing thought

None of these four layers replaces the one before it. A loop still needs a harness to manage any task inside it, the harness still needs context engineering to gather what each step requires, and context engineering still starts with a clearly written prompt. The stack is additive, not a ladder you climb and leave behind. The store's morning routine did not get replaced by magic. It got broken into six specific, checkable pieces, and that is the whole idea.

## References and further reading

- [Simon Willison: Context engineering](https://simonwillison.net/2025/jun/27/context-engineering/)
- [Mitchell Hashimoto: My AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey)
- [Birgitta Böckeler / Martin Fowler: Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html)
- [Addy Osmani: Loop Engineering](https://addyosmani.com/blog/loop-engineering/)
- [Claude Code documentation: Agent SDK overview](https://code.claude.com/docs/en/agent-sdk/overview)
- [Earlier post: Parallel AI Development with Git Worktrees](/posts/git-worktree-parallel-ai-development/)
