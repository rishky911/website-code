import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'screens/affordability_screen.dart';
import 'screens/roommate_screen.dart';
import 'screens/ai_advisor_screen.dart';

void main() {
  runApp(const RentMasterApp());
}

class RentMasterApp extends StatelessWidget {
  const RentMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RentMaster AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const MainScreen(),
    );
  }
}

enum UserMode { tenant, landlord }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  UserMode _userMode = UserMode.tenant;

  final List<Widget> _tenantScreens = [
    const AffordabilityScreen(),
    const RoommateScreen(),
    const AiAdvisorScreen(),
    const AiAdvisorScreen(isLeaseAnalyzer: true),
  ];

  final List<Widget> _landlordScreens = [
    const Center(child: Text("Landlord Dashboard (Coming Soon)")),
    const Center(child: Text("Lease Generator (Coming Soon)")),
    const AiAdvisorScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleUserMode() {
    setState(() {
      _userMode = _userMode == UserMode.tenant
          ? UserMode.landlord
          : UserMode.tenant;
      _selectedIndex = 0; // Reset to first tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTenant = _userMode == UserMode.tenant;
    final screens = isTenant ? _tenantScreens : _landlordScreens;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isTenant ? Colors.blue : Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.building2,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                children: [
                  const TextSpan(text: 'RentMaster'),
                  TextSpan(
                    text: 'AI',
                    style: TextStyle(
                      color: isTenant ? Colors.blue : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildModeButton('Tenant', UserMode.tenant),
                _buildModeButton('Landlord', UserMode.landlord),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: isTenant ? Colors.blue : Colors.black87,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: isTenant
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.layoutDashboard),
                  label: 'Budget',
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.users),
                  label: 'Split',
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.messageSquare),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.fileSearch),
                  label: 'Lease',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.briefcase),
                  label: 'Manage',
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.fileText),
                  label: 'Create Lease',
                ),
                BottomNavigationBarItem(
                  icon: Icon(LucideIcons.messageSquare),
                  label: 'AI Help',
                ),
              ],
      ),
    );
  }

  Widget _buildModeButton(String label, UserMode mode) {
    final isSelected = _userMode == mode;
    return GestureDetector(
      onTap: () {
        if (_userMode != mode) _toggleUserMode();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? (mode == UserMode.tenant ? Colors.blue : Colors.black87)
                : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
