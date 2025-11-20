import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'models.dart'; // For Product reference
import 'sales_history.dart';
import 'colors.dart';
import 'product_and_stock.dart';
import 'prediction_and_setting.dart';
import 'notes_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool _showSuccess = false;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() => _showSuccess = true);
    _successController.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back, color: teal600),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Reset Password',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: teal900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: teal100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.mail_outline,
                                  size: 32, color: teal600),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Enter your email address and we\'ll send you a link to reset your password',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: teal600,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: teal100),
                              ),
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  prefixIcon: const Icon(Icons.mail_outline,
                                      color: teal600),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _sendResetLink,
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: teal400.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Send Reset Link',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showSuccess)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _successController,
                    curve: Curves.elasticOut,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 80, color: green600),
                        const SizedBox(height: 16),
                        Text(
                          'Success!',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: teal900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Password reset link has been sent to your email',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: teal600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============= MAIN SCREEN WITH BOTTOM NAV =============
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductManagementScreen(),
    const StockManagementScreen(),
    const NotesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: gray100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.dashboard, 'Home'),
            _buildNavItem(1, Icons.local_florist, 'Products'),
            _buildNavItem(2, Icons.inventory_2_outlined, 'Stock'),
            _buildNavItem(3, Icons.fact_check, 'Catatan'),
            _buildNavItem(4, Icons.settings, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(colors: [teal100, purple100])
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? teal600 : gray400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isActive ? teal600 : gray400,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= DASHBOARD SCREEN =============
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  // Chart data
  final int _currentYear = DateTime.now().year;
  List<double> _monthlyRevenue = List<double>.filled(12, 0.0);
  List<int> _years = [];
  List<double> _yearlyRevenue = [];
  bool _chartsLoaded = false;
  VoidCallback? _removeAppStateListener;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      7,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) _controllers[i].forward();
      });
    }

    // Load chart data after first frame to access Provider safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChartData();
      // Re-fetch charts whenever AppState changes (e.g., new sales recorded)
      final appState = context.read<AppState>();
      void listener() {
        _loadChartData();
      }
      appState.addListener(listener);
      _removeAppStateListener = () => appState.removeListener(listener);
    });
  }

  @override
  void dispose() {
    // Remove state listener to avoid leaks
    _removeAppStateListener?.call();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadChartData() async {
    try {
      final appState = context.read<AppState>();
      final monthly = await appState.fetchMonthlyRevenueSeries(_currentYear);
      final yearlyMap = await appState.fetchYearlyRevenueTotals();
      final years = yearlyMap.keys.toList()..sort();
      final yearlyVals = years.map((y) => yearlyMap[y] ?? 0.0).toList();
      if (!mounted) return;
      setState(() {
        _monthlyRevenue = monthly;
        _years = years;
        _yearlyRevenue = yearlyVals;
        _chartsLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _chartsLoaded = true; // prevent infinite loading on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // Dynamic statistics
    final products = appState.products;
    final int totalSold = products.fold(0, (sum, p) => sum + p.sold);
    final double totalRevenue = products.fold(0.0, (sum, p) => sum + (p.sold * p.price));
  final Product? topProduct = products.isEmpty
    ? null
    : products.reduce((a, b) => a.sold >= b.sold ? a : b);

    String _formatCurrency(double value) {
      int intVal = value.round();
      final s = intVal.toString();
      String formatted = '';
      int counter = 0;
      for (int i = s.length - 1; i >= 0; i--) {
        formatted = s[i] + formatted;
        counter++;
        if (counter == 3 && i != 0) {
          formatted = '.' + formatted;
          counter = 0;
        }
      }
      return 'Rp $formatted';
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.only(bottom: 80), // Add padding for bottom nav
            child: Column(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      top: 48, left: 24, right: 24, bottom: 60),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                'Hello, ${appState.userName}',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                appState.userName[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.storage,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Local Data Synced',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Summary Cards
                Transform.translate(
                  offset: const Offset(0, -48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildAnimatedCard(
                          0,
                          _buildSummaryCard(
                            icon: Icons.payments,
                            iconColor: green600,
                            iconBg: green100,
                            label: 'Total Pendapatan',
                            value: _formatCurrency(totalRevenue),
                            change: totalSold > 0 ? '+ Realtime' : 'Belum ada',
                            changeIcon: totalSold > 0 ? Icons.trending_up : null,
                            changeColor: green600,
                            leadingText: 'Rp',
                          ),
                        ),
                        const SizedBox(height: 12), // Reduced from 16
                        _buildAnimatedCard(
                          1,
                          _buildSummaryCard(
                            icon: Icons.emoji_events,
                            iconColor: purple500,
                            iconBg: purple100,
                            label: 'Top Product',
                            value: topProduct?.name ?? 'Belum ada',
                            change: topProduct != null ? '${topProduct.sold} unit terjual' : 'Menunggu penjualan',
                            changeIcon: topProduct != null ? Icons.local_florist : null,
                            changeColor: teal500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAnimatedCard(
                          2,
                          _buildSummaryCard(
                            icon: Icons.shopping_cart_checkout,
                            iconColor: orange600,
                            iconBg: orange100,
                            label: 'Total Terjual',
                            value: '$totalSold unit',
                            change: totalSold > 0 ? 'Realtime update' : 'Belum ada',
                            changeIcon: totalSold > 0 ? Icons.flash_on : null,
                            changeColor: orange600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Charts
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      24, 8, 24, 24), // Reduced top padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAnimatedCard(
                        4,
                        _buildChartCard(
                          'Penjualan Bulanan (Tahun $_currentYear)',
                          _chartsLoaded
                              ? _buildBarChart(
                                  _monthlyRevenue,
                                  const [
                                    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                                    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
                                  ],
                                )
                              : _buildLoadingChart(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAnimatedCard(
                        5,
                        _buildChartCard(
                          'Penjualan Tahunan',
                          _chartsLoaded
                              ? (_yearlyRevenue.isEmpty
                                  ? _buildEmptyChart('Belum ada penjualan')
                                  : _buildBarChart(
                                      _yearlyRevenue,
                                      _years.map((y) => y.toString()).toList(),
                                    ))
                              : _buildLoadingChart(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const SalesHistoryScreen()),
                            );
                          },
                          icon: const Icon(Icons.history, color: teal600, size: 18),
                          label: Text('Riwayat Penjualan',
                              style: GoogleFonts.poppins(color: teal600)),
                        ),
                      ),
                      const SizedBox(height: 24), // Reduced from 100 to 24
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Removed unused FAB (+) per request for clean home screen
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String change,
    IconData? changeIcon,
    required Color changeColor,
    String? leadingText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: leadingText != null
                  ? Text(
                      leadingText,
                      style: GoogleFonts.poppins(
                        color: iconColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: teal600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: teal900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (changeIcon != null) ...[
                      Icon(changeIcon, size: 14, color: changeColor),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        change,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: changeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: teal900,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> data, List<String> labels) {
    final maxValue = (data.isEmpty)
        ? 0.0
        : data.reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const spacing = 12.0;
        // Compute a responsive bar width within sane bounds
        double barWidth = (availableWidth / (data.isEmpty ? 1 : data.length)) - spacing;
        barWidth = barWidth.clamp(18.0, 40.0);
        final contentWidth = data.length * (barWidth + spacing);
        final needScroll = contentWidth > availableWidth;

        final row = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(data.length, (index) {
            final height = (maxValue <= 0)
                ? 0.0
                : (data[index] / maxValue) * 140;
            return Padding(
              padding: const EdgeInsets.only(right: spacing),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: barWidth,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: barWidth + 6,
                    child: Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: teal600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );

        if (needScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: contentWidth),
              child: row,
            ),
          );
        }
        return row;
      },
    );
  }

  Widget _buildLoadingChart() {
    return const Center(
      child: SizedBox(
        height: 48,
        width: 48,
        child: CircularProgressIndicator(color: teal600, strokeWidth: 3),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return SizedBox(
      height: 140,
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(color: teal600),
        ),
      ),
    );
  }

}

// PART 3 will contain Product Management, Stock Management, Sales Prediction, and Settings screens
