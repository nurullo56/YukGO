import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/features/driver/models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        top: false, // Header rangini status bar bilan birlashtirish uchun
        child: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildMiniMap(),
                      _buildContent(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildActionButtons(context),
        ],
        ),
      ),
    );
  }

  // Header qismi
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 24, right: 24, bottom: 20),
      color: context.cardColor,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: context.inputColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.chevron_left, color: context.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Buyurtma tafsilotlari", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("ID: #${order.id}", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // Mini Map (Xarita)
  Widget _buildMiniMap() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[200],
      child: Stack(
        children: [
          Image.network(
            order.mapUrl ?? "https://yukchi.app/api/image-search?query=city-map-route-line&w=600&h=400&seed=88",
            fit: BoxFit.cover, 
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.map_outlined, size: 50, color: Colors.grey),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
            },
          ),
          Positioned(
            top: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
              child: Text("${order.distance} km", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // Asosiy kontent
  Widget _buildContent(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Yuk beruvchi info
            _buildCard(context,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.person, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("YUK BERUVCHI", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text("Bog'lanish"),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFEAF2FF),
                      foregroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Manzillar
            _buildCard(context,
              child: Column(
                children: [
                  _addressRow(Icons.circle, "Olish (Pickup)", order.pickupAddress, AppTheme.primary),
                  const Padding(
                    padding: EdgeInsets.only(left: 11),
                    child: SizedBox(height: 20, child: VerticalDivider(thickness: 2, color: Color(0xFFE2E8F0))),
                  ),
                  _addressRow(Icons.location_on, "Yetkazish (Drop-off)", order.dropoffAddress, Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Yuk haqida (Grid)
            _buildCard(context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("YUK HAQIDA MA'LUMOT", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _gridItem(Icons.inventory_2_outlined, "Turi", order.cargoType),
                      _gridItem(Icons.monitor_weight_outlined, "Vazni", order.weight),
                      _gridItem(Icons.aspect_ratio, "Hajmi", order.volume),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Izoh
            _buildCard(context,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.sticky_note_2_outlined, color: Colors.orange.shade700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("IZOH", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text(
                          "\"${order.comment}\"",
                          style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: child,
    );
  }

  Widget _addressRow(IconData icon, String label, String address, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gridItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: context.cardColor,
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: const Size(0, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.red.shade100, width: 2)),
              ),
              child: const Text("Rad etish", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10, shadowColor: AppTheme.primary.withOpacity(0.4),
              ),
              child: const Text("Qabul qilish", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}