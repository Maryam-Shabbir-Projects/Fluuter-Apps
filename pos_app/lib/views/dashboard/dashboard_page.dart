import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const _AppDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: _DashboardContent(),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Admin'),
            accountEmail: Text('admin@pos.local'),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 32),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Get.offNamed('/dashboard'),
          ),

          ExpansionTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Items'),
            children: [
              ListTile(
                title: const Text('Categories'),
                onTap: () => Get.toNamed('/categories'),
              ),
              ListTile(
                title: const Text('Products'),
                onTap: () => Get.toNamed('/products'),
              ),
            ],
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Bills'),
            onTap: () => Get.toNamed('/bills'),
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Customers'),
            onTap: () => Get.toNamed('/customers'),
          ),

          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () => Get.toNamed('/inventory'),
          ),

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () => Get.toNamed('/reports'),
          ),

          ListTile(
            leading: const Icon(Icons.percent),
            title: const Text('Tax & Discount'),
            onTap: () => Get.toNamed('/tax_discount'),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              authController.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    // Dummy data - replace with your real data from controller
    // Sales Summary
    final double totalSalesRevenue = 12500.75;
    final int itemsSold = 342;
    final int itemsReturned = 12;

    // Purchase Summary
    final int totalPurchases = 76;
    final double purchaseValue = 8900.50;
    final int itemsPurchased = 210;
    final int activeVendors = 8;

    // Stock Overview
    final int totalProducts = 1200;
    final int lowStockItems = 45;
    final int outOfStock = 10;
    final String stockStatus = 'Good';

    // Navigate to reports page
    void navigateToReports() => Get.toNamed('/reports');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _quickActionCard(
                icon: Icons.add_shopping_cart,
                title: 'New Sale',
                description: 'Create Bill',
                color: Colors.green,
                onTap: () => Get.toNamed('/bills'),
              ),
              _quickActionCard(
                icon: Icons.add_box,
                title: 'Add Product',
                description: 'Manage Inventory',
                color: Colors.blue,
                onTap: () => Get.toNamed('/inventory'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Dashboard Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Sales Summary Block
          _summaryCard(
            title: 'Sales Summary (Last 7 Days)',
            onTap: navigateToReports,
            items: [
              _SummaryItemData(
                label: 'Total Revenue',
                value: totalSalesRevenue.toStringAsFixed(2),
                color: Colors.green,
                icon: Icons.attach_money,
                isCurrency: true,
              ),
              _SummaryItemData(
                label: 'Items Sold',
                value: '$itemsSold',
                color: Colors.blue,
                icon: Icons.shopping_cart,
              ),
              _SummaryItemData(
                label: 'Returns',
                value: '$itemsReturned',
                color: Colors.red,
                icon: Icons.undo,
              ),
            ],
          ),

          // Purchase Summary Block
          _summaryCard(
            title: 'Purchase Summary (Last 7 Days)',
            onTap: navigateToReports,
            backgroundColor: Colors.orange[50],
            items: [
              _SummaryItemData(
                label: 'Total Purchases',
                value: '$totalPurchases',
                color: Colors.orange.shade800,
                icon: Icons.shopping_bag,
              ),
              _SummaryItemData(
                label: 'Purchase Value',
                value: purchaseValue.toStringAsFixed(2),
                color: Colors.orange.shade600,
                icon: Icons.attach_money,
                isCurrency: true,
              ),
              _SummaryItemData(
                label: 'Items Purchased',
                value: '$itemsPurchased',
                color: Colors.orange.shade400,
                icon: Icons.inventory_2,
              ),
              _SummaryItemData(
                label: 'Active Vendors',
                value: '$activeVendors',
                color: Colors.orange.shade200,
                icon: Icons.people,
              ),
            ],
          ),

          // Stock Overview Block
          _summaryCard(
            title: 'Stock Overview',
            onTap: navigateToReports,
            backgroundColor: Colors.blueGrey[50],
            items: [
              _SummaryItemData(
                label: 'Total Products',
                value: '$totalProducts',
                color: Colors.blueGrey.shade800,
                icon: Icons.category,
              ),
              _SummaryItemData(
                label: 'Low Stock Items',
                value: '$lowStockItems',
                color: Colors.red.shade700,
                icon: Icons.warning,
              ),
              _SummaryItemData(
                label: 'Out of Stock',
                value: '$outOfStock',
                color: Colors.red.shade900,
                icon: Icons.block,
              ),
              _SummaryItemData(
                label: 'Stock Status',
                value: stockStatus,
                color: Colors.green.shade700,
                icon: Icons.check_circle,
                isTextValue: true,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(''),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          )),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required List<_SummaryItemData> items,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items.map((item) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: onTap,
                      child: _summaryItem(item),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap to view detailed reports',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(_SummaryItemData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, color: item.color, size: 20),
              const SizedBox(width: 6),
              if (item.isCurrency)
                Text('\$${item.value}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: item.color))
              else
                Text(item.value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: item.color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _SummaryItemData {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isCurrency;
  final bool isTextValue;

  _SummaryItemData({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.isCurrency = false,
    this.isTextValue = false,
  });
}
