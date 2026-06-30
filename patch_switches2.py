import os
import re

files_to_patch = [
    "lib/presentation/screens/auth/login_screen.dart",
    "lib/presentation/screens/auth/register_screen.dart",
    "lib/presentation/screens/home/widgets/greeting_section.dart",
    "lib/presentation/screens/navigation/role_based_navigation_container.dart",
    "lib/presentation/widgets/global_announcement_banner.dart",
    "lib/presentation/widgets/personalized_content_widget.dart"
]

for filepath in files_to_patch:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    def replacer(match):
        company_block = match.group(0)
        seller_block = company_block.replace("UserType.company", "UserType.seller").replace("'Company'", "'Seller'").replace('"Company"', '"Seller"')
        return company_block + "\n" + seller_block

    new_content = re.sub(r"([ \t]*)case UserType\.company:[\s\S]*?(?=\n\s*(?:case |default:|}))", replacer, content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"Patched {filepath}")
