import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/core/widgets/app_bottom_nav.dart';
import 'package:yukgo_flutter/features/shipper/screens/active_order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  List<Map<String, dynamic>> _active = [];
  List<Map<String, dynamic>> _done = [];
  List<Map<String, dynamic>> _cancelled = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final orders = (await ApiService.getMyOrders()).cast<Map<String, dynamic>>();
      setState(() {
        _active    = orders.where((o) => !['delivered', 'cancelled'].contains(o['status'])).toList();
        _done      = orders.where((o) => o['status'] == 'delivered').toList();
        _cancelled = orders.where((o) => o['status'] == 'cancelled').toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Buyurtmalarni yuklashda xato';
        _loading = false;
      });
    }
  }

  // Status → matn
  static String _statusText(String s) => const {
    'pending':    "Kutilmoqda",
    'accepted':   "Qabul qilindi",
    'in_transit': "Yo'lda",
    'delivered':  "Yetkazildi",
    'cancelled':  "Bekor qilindi",
  }[s] ?? s;

  // Status → rang
  static Color _statusColor(String s) => const {
    'pending':    AppTheme.primary,
    'accepted':   Color(0xFFF59E0B),
    'in_transit': AppTheme.primary,
    'delivered':  Color(0xFF10B981),
    'cancelled':  Color(0xFFEF4444),
  }[s] ?? AppTheme.primary;

  // Status → icon
  static IconData _statusIcon(String s) => {
    'pending':    Icons.hourglass_empty,
    'accepted':   Icons.inventory_2,
    'in_transit': Icons.local_shipping,
    'delivered':  Icons.check_circle,
    'cancelled':  Icons.cancel,
  }[s] ?? Icons.circle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Buyurtmalarim", style: GoogleFonts.inter(
                      fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("${_active.length} faol",
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: context.inputColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: context.textMuted,
                labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Faol'),
                  Tab(text: 'Tugallangan'),
                  Tab(text: 'Bekor'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : _error != null
                      ? _buildError()
                      : TabBarView(
                          controller: _tabs,
                          children: [
                            _buildList(_active,    emptyText: "Faol buyurtma yo'q"),
                            _buildList(_done,      emptyText: "Tugallangan buyurtma yo'q"),
                            _buildList(_cancelled, emptyText: "Bekor qilingan buyurtma yo'q"),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.cloud_off_outlined, size: 60, color: context.textMuted),
        const SizedBox(height: 12),
        Text(_error!, style: GoogleFonts.inter(color: context.textMuted)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text("Qayta urinish"),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
        ),
      ]),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> orders, {required String emptyText}) {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.primary,
      child: orders.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.inbox_outlined, size: 64, color: context.textMuted),
                      const SizedBox(height: 12),
                      Text(emptyText, style: GoogleFonts.inter(fontSize: 15, color: context.textMuted)),
                    ]),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OrderCard(
                order: orders[i],
                statusText:  _statusText(orders[i]['status'] ?? ''),
                statusColor: _statusColor(orders[i]['status'] ?? ''),
                statusIcon:  _statusIcon(orders[i]['status'] ?? ''),
                counterpartName: _counterpartName(orders[i]),
                counterpartRole: _counterpartRole(),
                counterpartPhone: _counterpartPhone(orders[i]),
                onTap: () => _openDetail(orders[i]),
              ),
            ),
    );
  }

  String _counterpartName(Map<String, dynamic> order) {
    final Map<String, dynamic>? person = UserSession.isYukchi
        ? (order['furachi'] as Map<String, dynamic>?)
        : (order['yukchi'] as Map<String, dynamic>?);
    if (person == null) return '';
    final fn = person['first_name'] ?? '';
    final ln = person['last_name'] ?? '';
    return '$fn $ln'.trim();
  }

  String _counterpartRole() => UserSession.isYukchi ? 'Furachi' : 'Yukchi';

  String _counterpartPhone(Map<String, dynamic> order) {
    final Map<String, dynamic>? person = UserSession.isYukchi
        ? (order['furachi'] as Map<String, dynamic>?)
        : (order['yukchi'] as Map<String, dynamic>?);
    return person?['phone'] ?? '';
  }

  void _openDetail(Map<String, dynamic> order) {
    final status = order['status'] as String? ?? 'pending';
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ActiveOrderDetailScreen(
        orderId: order['id'].toString(),
        from: order['from_city'] ?? '',
        to: order['to_city'] ?? '',
        status: _statusText(status),
        statusColor: _statusColor(status),
        statusIcon: _statusIcon(status),
        weight: order['weight_kg'] != null ? '${order['weight_kg']} kg' : '—',
        price: order['price'] != null ? '${order['price']} so\'m' : '—',
        date: (order['created_at'] as String?)?.substring(0, 10) ?? '',
        counterpartName: _counterpartName(order),
        counterpartRole: _counterpartRole(),
        counterpartPhone: _counterpartPhone(order),
      ),
    ));
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String statusText;
  final Color statusColor;
  final IconData statusIcon;
  final String counterpartName;
  final String counterpartRole;
  final String counterpartPhone;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
    required this.counterpartName,
    required this.counterpartRole,
    required this.counterpartPhone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final from   = order['from_city'] ?? '';
    final to     = order['to_city'] ?? '';
    final weight = order['weight_kg'] != null ? '${order['weight_kg']} kg' : '';
    final price  = order['price'];
    final date   = (order['created_at'] as String?)?.substring(0, 10) ?? '';
    final id     = order['id']?.toString() ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID + status
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('#YK-$id', style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700, color: context.textMuted)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(statusText, style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                ]),
              ),
            ]),
            const SizedBox(height: 14),

            // Yo'nalish
            Row(children: [
              _dot(AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(from, style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary))),
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Container(width: 2, height: 16, color: context.borderColor),
            ),
            Row(children: [
              _dot(Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(to, style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary))),
            ]),
            const SizedBox(height: 14),

            // Info + counterpart
            Row(children: [
              if (weight.isNotEmpty) _chip(context, Icons.scale_outlined, weight),
              if (weight.isNotEmpty) const SizedBox(width: 8),
              if (date.isNotEmpty) _chip(context, Icons.calendar_today_outlined, date),
              const Spacer(),
              if (price != null && price.toString().isNotEmpty)
                Text('$price so\'m', style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            ]),

            // Furachi/Yukchi ismi (agar bor bo'lsa)
            if (counterpartName.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Icon(Icons.person_outline, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text('$counterpartRole: $counterpartName',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                  const Spacer(),
                  Icon(Icons.chat_bubble_outline, size: 13, color: AppTheme.primary),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _chip(BuildContext context, IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: context.inputColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(children: [
      Icon(icon, size: 12, color: context.textMuted),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: context.textMuted, fontWeight: FontWeight.w600)),
    ]),
  );
}
