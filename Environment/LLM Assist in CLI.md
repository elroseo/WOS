# LLM Assist in CLI

To use LLM Assist from the Copilot CLI:

```bash
cd "/Users/elroseo/GitHub work/llm-assist"
copilot --yolo --disable-mcp-server github
```

- `--yolo` auto-approves tool calls for the session (no per-command confirmation).
- `--disable-mcp-server github` suppresses the VS Code OAuth GitHub MCP error (CLI has its own built-in GitHub MCP).
