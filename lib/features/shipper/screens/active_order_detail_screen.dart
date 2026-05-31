import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/features/chat/screens/chat_screen.dart';

class ActiveOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String from;
  final String to;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final String weight;
  final String price;
  final String date;
  final String counterpartName;
  final String counterpartRole; // "Furachi" yoki "Yukchi"
  final String counterpartPhone;

  const ActiveOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.from,
    required this.to,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.weight,
    required this.price,
    required this.date,
    required this.counterpartName,
    required this.counterpartRole,
    this.counterpartPhone = '',
  });

  @override
  State<ActiveOrderDetailScreen> createState() => _ActiveOrderDetailScreenState();
}

class _ActiveOrderDetailScreenState extends State<ActiveOrderDetailScreen> {
  GoogleMapController? _mapController;

  static const _cities = {
    'Toshkent':  LatLng(41.2995, 69.2401),
    'Samarqand': LatLng(39.6542, 66.9597),
    'Buxoro':    LatLng(39.7747, 64.4286),
    'Namangan':  LatLng(41.0011, 71.6726),
    'Andijon':   LatLng(40.7829, 72.3442),
    "Farg'ona":  LatLng(40.3842, 71.7843),
    'Qarshi':    LatLng(38.8600, 65.7889),
    'Nukus':     LatLng(42.4600, 59.6100),
    'Urganch':   LatLng(41.5500, 60.6333),
    'Termiz':    LatLng(37.2242, 67.2783),
    'Jizzax':    LatLng(40.1158, 67.8422),
    'Navoiy':    LatLng(40.0843, 65.3791),
  };

  LatLng? get _fromLatLng => _cities[widget.from];
  LatLng? get _toLatLng   => _cities[widget.to];

  LatLng get _center {
    if (_fromLatLng != null && _toLatLng != null) {
      return LatLng(
        (_fromLatLng!.latitude + _toLatLng!.latitude) / 2,
        (_fromLatLng!.longitude + _toLatLng!.longitude) / 2,
      );
    }
    return _fromLatLng ?? _toLatLng ?? const LatLng(40.5, 66.0);
  }

  double get _zoom {
    if (_fromLatLng == null || _toLatLng == null) return 7;
    final d = ((_fromLatLng!.latitude - _toLatLng!.latitude).abs() +
               (_fromLatLng!.longitude - _toLatLng!.longitude).abs());
    if (d < 1) return 9.5;
    if (d < 3) return 7.5;
    return 6.5;
  }

  Set<Marker> get _markers {
    final m = <Marker>{};
    if (_fromLatLng != null) {
      m.add(Marker(
        markerId: const MarkerId('from'),
        position: _fromLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.from, snippet: 'Yuklash'),
      ));
    }
    if (_toLatLng != null) {
      m.add(Marker(
        markerId: const MarkerId('to'),
        position: _toLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.to, snippet: 'Yetkazish'),
      ));
    }
    return m;
  }

  Set<Polyline> get _polylines {
    if (_fromLatLng == null || _toLatLng == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_fromLatLng!, _toLatLng!],
        color: AppTheme.primary,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
  }

  void _openChat() {
    final otherName = widget.counterpartName.isNotEmpty
        ? widget.counterpartName
        : widget.counterpartRole;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatScreen(
        roomId: 'order_${widget.orderId}',
        otherName: otherName,
      ),
    ));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UserSession.darkMode.value;
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16, right: 16, bottom: 12,
            ),
            color: context.cardColor,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: context.inputColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back, color: context.textPrimary, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${widget.orderId}',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary)),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(widget.statusIcon, size: 12, color: widget.statusColor),
                        const SizedBox(width: 4),
                        Text(widget.status,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: widget.statusColor)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Google Map
          SizedBox(
            height: 220,
            child: GoogleMap(
              onMapCreated: (c) => _mapController = c,
              initialCameraPosition: CameraPosition(target: _center, zoom: _zoom),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),

          // Kontent
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Yo'nalish
                  _card(
                    isDark: isDark,
                    child: Column(
                      children: [
                        _routeRow(context, Icons.circle, widget.from, const Color(0xFF29CC78)),
                        Padding(
                          padding: const EdgeInsets.only(left: 11),
                          child: Container(width: 2, height: 18, color: context.borderColor),
                        ),
                        _routeRow(context, Icons.location_on, widget.to, Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Info chips
                  _card(
                    isDark: isDark,
                    child: Row(
                      children: [
                        _infoItem(context, Icons.scale_outlined, 'Og\'irlik', widget.weight),
                        _divider(),
                        _infoItem(context, Icons.calendar_today_outlined, 'Sana', widget.date),
                        _divider(),
                        _infoItem(context, Icons.payments_outlined, 'Narx',
                            '${widget.price} so\'m', color: AppTheme.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Raqib (furachi yoki yukchi)
                  _card(
                    isDark: isDark,
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              widget.counterpartName.isNotEmpty
                                  ? widget.counterpartName[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.inter(
                                  fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.counterpartRole.toUpperCase(),
                                  style: GoogleFonts.inter(
                                      fontSize: 10, fontWeight: FontWeight.w700, color: context.textMuted)),
                              const SizedBox(height: 2),
                              Text(
                                widget.counterpartName.isNotEmpty
                                    ? widget.counterpartName
                                    : 'Aniqlanmoqda...',
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary),
                              ),
                              if (widget.counterpartPhone.isNotEmpty)
                                Text(widget.counterpartPhone,
                                    style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
                            ],
                          ),
                        ),
                        // Chat tugmasi
                        GestureDetector(
                          onTap: _openChat,
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: context.cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
            ),
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _openChat,
                icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                label: Text('Chat - ${widget.counterpartRole} bilan',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151B2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: child,
    );
  }

  Widget _routeRow(BuildContext context, IconData icon, String city, Color color) {
    return Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 10),
      Text(city, style: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
    ]);
  }

  Widget _infoItem(BuildContext context, IconData icon, String label, String value, {Color? color}) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 18, color: color ?? context.textMuted),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: context.textMuted)),
        const SizedBox(height: 2),
        Text(value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: color ?? context.textPrimary)),
      ]),
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: const Color(0xFFE2E8F0));
}
