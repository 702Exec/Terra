# Connecting Claude to Godot — Setup Guide

## The short version

There are two layers, and they're worth understanding separately because the first one does most of the work:

**Layer 1 — Claude Code in your project folder.** Godot stores everything as plain text: `.gd` scripts, `.tscn` scenes, `.tres` resources, `project.godot`. Claude Code can read and write all of it directly, with no plugin, no server, no configuration. This is roughly 80% of the value and takes about five minutes to set up.

**Layer 2 — a Godot MCP server.** This adds the part Layer 1 can't do: launching the editor, *running the project*, and capturing console output and runtime errors. That closes the feedback loop — Claude writes code, runs the game, reads the crash, and fixes it without you relaying error messages by hand.

Do Layer 1 first and start building. Add Layer 2 once you're tired of copy-pasting stack traces.

---

## Step 1 — Install the pieces

| | What | Where |
|---|---|---|
| Godot | Current stable 4.x, standard build (not .NET unless you specifically want C#) | godotengine.org |
| Node.js | v18 or newer — required by the MCP server | nodejs.org |
| Claude Code | The CLI | Anthropic's install instructions |

Use standard Godot with GDScript, not the .NET/C# build. GDScript is what the AI handles best, the whole ecosystem of tutorials assumes it, and C# adds a build step and export friction you don't need on a first project.

## Step 2 — Create the project

Open Godot, create a new project, name it `terra`, note the folder path. Make it a git repo immediately:

```bash
cd /path/to/terra
git init
git add -A
git commit -m "Empty Godot project"
```

This matters more than usual when working with an AI agent. You want to be able to throw away a bad hour with `git checkout .` instead of untangling it.

## Step 3 — Point Claude Code at it

```bash
cd /path/to/terra
claude
```

That's the whole of Layer 1. Claude can now read your scenes and scripts, write new ones, and refactor across the project.

## Step 4 — Add the MCP server

The most established option is open source, free, and installs in one line:

```bash
claude mcp add godot -- npx @coding-solo/godot-mcp
```

Restart Claude Code and run `/mcp` — you should see `godot` connected.

This gives Claude tools to launch the editor, run the project, capture console and error output, inspect project structure, and create scenes and nodes.

There are paid alternatives with deeper scene-graph manipulation. Don't start there. The free one covers the run-and-read-errors loop, which is the part that actually changes your day.

## Step 5 — Drop in CLAUDE.md

Put the accompanying `CLAUDE.md` file in your project root. Claude Code reads it automatically at the start of every session, so you don't re-explain the project each time. It's the difference between an assistant that knows Terra and one that knows Godot in general.

Commit it. Update it whenever a convention changes.

---

## Known gotchas

**Turn off script auto-reload while an agent is working.** Godot re-importing scripts mid-edit can interrupt or confuse an agent session. Editor Settings → Text Editor → Behavior.

**Use explicit type annotations in GDScript.** Write `var health: int = 100`, not `var health = 100`. GDScript's dynamic typing means wrong-typed arguments fail at runtime rather than being caught early, and type hints measurably improve what the AI produces. Make it a project rule — it's in the CLAUDE.md.

**Save scenes explicitly.** Changes made to the SceneTree in memory don't automatically persist to disk. If Claude modifies a scene and you don't save, it's gone.

**Godot must be findable.** If the MCP server can't locate your Godot binary, set the `GODOT_PATH` environment variable to point at it.

**Commit before big requests.** When you ask for something sweeping — "refactor the wave spawner" — commit first. Reverting is free; reconstructing is not.

---

## What to ask for first

Don't ask for Terra. Ask for Phase 0 from the design doc:

> Build a grey-box prototype. A single flat map. A base structure with health at one end. Enemy capsules spawning at a fixed point and pathing toward the base using a NavigationRegion or flow field. One defensive turret I can place with a mouse click that shoots enemies in range. Waves spawn on a timer and get larger each wave. Lose when base health hits zero. No art, no menus, no economy — capsules and boxes only.

That's a few hours of agent work and it answers the only question that matters right now: **is holding the line fun?** Everything in the GDD is built on that assumption, and it's cheaper to test it than to trust it.

Once it runs, play it ten times. If you find yourself wanting one more wave, you have a game. If you're bored on wave four, the problem is in the core loop and no amount of art, story, or star map will fix it — but it's a very cheap problem to have found on day one.
