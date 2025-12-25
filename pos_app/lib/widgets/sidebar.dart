import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onLogout;

  const Sidebar({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildProfileHeader(context),
            const Divider(),

            // Dashboard
            _buildListTile(
              icon: Icons.dashboard,
              label: 'Dashboard',
              onTap: () => _navigateTo('/dashboard'),
            ),

            // Items (expandable)
            ExpansionTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Items'),
              children: [
                _buildListTile(
                  icon: Icons.category,
                  label: 'Categories',
                  onTap: () => _navigateTo('/categories'),
                ),
                _buildListTile(
                  icon: Icons.production_quantity_limits,
                  label: 'Products',
                  onTap: () => _navigateTo('/products'),
                ),
              ],
            ),

            // Bills
            _buildListTile(
              icon: Icons.receipt_long,
              label: 'Bills',
              onTap: () => _navigateTo('/bills'),
            ),

            // Customers
            _buildListTile(
              icon: Icons.people,
              label: 'Customers',
              onTap: () => _navigateTo('/customers'),
            ),

            // Inventory
            _buildListTile(
              icon: Icons.store,
              label: 'Inventory',
              onTap: () => _navigateTo('/inventory'),
            ),

            // Reports
            _buildListTile(
              icon: Icons.bar_chart,
              label: 'Reports',
              onTap: () => _navigateTo('/reports'),
            ),

            // Tax & Discount
            _buildListTile(
              icon: Icons.percent,
              label: 'Tax & Discount',
              onTap: () => _navigateTo('/tax_discount'),
            ),

            // Settings (expandable)
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              children: [
                _buildListTile(
                  icon: Icons.person,
                  label: 'Edit Profile',
                  onTap: () => _navigateTo('/settings/edit_profile'),
                ),
                _buildListTile(
                  icon: Icons.storefront,
                  label: 'Store Information',
                  onTap: () => _navigateTo('/settings/store_info'),
                ),
                _buildListTile(
                  icon: Icons.attach_money,
                  label: 'Currency Settings',
                  onTap: () => _navigateTo('/settings/currency'),
                ),
                _buildListTile(
                  icon: Icons.manage_accounts,
                  label: 'User Management',
                  onTap: () => _navigateTo('/settings/user_management'),
                ),
                _buildListTile(
                  icon: Icons.print,
                  label: 'Printer Settings',
                  onTap: () => _navigateTo('/settings/printer'),
                ),
              ],
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back(); // close drawer first
                onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    // TODO: Replace with your user/profile data or GetX controller
    const String roleName = 'Admin';
    const String email = 'admin@example.com';

    return UserAccountsDrawerHeader(
      currentAccountPicture: GestureDetector(
        onTap: () {
          Get.back();
          _navigateTo('/settings/edit_profile');
        },
        child: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile_avatar.png'),
        ),
      ),
      accountName: Text(roleName),
      accountEmail: Text(email),
      otherAccountsPictures: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          tooltip: 'Edit Profile',
          onPressed: () {
            Get.back();
            _navigateTo('/settings/edit_profile');
          },
        )
      ],
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Get.back(); // close drawer
        onTap();
      },
    );
  }

  void _navigateTo(String route) {
    Get.toNamed(route);
  }
}
