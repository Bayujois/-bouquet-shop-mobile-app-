import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'colors.dart';
import 'main.dart' as main;

// Part 4 (Final): Sales Prediction & Settings

// ============= SALES PREDICTION SCREEN =============
class SalesPredictionScreen extends StatefulWidget {
  const SalesPredictionScreen({super.key});

  @override
  State<SalesPredictionScreen> createState() => _SalesPredictionScreenState();
}

class _SalesPredictionScreenState extends State<SalesPredictionScreen>
    with TickerProviderStateMixin {
  String selectedProduct = '';
  final unitPriceController = TextEditingController();
  final totalCostController = TextEditingController();
  bool showPrediction = false;

  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  final List<Map<String, dynamic>> predictionData = [
    {'month': 'Jan', 'predicted': 120.0, 'actual': 115.0},
    {'month': 'Feb', 'predicted': 145.0, 'actual': 138.0},
    {'month': 'Mar', 'predicted': 160.0, 'actual': 155.0},
    {'month': 'Apr', 'predicted': 178.0, 'actual': 172.0},
    {'month': 'May', 'predicted': 195.0, 'actual': 188.0},
    {'month': 'Jun', 'predicted': 210.0, 'actual': 205.0},
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
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
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    unitPriceController.dispose();
    totalCostController.dispose();
    super.dispose();
  }

  void _generatePrediction() {
    if (unitPriceController.text.isEmpty || totalCostController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      showPrediction = true;
    });

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  double get profitMargin {
    final price = double.tryParse(unitPriceController.text) ?? 0;
    final cost = double.tryParse(totalCostController.text) ?? 0;
    if (price == 0) return 0;
    return ((price - cost) / price * 100);
  }

  double get suggestedPrice {
    final cost = double.tryParse(totalCostController.text) ?? 0;
    return cost * 1.65;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                  top: 56, left: 24, right: 24, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Forecast',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI-powered predictions',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Input Form
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
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
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome,
                                color: purple500, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Generate Prediction',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: teal900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: gray50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: gray100),
                          ),
                          child: DropdownButton<String?>(
                            value: (context.watch<AppState>().products
                                    .map((p) => p.name)
                                    .contains(selectedProduct))
                                ? selectedProduct
                                : null,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: context
                                .watch<AppState>()
                                .products
                                .map((p) => DropdownMenuItem<String>(
                                      value: p.name,
                                      child: Text(p.name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedProduct = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                            unitPriceController, 'Material Unit Price (Rp)'),
                        const SizedBox(height: 16),
                        _buildInputField(
                            totalCostController, 'Total Production Cost (Rp)'),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _generatePrediction,
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: teal400.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Generate',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showPrediction) ...[
                    const SizedBox(height: 24),
                    _buildAnimatedCard(
                      0,
                      _buildChartCard(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnimatedCard(
                            1,
                            _buildSummaryCard(
                              'Profit Margin',
                              '${profitMargin.toStringAsFixed(1)}%',
                              Icons.trending_up,
                              const LinearGradient(colors: [green400, teal400]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildAnimatedCard(
                            2,
                            _buildSummaryCard(
                              'Suggested Price',
                              formatRupiah(suggestedPrice),
                              Icons.attach_money,
                              const LinearGradient(
                                  colors: [purple400, pink400]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedCard(
                      3,
                      _buildInsightCard(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildInputField(TextEditingController controller, String label) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gray100),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
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
            'Predicted vs Actual Sales',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: teal900,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: _buildGroupedBarChart(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Predicted', teal400),
              const SizedBox(width: 24),
              _buildLegend('Actual', purple400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedBarChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: predictionData.map((data) {
        final maxValue = 220.0;
        final predictedHeight = (data['predicted'] / maxValue) * 160;
        final actualHeight = (data['actual'] / maxValue) * 160;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 12,
                  height: predictedHeight,
                  decoration: BoxDecoration(
                    color: teal400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 12,
                  height: actualHeight,
                  decoration: BoxDecoration(
                    color: purple400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data['month'],
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: teal600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: teal600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [teal50, purple50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: purple100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: purple100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: purple600, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insight',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: teal900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prediction generated from cost conversion data. Based on current market trends and historical sales data, we recommend maintaining the suggested price point for optimal profit margins. Sales are expected to increase by 15% in the next quarter.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: teal600,
                    height: 1.5,
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

// ============= SETTINGS SCREEN =============
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: SingleChildScrollView(
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
                  top: 56, left: 24, right: 24, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize your experience',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Appearance',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: teal900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: teal100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.language,
                                  color: teal600, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Language',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: teal900,
                                    ),
                                  ),
                                  Text(
                                    appState.language == 'EN'
                                        ? 'English'
                                        : 'Indonesian',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: teal600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => appState.toggleLanguage(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: teal50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  appState.language,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: teal600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32, color: gray100),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: purple100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                appState.darkMode
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: purple600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dark Mode',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: teal900,
                                    ),
                                  ),
                                  Text(
                                    appState.darkMode ? 'Enabled' : 'Disabled',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: teal600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: appState.darkMode,
                              onChanged: (_) => appState.toggleDarkMode(),
                              activeTrackColor: purple500,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Data Management Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Data Management',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: teal900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: green100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.storage,
                                  color: green600, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sync Data Offline',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: teal900,
                                    ),
                                  ),
                                  Text(
                                    'Auto-sync when online',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: teal600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: appState.offlineSync,
                              onChanged: (_) => appState.toggleOfflineSync(),
                              activeTrackColor: green600,
                            ),
                          ],
                        ),
                        const Divider(height: 32, color: gray100),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: red100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_forever,
                                  color: red600, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reset Semua Data',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: teal900,
                                    ),
                                  ),
                                  Text(
                                    'Delete all local database & cached info',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: red600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Konfirmasi Reset', style: GoogleFonts.poppins()),
                                    content: Text(
                                      'Semua data lokal (produk, material, catatan, penjualan) akan dihapus permanen. Lanjutkan?',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text('Batal', style: GoogleFonts.poppins()),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: red600,
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(ctx); // close dialog
                                          await context.read<AppState>().resetAllData();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Data berhasil direset.')),);
                                          }
                                        },
                                        child: Text('Reset', style: GoogleFonts.poppins(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: red100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Hapus',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: red600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (appState.offlineSync) ...[
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(colors: [green100, teal50]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: green100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.storage,
                                  color: green600, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Last synced: 2 minutes ago',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: green600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All data stored locally and synced automatically',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: teal600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // About Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'About',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: teal900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('pesan Developer',
                                  style: GoogleFonts.poppins()),
                              content: Text(
                                'dari BAYU JOIS WANVIENDI untuk AGLIS TRINOPITA PUTRI, Sayangggg maaf kalau effort by masih kurang ini aplikasi sederhana tapi ini adalah aplikasi pertama by yang by kerjakan sebagai seorang developer dan sangat semangatt tauuuuuuu kerjaiinnyaaa, terimaksih telah menggunakan aplikasi ini\n\n-salam cinta, wopyuuuuuuu  ',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Tutup',
                                      style: GoogleFonts.poppins(
                                          color: purple500)),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: blue100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.info_outline,
                                    color: blue600, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About Developer',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: teal900,
                                      ),
                                    ),
                                    Text(
                                      'Versi 1.0.0',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: teal600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: gray400),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Logout Button
                  GestureDetector(
                    onTap: () async {
                      final appState = context.read<AppState>();
                      await appState.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const main.LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: red100,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: red600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: red600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
