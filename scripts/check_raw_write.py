#!/usr/bin/env python3
"""
PreToolUse hook：禁止 Claude 修改 raw/ 目录下的任何文件。
被 .claude/settings.json 的 PreToolUse hook 调用。

协议：Claude Code 通过 stdin 传入 JSON，格式为：
  {"tool_name": "Write", "tool_input": {"file_path": "..."}, ...}
阻断方式：exit(2) + stderr 输出原因。
"""
import sys
import json
import io

sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8")

try:
    data = json.loads(sys.stdin.read())
except (json.JSONDecodeError, Exception):
    sys.exit(0)

path = data.get("tool_input", {}).get("file_path", "")

# 归一化路径分隔符
path = path.replace("\\", "/")

if "raw/" in path:
    print(
        f"[BLOCKED] 禁止修改 raw/ 目录：{path}\n"
        "raw/ 是只读原始资料层，请将内容整理后写入 wiki/ 目录。",
        file=sys.stderr,
    )
    sys.exit(2)

sys.exit(0)
