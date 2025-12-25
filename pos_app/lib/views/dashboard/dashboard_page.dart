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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Dashboard Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Sales summary, inventory status, and reports will appear here.'),
        ],
      ),
    );
  }
}
