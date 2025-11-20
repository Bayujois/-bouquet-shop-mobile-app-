// main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

import 'app_state.dart';
import 'database_helper.dart';
import 'forgot_password_and_main_screen.dart';

// ============= CONSTANTS & THEME =============
const Color teal50 = Color(0xFFF0FDFA);
const Color teal100 = Color(0xFFCCFBF1);
const Color teal400 = Color(0xFF5EEAD4);
const Color teal500 = Color(0xFF14B8A6);
const Color teal600 = Color(0xFF0D9488);
const Color teal900 = Color(0xFF134E4A);

const Color purple50 = Color(0xFFFAF5FF);
const Color purple100 = Color(0xFFF3E8FF);
const Color purple400 = Color(0xFFC084FC);
const Color purple500 = Color(0xFFA855F7);
const Color purple600 = Color(0xFF9333EA);

const Color pink50 = Color(0xFFFDF2F8);
const Color pink400 = Color(0xFFF472B6);

const Color green100 = Color(0xFFDCFCE7);
const Color green400 = Color(0xFF4ADE80);
const Color green600 = Color(0xFF16A34A);
const Color red100 = Color(0xFFFEE2E2);
const Color red600 = Color(0xFFDC2626);
const Color orange50 = Color(0xFFFFF7ED);
const Color orange600 = Color(0xFFEA580C);
const Color blue100 = Color(0xFFDBEAFE);
const Color blue600 = Color(0xFF2563EB);
const Color gray50 = Color(0xFFF9FAFB);
const Color gray100 = Color(0xFFF3F4F6);
const Color gray400 = Color(0xFF9CA3AF);

final Gradient primaryGradient = const LinearGradient(
  colors: [teal400, purple400],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

final Gradient backgroundGradient = const LinearGradient(
  colors: [purple50, teal50, pink50],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ============= MAIN APP =============
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  // Request notification permission on Android 13+ if not yet granted
  await NotificationService().requestAndroidPermissionIfNeeded();
  // One-time purge of legacy sample seed data (names like Rose Romance Bouquet, etc.)
  final prefs = await SharedPreferences.getInstance();
  final purgeDone = prefs.getBool('purge_done') ?? false;
  if (!purgeDone) {
    try {
      await DatabaseHelper().purgeSampleData();
      await prefs.setBool('purge_done', true);
    } catch (e) {
      // Ignore purge errors; continue app startup
    }
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..loadData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloom Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      // Clamp global text scale to avoid overflow on very large system font sizes
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaleFactor.clamp(0.85, 1.15);
        return MediaQuery(
          data: mq.copyWith(textScaleFactor: clamped),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // Check for auto-login
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final appState = context.read<AppState>();
    if (await appState.checkAutoLogin()) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final appState = context.read<AppState>();
    try {
      // AWAIT the async login operation!
      await appState.login(
        _emailController.text,
        _passwordController.text,
        remember: _rememberMe,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40), // Reduced from 60
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.local_florist,
                          size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16), // Reduced from 24
                    Text(
                      'Bloom Manager',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: teal900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your flower business',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: teal600,
                      ),
                    ),
                    const SizedBox(height: 32), // Reduced from 48
                    // Email
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
                          prefixIcon:
                              const Icon(Icons.mail_outline, color: teal600),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: teal100),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon:
                              const Icon(Icons.lock_outline, color: teal600),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Remember Me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                              activeColor: teal500,
                              side: BorderSide(color: teal100),
                            ),
                            Text(
                              'Remember me',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: teal600,
                              ),
                            ),
                          ],
                        ),
                        // Forgot Password
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen()));
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(color: purple500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    GestureDetector(
                      onTap: _login,
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
                            'Login',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Reduced from 24
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(color: teal600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen()));
                          },
                          child: Text(
                            'Register',
                            style: GoogleFonts.poppins(
                              color: purple500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Reduced from 32
                    // Offline Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: teal100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.storage, size: 16, color: teal500),
                          const SizedBox(width: 8),
                          Text(
                            'Offline Mode Available',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: teal600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============= REGISTER SCREEN =============
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  bool _passwordsMatch = false;

  void _validateName(String value) {
    setState(() {
      _nameError = value.isEmpty ? 'Name is required' : null;
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else if (!value.contains('@')) {
        _emailError = 'Invalid email format';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
      _checkPasswordMatch();
    });
  }

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _register() {
    _validateName(_nameController.text);
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    if (_nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _passwordsMatch) {
      _saveUserToDatabase();
    }
  }

  Future<void> _saveUserToDatabase() async {
    try {
      final dbHelper = DatabaseHelper();
      
      // Check if email already exists
      final emailExists = await dbHelper.emailExists(_emailController.text);
      if (!mounted) return;
      
      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already registered!')),
        );
        return;
      }
      
      // Register user in database
      await dbHelper.registerUser(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      
      if (!mounted) return;
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: teal900,
                      ),
                    ),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _nameController,
                        icon: Icons.person_outline,
                        hint: 'Full Name',
                        onChanged: _validateName,
                        error: _nameError,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        icon: Icons.mail_outline,
                        hint: 'Email',
                        onChanged: _validateEmail,
                        error: _emailError,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        hint: 'Password',
                        obscureText: true,
                        onChanged: _validatePassword,
                        error: _passwordError,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        icon: Icons.lock_outline,
                        hint: 'Confirm Password',
                        obscureText: true,
                        onChanged: (_) => _checkPasswordMatch(),
                      ),
                      if (_confirmPasswordController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                _passwordsMatch
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: _passwordsMatch ? green600 : red600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _passwordsMatch
                                    ? 'Passwords match'
                                    : 'Passwords do not match',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _passwordsMatch ? green600 : red600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: _register,
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
                              'Register',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.poppins(color: teal600),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Back to Login',
                              style: GoogleFonts.poppins(
                                color: purple500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Function(String)? onChanged,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: error != null ? red600 : teal100),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: teal600),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: red600),
                const SizedBox(width: 6),
                Text(
                  error,
                  style: GoogleFonts.poppins(fontSize: 12, color: red600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Continue in next part...
// Due to character limit, I'll provide the complete app in multiple artifacts
// Part 2 will include: ForgotPasswordScreen, MainScreen, DashboardScreen
