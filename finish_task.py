import os

task_file = "C:/Users/mdtof/.gemini/antigravity-ide/brain/a49834a1-6cde-416d-96ab-f08553fa762b/task.md"

with open(task_file, 'r', encoding='utf-8') as f:
    content = f.read()
    
content = content.replace("- `[/]` 5. **Verify**", "- `[x]` 5. **Verify**")

with open(task_file, 'w', encoding='utf-8') as f:
    f.write(content)
