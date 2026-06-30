import os
import re

files_to_patch = [
    "lib/core/services/access_denial_handler.dart",
    "lib/core/services/screen_access_control.dart",
    "lib/core/services/route_guard.dart",
    "lib/core/services/role_service.dart",
    "lib/core/services/role_permissions.dart",
]

for filepath in files_to_patch:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We want to find "case UserType.company: ... return/break;" and add seller after it.
    # It might be easier to just find the switch blocks and if 'case UserType.seller:' is missing, add it.
    
    # Let's just fix it by injecting case UserType.seller: where case UserType.company: is found.
    # Since company and seller are similar, we can duplicate the company case and replace company with seller, Company with Seller.
    
    def replacer(match):
        company_block = match.group(0)
        seller_block = company_block.replace("UserType.company", "UserType.seller").replace("'Company'", "'Seller'").replace('"Company"', '"Seller"')
        # Special cases for different files
        if "RolePermissions" in seller_block:
            seller_block = company_block.replace("UserType.company", "UserType.seller").replace("companyPermissions", "buyerPermissions") # Or whatever is appropriate
            
        return company_block + "\n" + seller_block

    # Regex to capture a case UserType.company: block
    # It starts with case UserType.company: and goes until the next case, default, or }
    new_content = re.sub(r"([ \t]*)case UserType\.company:[\s\S]*?(?=\n\s*(?:case |default:|}))", replacer, content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"Patched {filepath}")
