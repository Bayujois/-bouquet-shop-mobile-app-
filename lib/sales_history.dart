import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'models.dart';
import 'colors.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  DateTimeRange? _range;
  List<Sale> _sales = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  Future<void> _load() async {
    if (_range == null) return;
    setState(() => _loading = true);
    final app = context.read<AppState>();
    final sales = await app.getSalesBetween(_range!.start, _range!.end);
    setState(() {
      _sales = sales;
      _loading = false;
    });
  }

  Future<void> _exportCsv() async {
    if (_range == null) return;
    final app = context.read<AppState>();
    final path = await app.generateSalesCsv(_range!.start, _range!.end);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV disimpan: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Penjualan', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        foregroundColor: teal600,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickRange,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: gray50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gray100),
                      ),
                      child: Text(
                        _range == null
                            ? 'Pilih Rentang Tanggal'
                            : '${_range!.start.toLocal().toString().substring(0, 10)} - ${_range!.end.toLocal().toString().substring(0, 10)}',
                        style: GoogleFonts.poppins(fontSize: 12, color: teal600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _load,
                  style: ElevatedButton.styleFrom(backgroundColor: teal500),
                  child: const Text('Terapkan'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _exportCsv,
                  child: const Text('Export CSV'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemBuilder: (c, i) {
                      final s = _sales[i];
                      return ListTile(
                        title: Text(s.productName, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        subtitle: Text('${s.quantity} x Rp ${s.price.round()}  •  ${s.soldAt}'),
                        trailing: Text('Rp ${s.total.round()}', style: GoogleFonts.poppins(color: purple600)),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _sales.length,
                  ),
          ),
        ],
      ),
    );
  }
}
