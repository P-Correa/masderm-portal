import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'influencers_screen.dart';
import 'parcerias_screen.dart';
import 'produtos_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.people_outline_rounded, label: 'Influencers'),
    _NavItem(icon: Icons.handshake_outlined, label: 'Parcerias'),
    _NavItem(icon: Icons.inventory_2_outlined, label: 'Produtos'),
    _NavItem(icon: Icons.settings_outlined, label: 'Definições'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAll(context);
    });
  }

  Widget _buildScreen() {
    return switch (_selectedIndex) {
      0 => const DashboardScreen(),
      1 => const InfluencersScreen(),
      2 => const ParceriasScreen(),
      3 => const ProdutosScreen(),
      4 => const SettingsScreen(),
      _ => const DashboardScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          _Sidebar(
            selectedIndex: _selectedIndex,
            navItems: _navItems,
            onSelect: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onSelect;

  const _Sidebar({
    required this.selectedIndex,
    required this.navItems,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      width: 220,
      color: AppTheme.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: AppTheme.sidebarBg,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Masderm',
                    style: TextStyle(
                      color: AppTheme.sidebarText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          ),
          const SizedBox(height: 8),

          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: navItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isSelected = i == selectedIndex;
                  return _SidebarNavItem(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () => onSelect(i),
                  );
                }).toList(),
              ),
            ),
          ),

          // Bottom: user + logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.userEmail,
                  style: const TextStyle(
                    color: AppTheme.sidebarTextMuted,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => auth.logout(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.sidebarTextMuted,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 14),
                    label: const Text(
                      'Terminar sessão',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isSelected
        ? AppTheme.sidebarActive
        : _hovered
            ? AppTheme.sidebarHover
            : Colors.transparent;
    final fg = widget.isSelected
        ? Colors.white
        : _hovered
            ? Colors.white
            : AppTheme.sidebarTextMuted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: fg),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: widget.isSelected
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
