import os

task_file = "C:/Users/mdtof/.gemini/antigravity-ide/brain/a49834a1-6cde-416d-96ab-f08553fa762b/task.md"

with open(task_file, 'r', encoding='utf-8') as f:
    content = f.read()
    
content = content.replace("- `[/]` 1. **Prepare `marketplace_screen.dart`**", "- `[x]` 1. **Prepare `marketplace_screen.dart`**")
content = content.replace("- `[ ]` 2. **Integrate SSL & Orders**", "- `[x]` 2. **Integrate SSL & Orders**")
content = content.replace("- `[ ]` 3. **Adapt Farmer Flow**", "- `[x]` 3. **Adapt Farmer Flow**")
content = content.replace("- `[ ]` 4. **Update Navigation**", "- `[x]` 4. **Update Navigation**")
content = content.replace("- `[ ]` 5. **Verify**", "- `[/]` 5. **Verify**")

with open(task_file, 'w', encoding='utf-8') as f:
    f.write(content)
