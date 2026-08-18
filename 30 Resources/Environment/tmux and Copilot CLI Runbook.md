---
type: reference
para: resource
created: 2026-08-18
updated: 2026-08-18
tags:
  - tmux
  - copilot-cli
  - tooling
---

# tmux and Copilot CLI Runbook

Use one tmux session as the persistent workspace, with one tmux window and one Copilot CLI session per task. Prefer windows for Copilot and panes for supporting shells, logs, or tests.

## Start the workspace

Create a named tmux session with a main window:

```bash
tmux new-session -s copilot -n main
```

Launch Copilot CLI:

```bash
copilot --yolo --disable-mcp-server github
```

The flags reduce command-confirmation interruptions and suppress the harmless VS Code OAuth error from the configured GitHub MCP server. Copilot CLI provides its own built-in GitHub tools.

## Organize work

Use one named window for each distinct task:

```text
0: main
1: incident-4537
2: customer-research
3: scratch
```

Create a window with `Ctrl-b c`, then rename it with `Ctrl-b ,`.

Inside each Copilot window:

- `/rename incident-4537` names the current Copilot session.
- `/new` starts a separate conversation.
- `/resume` reopens or switches to an existing session.
- `/fork` branches the current conversation into a new session.
- `/tasks` displays background tasks.
- `Ctrl-x b` moves the current task into the background.
- `/context` displays context-window usage.
- `/compact` summarizes history when the context becomes large.

Keep the tmux window name and Copilot session name aligned so it is easy to recover the correct context.

## Use supporting panes

Keep Copilot in the main pane and use additional panes only when useful for commands, logs, or monitoring:

- `Ctrl-b %` splits the window vertically.
- `Ctrl-b "` splits the window horizontally.
- `Ctrl-b` followed by an arrow key changes panes.
- `Ctrl-b z` zooms or restores the current pane.

Copilot generally benefits from a full-width terminal, so separate windows are preferable for independent Copilot sessions.

## Leave and return

Detach from tmux without stopping its processes:

```text
Ctrl-b d
```

List available sessions:

```bash
tmux ls
```

Return to the workspace:

```bash
tmux attach-session -t copilot
```

When already inside tmux, switch sessions with:

```bash
tmux switch-client -t copilot
```

Copilot also persists its own conversations. If a Copilot process was closed, launch it again and use `/resume` to recover the conversation.

## Close work safely

Close an individual pane or window by exiting its shell:

```bash
exit
```

Close the entire tmux workspace only when all contained processes can be terminated:

```bash
tmux kill-session -t copilot
```

This stops every process in the session, including all Copilot processes.

## Suggested daily workflow

1. Run `tmux attach -t copilot` or create the session if it does not exist.
2. Keep `main` for coordination and short tasks.
3. Create and name a new window for each substantial task.
4. Run Copilot in that window and give the Copilot session the same name with `/rename`.
5. Use a pane for supporting commands only when necessary.
6. Detach with `Ctrl-b d` at the end of the work period.
7. Reattach later and use `/resume` if any Copilot process needs to be restored.

# tmux Cheat Sheet
## How to type tmux shortcuts

`Ctrl-b` is tmux's prefix, not usually part of one simultaneous chord:

1. Hold `Control` and press `b`.
2. Release both keys.
3. Press the command key, such as `d`, `c`, or `w`.

For example, `Ctrl-b d` means press `Control+b`, release, then press `d`. On a Mac, use the `Control` key marked `control` or `^`, not the `Command` key marked `command` or `⌘`.

Symbols may require `Shift` on a standard keyboard:

- `Ctrl-b %`: press `Control+b`, release, then press `Shift+5` for `%`.
- `Ctrl-b "`: press `Control+b`, release, then press `Shift+'` for `"`.
- `Ctrl-b [`: press `Control+b`, release, then press `[`.
- `Ctrl-b ,`: press `Control+b`, release, then press `,`.
- `Ctrl-b` plus an arrow: press `Control+b`, release, then press the arrow key.
- `Ctrl-b`, then `Ctrl` plus an arrow: press the prefix, release it, then hold `Control` while pressing an arrow key.

If the second key does nothing, press the prefix and command more deliberately rather than holding every key at once.


All tmux shortcuts begin with the prefix `Ctrl-b`.

| Action                  | Shortcut or command               |
| ----------------------- | --------------------------------- |
| Create named session    | `tmux new -s NAME`                |
| List sessions           | `tmux ls`                         |
| Attach session          | `tmux attach -t NAME`             |
| Detach                  | `Ctrl-b d`                        |
| Create window           | `Ctrl-b c`                        |
| Rename window           | `Ctrl-b ,`                        |
| List or select windows  | `Ctrl-b w`                        |
| Next window             | `Ctrl-b n`                        |
| Previous window         | `Ctrl-b p`                        |
| Select numbered window  | `Ctrl-b 0` through `Ctrl-b 9`     |
| Close window            | `exit` or `Ctrl-d`                |
| Split vertically        | `Ctrl-b %`                        |
| Split horizontally      | `Ctrl-b "`                        |
| Move between panes      | `Ctrl-b` plus an arrow key        |
| Resize pane             | `Ctrl-b`, then `Ctrl` plus arrow  |
| Zoom or restore pane    | `Ctrl-b z`                        |
| Close pane              | `exit` or `Ctrl-d`                |
| Enter scroll/copy mode  | `Ctrl-b [`                        |
| Exit scroll/copy mode   | `q`                               |
| Show clock              | `Ctrl-b t`                        |
| Reload configuration    | `tmux source-file ~/.tmux.conf`   |
| Switch tmux session     | `tmux switch-client -t NAME`      |
| Kill named session      | `tmux kill-session -t NAME`       |

## Copilot CLI companion commands

| Action                         | Command      |
| ------------------------------ | ------------ |
| Name the current session       | `/rename`    |
| Start a new conversation       | `/new`       |
| Find and restore a session     | `/resume`    |
| Branch the current session     | `/fork`      |
| View background tasks          | `/tasks`     |
| Move task to background        | `Ctrl-x b`   |
| Check context usage            | `/context`   |
| Compress conversation history  | `/compact`   |
| Show command help              | `/help`      |
