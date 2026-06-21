import re
file_path = 'D:/App/AgroLinkBD/lib/presentation/screens/driver/driver_dashboard.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

garbled_map = {
    'title: \'à¦¸à¦¾à¦®à§ à¦ªà§ à¦°à¦¤à¦¿à¦• à¦²à§‡à¦¨à¦¦à§‡à¦¨\','.encode('utf-8'): 'title: \'সাম্প্রতিক লেনদেন\','.encode('utf-8'),
    'title: \'à¦Ÿà§ à¦°à¦¿à¦ª #TR2024-05810\','.encode('utf-8'): 'title: \'ট্রিপ #TR2024-05810\','.encode('utf-8'),
    'date: \'à¦†à¦œ, à¦¸à¦•à¦¾à¦² à§¯:à§§à§«\','.encode('utf-8'): 'date: \'আজ, সকাল ৯:১৫\','.encode('utf-8'),
    'title: \'à¦¤à§‡à¦² à¦–à¦°à¦š\','.encode('utf-8'): 'title: \'তেল খরচ\','.encode('utf-8'),
    'date: \'à¦—à¦¤à¦•à¦¾à¦², à¦¬à¦¿à¦•à§‡à¦² à§«:à§©à§¦\','.encode('utf-8'): 'date: \'গতকাল, বিকেল ৫:৩০\','.encode('utf-8'),
    '\'à¦‰à¦ªà¦²à¦¬à§ à¦§ à¦Ÿà§ à¦°à¦¿à¦ª\''.encode('utf-8'): '\'উপলব্ধ ট্রিপ\''.encode('utf-8'),
    '\'à§« à¦¨à¦¤à§ à¦¨\''.encode('utf-8'): '\'৫ নতুন\''.encode('utf-8'),
    '\'à¦†à¦œà¦•à§‡à¦° à¦Ÿà§ à¦°à¦¿à¦ª\''.encode('utf-8'): '\'আজকের ট্রিপ\''.encode('utf-8'),
    'Get.snackbar(\'à¦‡à¦¤à¦¿à¦¹à¦¾à¦¸\', \'à¦¸à¦¬ à¦Ÿà§ à¦°à¦¿à¦ª à¦¦à§‡à¦–à§ à¦¨\');'.encode('utf-8'): 'Get.snackbar(\'ইতিহাস\', \'সব ট্রিপ দেখুন\');'.encode('utf-8'),
    'child: const Text(\'à¦¸à¦¬ à¦¦à§‡à¦–à§ à¦¨\'),'.encode('utf-8'): 'child: const Text(\'সব দেখুন\'),'.encode('utf-8'),
    '\'pickup\': \'à¦®à¦¤à¦¿à¦ à¦¿à¦²\''.encode('utf-8'): '\'pickup\': \'মতিঝিল\''.encode('utf-8'),
    '\'delivery\': \'à¦¤à§‡à¦œà¦—à¦¾à¦ à¦“\''.encode('utf-8'): '\'delivery\': \'তেজগাঁও\''.encode('utf-8'),
    '\'distance\': \'à§«.à§¨ à¦•à¦¿à¦®à¦¿\''.encode('utf-8'): '\'distance\': \'৫.২ কিমি\''.encode('utf-8'),
    '\'urgency\': \'à¦¦à§ à¦°à§ à¦¤\''.encode('utf-8'): '\'urgency\': \'দ্রুত\''.encode('utf-8'),
    '\'pickup\': \'à¦—à§ à¦²à¦¶à¦¾à¦¨\''.encode('utf-8'): '\'pickup\': \'গুলশান\''.encode('utf-8'),
    '\'delivery\': \'à¦¬à¦¨à¦¾à¦¨à§€\''.encode('utf-8'): '\'delivery\': \'বনানী\''.encode('utf-8'),
    '\'distance\': \'à§©.à§® à¦•à¦¿à¦®à¦¿\''.encode('utf-8'): '\'distance\': \'৩.৮ কিমি\''.encode('utf-8'),
    '\'urgency\': \'à¦¸à§ à¦¬à¦¾à¦­à¦¾à¦¬à¦¿à¦•\''.encode('utf-8'): '\'urgency\': \'স্বাভাবিক\''.encode('utf-8'),
    '\'à¦Ÿà§ à¦°à¦¿à¦ª à¦—à§ƒà¦¹à§€à¦¤\''.encode('utf-8'): '\'ট্রিপ গৃহীত\''.encode('utf-8'),
    'à¦¥à§‡à¦•à§‡'.encode('utf-8'): 'থেকে'.encode('utf-8'),
    '\'route\': \'à¦§à¦¾à¦¨à¦®à¦¨à§ à¦¡à¦¿ â†’ à¦«à¦¾à¦°à§ à¦®à¦—à§‡à¦Ÿ\''.encode('utf-8'): '\'route\': \'ধানমন্ডি -> ফার্মগেট\''.encode('utf-8'),
    '\'status\': \'à¦¸à¦®à§ à¦ªà¦¨à§ à¦¨\''.encode('utf-8'): '\'status\': \'সম্পন্ন\''.encode('utf-8'),
    '\'route\': \'à¦¤à§‡à¦œà¦—à¦¾à¦ à¦“ â†’ à¦®à§‹à¦¹à¦¾à¦®à§ à¦®à¦¦à¦ªà§ à¦°\''.encode('utf-8'): '\'route\': \'তেজগাঁও -> মোহাম্মদপুর\''.encode('utf-8'),
    '\'à¦¸à¦®à§ à¦ªà¦¨à§ à¦¨\''.encode('utf-8'): '\'সম্পন্ন\''.encode('utf-8'),
}

text_bytes = text.encode('utf-8')
for bad, good in garbled_map.items():
    text_bytes = text_bytes.replace(bad, good)

with open(file_path, 'wb') as f:
    f.write(text_bytes)
print('Fixed byte mapping')
