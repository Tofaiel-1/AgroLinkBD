import sys

file_path = "lib/presentation/screens/buyer/buyer_orders_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix OrderService call
content = content.replace("OrderService().streamUserOrders(", "OrderService().getOrdersByBuyerId(")

# Remove activeOrders badge
target1 = """                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_activeOrders.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),"""
content = content.replace(target1, "")

# Remove pastOrders badge if exists
target2 = """                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_pastOrders.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),"""
content = content.replace(target2, "")


with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed buyer_orders_screen.dart")
