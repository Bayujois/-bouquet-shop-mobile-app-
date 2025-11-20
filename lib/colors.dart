import 'package:flutter/material.dart';

// Primary Colors
const Color teal50 = Color(0xFFE0F2F1);
const Color teal100 = Color(0xFFB2DFDB);
const Color teal400 = Color(0xFF26A69A);
const Color teal500 = Color(0xFF009688);
const Color teal600 = Color(0xFF00897B);
const Color teal900 = Color(0xFF004D40);

// Purple Colors
const Color purple50 = Color(0xFFF3E5F5);
const Color purple100 = Color(0xFFE1BEE7);
const Color purple400 = Color(0xFFAB47BC);
const Color purple500 = Color(0xFF9C27B0);
const Color purple600 = Color(0xFF8E24AA);

// Green Colors
const Color green50 = Color(0xFFE8F5E8);
const Color green100 = Color(0xFFC8E6C9);
const Color green400 = Color(0xFF66BB6A);
const Color green600 = Color(0xFF43A047);

// Pink Colors
const Color pink400 = Color(0xFFEC407A);

// Red Colors
const Color red50 = Color(0xFFFFEBEE);
const Color red100 = Color(0xFFFFCDD2);
const Color red600 = Color(0xFFE53935);

// Blue Colors
const Color blue100 = Color(0xFFBBDEFB);
const Color blue600 = Color(0xFF1E88E5);

// Orange Colors
const Color orange50 = Color(0xFFFFF3E0);
const Color orange100 = Color(0xFFFFE0B2);
const Color orange600 = Color(0xFFFB8C00);

// Gray Colors
const Color gray50 = Color(0xFFFAFAFA);
const Color gray100 = Color(0xFFF5F5F5);
const Color gray400 = Color(0xFFBDBDBD);

// Gradients
const LinearGradient primaryGradient = LinearGradient(
  colors: [teal400, purple400],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Utility Functions
String formatRupiah(double amount) {
  final formatter = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  String value = amount.toStringAsFixed(0);
  return 'Rp ${value.replaceAllMapped(formatter, (m) => '${m[1]}.')}';
}

const LinearGradient backgroundGradient = LinearGradient(
  colors: [teal50, purple50],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
