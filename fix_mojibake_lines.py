import re

file_path = 'D:/App/AgroLinkBD/lib/presentation/screens/driver/driver_dashboard.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

def fix_line(i, old, new):
    if old in lines[i]:
        lines[i] = lines[i].replace(old, new)

# 533 (0-indexed 533) is line 534
fix_line(533, lines[533].strip(), "title: 'সাম্প্রতিক লেনদেন',")
fix_line(537, lines[537].strip(), "title: 'ট্রিপ #TR2024-05810',")
fix_line(546, lines[546].strip(), "amount: '৳ 1,500',")
fix_line(568, lines[568].strip(), "'উপলব্ধ ট্রিপ',")
fix_line(585, lines[585].strip(), "'৫ নতুন',")
fix_line(615, lines[615].strip(), "'আজকের ট্রিপ',")
fix_line(624, lines[624].strip(), "Get.snackbar('ইতিহাস', 'সব ট্রিপ দেখুন');")
fix_line(626, lines[626].strip(), "child: const Text('সব দেখুন'),")
fix_line(821, lines[821].strip(), "'pickup': 'মতিঝিল',")
fix_line(822, lines[822].strip(), "'delivery': 'তেজগাঁও',")
fix_line(824, lines[824].strip(), "'distance': '৫.২ কিমি',")
fix_line(825, lines[825].strip(), "'urgency': 'দ্রুত',")
fix_line(829, lines[829].strip(), "'pickup': 'গুলশান',")
fix_line(832, lines[832].strip(), "'distance': '৩.৮ কিমি',")
fix_line(833, lines[833].strip(), "'urgency': 'স্বাভাবিক',")
fix_line(845, lines[845].strip(), "'ট্রিপ গৃহীত',")
fix_line(941, lines[941].strip(), "'route': 'ধানমন্ডি -> ফার্মগেট',")
fix_line(942, lines[942].strip(), "'status': 'সম্পন্ন',")
fix_line(943, lines[943].strip(), "'status': 'সম্পন্ন',")
fix_line(948, lines[948].strip(), "'route': 'তেজগাঁও -> মোহাম্মদপুর',")
fix_line(950, lines[950].strip(), "'status': 'সম্পন্ন',")

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print('Fixed by line numbers')
