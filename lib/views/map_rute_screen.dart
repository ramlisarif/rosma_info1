import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pedagang_model.dart';

class MapRuteScreen extends StatelessWidget {
  final PedagangModel pedagang;
  final Position? userPosition;

  const MapRuteScreen({
    super.key,
    required this.pedagang,
    this.userPosition,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng pedagangLatLng = pedagang.latLng;
    // Jika GPS tidak aktif/null, gunakan default Pasar Gamalama Ternate
    final LatLng userLatLng = userPosition != null
        ? LatLng(userPosition!.latitude, userPosition!.longitude)
        : const LatLng(0.7881, 127.3879);

    return Scaffold(
      appBar: AppBar(
        title: Text(pedagang.nama),
      ),
      body: Column(
        children: [
          // Informasi Pedagang
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedagang.nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Kategori: ${pedagang.kategori}'),
                Text('Deskripsi: ${pedagang.deskripsi}'),
              ],
            ),
          ),
          // Map OpenStreetMap
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: pedagangLatLng,
                initialZoom: 17.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.project_rosma_skom',
                ),
                // Layer Garis Rute (Polyline)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [userLatLng, pedagangLatLng],
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
                // Layer Marker
                MarkerLayer(
                  markers: [
                    // Marker Pedagang
                    Marker(
                      point: pedagangLatLng,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.store,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    // Marker Lokasi Pengguna
                    Marker(
                      point: userLatLng,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 32,
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
}