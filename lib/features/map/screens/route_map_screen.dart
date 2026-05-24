import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';

class RouteMapScreen extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final String? cargoType;
  final String? driverName;

  const RouteMapScreen({
    super.key,
    required this.fromCity,
    required this.toCity,
    this.cargoType,
    this.driverName,
  });

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // O'zbekiston shaharlari koordinatalari
  static const _cities = {
    'Toshkent':    LatLng(41.2995, 69.2401),
    'Samarqand':   LatLng(39.6542, 66.9597),
    'Buxoro':      LatLng(39.7747, 64.4286),
    'Namangan':    LatLng(41.0011, 71.6726),
    'Andijon':     LatLng(40.7829, 72.3442),
    "Farg'ona":    LatLng(40.3842, 71.7843),
    'Qarshi':      LatLng(38.8600, 65.7889),
    'Nukus':       LatLng(42.4600, 59.6100),
    'Urganch':     LatLng(41.5500, 60.6333),
    'Termiz':      LatLng(37.2242, 67.2783),
    'Jizzax':      LatLng(40.1158, 67.8422),
    'Navoiy':      LatLng(40.0843, 65.3791),
    'Guliston':    LatLng(40.4897, 68.7842),
    'Sirdaryo':    LatLng(40.8333, 68.6667),
  };

  LatLng? _fromLatLng;
  LatLng? _toLatLng;

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  void _setupMap() {
    _fromLatLng = _cities[widget.fromCity];
    _toLatLng = _cities[widget.toCity];

    final markers = <Marker>{};
    final polylines = <Polyline>{};

    if (_fromLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('from'),
        position: _fromLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.fromCity, snippet: 'Yuklash joyi'),
      ));
    }

    if (_toLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('to'),
        position: _toLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.toCity, snippet: 'Yetkazish joyi'),
      ));
    }

    if (_fromLatLng != null && _toLatLng != null) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [_fromLatLng!, _toLatLng!],
        color: AppTheme.primary,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  LatLng get _centerLatLng {
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
    final lat = (_fromLatLng!.latitude - _toLatLng!.latitude).abs();
    final lng = (_fromLatLng!.longitude - _toLatLng!.longitude).abs();
    final dist = lat > lng ? lat : lng;
    if (dist < 1) return 9;
    if (dist < 3) return 7.5;
    return 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Yo\'nalish xaritasi',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: context.textPrimary)),
      ),
      body: Column(
        children: [
          // Route info card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: context.cardColor,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _cityChip(context, Icons.circle, widget.fromCity, const Color(0xFF29CC78)),
                      Container(width: 2, height: 16, color: context.borderColor, margin: const EdgeInsets.symmetric(vertical: 4)),
                      _cityChip(context, Icons.location_on, widget.toCity, Colors.red),
                    ],
                  ),
                ),
                if (widget.cargoType != null || widget.driverName != null) ...[
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.cargoType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(widget.cargoType!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                        ),
                      if (widget.driverName != null) ...[
                        const SizedBox(height: 4),
                        Text(widget.driverName!, style: GoogleFonts.inter(fontSize: 12, color: context.textMuted)),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Map
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _centerLatLng,
                zoom: _zoom,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cityChip(BuildContext context, IconData icon, String city, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(city, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary)),
      ],
    );
  }
}
