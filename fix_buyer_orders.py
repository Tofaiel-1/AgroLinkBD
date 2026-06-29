import sys

file_path = "lib/presentation/screens/buyer/buyer_orders_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False
for i, line in enumerate(lines):
    if line.strip().startswith('final List<Map<String, dynamic>> _activeOrders = ['):
        skip = True
        
    if skip and line.strip() == '];':
        if i > 25 and lines[i-1].strip() == '}':
            pass
        elif i > 60:
            skip = False
            continue
            
    if skip:
        if line.strip().startswith('final List<Map<String, dynamic>> _pastOrders = ['):
            pass
        elif line.strip() == '];':
            if i > 60:
                skip = False
        continue
    else:
        new_lines.append(line)

content = "".join(new_lines)

# Replace TabBarView
target_start = content.find('Expanded(\n              child: TabBarView(')
if target_start == -1:
    target_start = content.find('Expanded(\n                child: TabBarView(')
    
if target_start != -1:
    # Find matching closing bracket
    open_brackets = 0
    target_end = target_start
    for i in range(target_start, len(content)):
        if content[i] == '(':
            open_brackets += 1
        elif content[i] == ')':
            open_brackets -= 1
            if open_brackets == 0:
                target_end = i + 2 # to include ),
                break
                
    tabview_code = content[target_start:target_end]
    
    replacement = """Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: OrderService().streamUserOrders(FirebaseAuth.instance.currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  final allOrders = snapshot.data ?? [];
                  final activeOrders = allOrders.where((o) => o.status == 'pending' || o.status == 'processing' || o.status == 'shipped').toList();
                  final pastOrders = allOrders.where((o) => o.status == 'delivered' || o.status == 'cancelled').toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Active orders tab
                      activeOrders.isEmpty
                          ? _buildEmptyState(
                              isDark, 'কোনো সক্রিয় অর্ডার নেই', Icons.inbox)
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: activeOrders.length,
                              itemBuilder: (context, index) {
                                return _buildActiveOrderCard(
                                    activeOrders[index], isDark);
                              },
                            ),
                      
                      // Past orders tab
                      pastOrders.isEmpty
                          ? _buildEmptyState(
                              isDark, 'কোনো পূর্ববর্তী অর্ডার নেই', Icons.history)
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: pastOrders.length,
                              itemBuilder: (context, index) {
                                return _buildPastOrderCard(
                                    pastOrders[index], isDark);
                              },
                            ),
                    ],
                  );
                },
              ),
            ),"""
    
    content = content[:target_start] + replacement + content[target_end:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated buyer_orders_screen.dart")
