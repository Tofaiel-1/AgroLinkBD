import os

def patch_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    out_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        out_lines.append(line)
        if "case UserType.company:" in line:
            company_lines = []
            case_indent = len(line) - len(line.lstrip())
            i += 1
            while i < len(lines):
                next_line = lines[i]
                next_stripped = next_line.strip()
                next_indent = len(next_line) - len(next_line.lstrip())
                
                # Check if we hit the next case, default, or the end of the switch
                is_next_case = next_stripped.startswith('case ') or next_stripped.startswith('default:')
                is_end_of_switch = next_stripped == '}' and next_indent < case_indent
                
                if is_next_case or is_end_of_switch:
                    out_lines.extend(company_lines)
                    seller_case = line.replace('UserType.company', 'UserType.seller')
                    out_lines.append(seller_case)
                    for cl in company_lines:
                        sl = cl.replace("'Company'", "'Seller'").replace('"Company"', '"Seller"').replace('কোম্পানি', 'বিক্রেতা')
                        # Special fixes for specific files/methods if needed
                        if 'companyPermissions' in sl:
                            sl = sl.replace('companyPermissions', 'buyerPermissions')
                        out_lines.append(sl)
                    
                    # Do NOT append next_line here; it will be appended in the next outer loop iteration
                    # because we don't increment i
                    break
                    
                company_lines.append(next_line)
                i += 1
            continue
        i += 1
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(out_lines)
    print("Patched", filepath)

files = [
    "lib/core/services/access_denial_handler.dart",
    "lib/core/services/screen_access_control.dart",
    "lib/core/services/route_guard.dart",
    "lib/core/services/role_service.dart",
    "lib/core/services/role_permissions.dart",
    "lib/presentation/screens/auth/login_screen.dart",
    "lib/presentation/screens/auth/register_screen.dart",
    "lib/presentation/screens/home/widgets/greeting_section.dart",
    "lib/presentation/screens/navigation/role_based_navigation_container.dart",
    "lib/presentation/widgets/global_announcement_banner.dart",
    "lib/presentation/widgets/personalized_content_widget.dart"
]
for f in files:
    patch_file(f)
