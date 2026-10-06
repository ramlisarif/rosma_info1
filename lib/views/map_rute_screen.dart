import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/pedagang_model.dart';
import 'pencarian_screen.dart'; // Untuk extension toTitleCase()

class MapRuteScreen extends StatefulWidget {
  final PedagangModel pedagang;
  final Position? userPosition;

  const MapRuteScreen({
    super.key,
    required this.pedagang,
    this.userPosition,
  });

  @override
  State<MapRuteScreen> createState() => _MapRuteScreenState();
}

class _MapRuteScreenState extends State<MapRuteScreen> {
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = true;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  // Fungsi untuk mengambil titik-titik RUTE JALAN RAYA dari OSRM Routing API
  Future<void> _fetchRoute() async {
    if (widget.userPosition == null) {
      if (mounted) setState(() => _isLoadingRoute = false);
      return;
    }

    final startLat = widget.userPosition!.latitude;
    final startLng = widget.userPosition!.longitude;
    final endLat = widget.pedagang.latitude;
    final endLng = widget.pedagang.longitude;

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          List<LatLng> points = coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          if (mounted) {
            setState(() {
              _routePoints = points;
              _isLoadingRoute = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error mengambil rute jalan: $e');
    }

    // Cadangan jika jaringan bermasalah: hubungkan 2 titik langsung
    if (mounted) {
      setState(() {
        _routePoints = [
          LatLng(startLat, startLng),
          LatLng(endLat, endLng),
        ];
        _isLoadingRoute = false;
      });
    }
  }

  // Pencocokan Aset Gambar Lokal sesuai halaman pencarian
  String? _getImageAssetPath(String namaPedagang) {
    String name = namaPedagang.toLowerCase();

    if (name.contains('gamalama')) {
      return 'assets/pasargamalama.jpeg';
    } else if (name.contains('buah') || name.contains('barito')) {
      return 'assets/pasarbarito.jpeg';
    } else if (name.contains('tingkat')) {
      return 'assets/pasartingkat.jpeg';
    } else if (name.contains('makmur')) {
      return 'assets/makmur.jpeg';
    } else if (name.contains('giga')) {
      return 'assets/gigacom.jpeg';
    } else if (name.contains('garuda')) {
      return 'assets/garudaelok.jpeg';
    } else if (name.contains('higienis') || name.contains('higensi')) {
      return 'assets/pasarhigienis.jpeg';
    } else if (name.contains('depo')) {
      return 'assets/depomart.jpeg';
    } else if (name.contains('kota') || name.contains('pariwisata')) {
      return 'assets/pasarkota.jpeg';
    } else if (name.contains('batu') || name.contains('anugerah')) {
      return 'assets/tokobatu.jpeg';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pedagangLatLng =
        LatLng(widget.pedagang.latitude, widget.pedagang.longitude);
    final userLatLng = widget.userPosition != null
        ? LatLng(widget.userPosition!.latitude, widget.userPosition!.longitude)
        : null;

    final centerLatLng = userLatLng ?? pedagangLatLng;

    final displayName = widget.pedagang.nama.trim().isNotEmpty
        ? widget.pedagang.nama.toTitleCase()
        : 'Pedagang Tanpa Nama';

    final imageAsset = _getImageAssetPath(displayName);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Widget Peta OpenStreetMap
          FlutterMap(
            options: MapOptions(
              initialCenter: centerLatLng,
              initialZoom: 15.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.rosma_info2',
              ),

              // Polyline Rute Jalan Raya
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      color: Colors.blueAccent.shade700,
                    ),
                  ],
                ),

              // Marker Lokasi
              MarkerLayer(
                markers: [
                  // Marker Pedagang / Pasar
                  Marker(
                    point: pedagangLatLng,
                    width: 48,
                    height: 48,
                    child: _buildMarkerPedagang(
                      widget.pedagang.foto,
                      imageAsset,
                    ),
                  ),

                  // Marker Pengguna
                  if (userLatLng != null)
                    Marker(
                      point: userLatLng,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.blueAccent,
                        size: 32,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Indikator Loading Rute Jalan
          if (_isLoadingRoute && userLatLng != null)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Menghitung rute jalan...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Card Informasi Pedagang
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (widget.pedagang.kategori != null &&
                            widget.pedagang.kategori!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.pedagang.kategori!.toTitleCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (widget.pedagang.deskripsi != null &&
                        widget.pedagang.deskripsi!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.pedagang.deskripsi!.toTitleCase(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pendukung untuk Marker lokasi pedagang
  Widget _buildMarkerPedagang(String? urlFoto, String? assetPath) {
    Widget imageWidget;

    if (urlFoto != null && urlFoto.isNotEmpty) {
      imageWidget = Image.network(
        urlFoto,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultMarkerIcon(),
      );
    } else if (assetPath != null) {
      imageWidget = Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultMarkerIcon(),
      );
    } else {
      imageWidget = _defaultMarkerIcon();
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.teal.shade700, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  Widget _defaultMarkerIcon() {
    return Container(
      color: Colors.teal.shade700,
      child: const Icon(
        Icons.storefront_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}