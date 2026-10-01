import 'package:latlong2/latlong.dart';

class PedagangModel {
  final String id;
  final String nama;
  final String kategori;
  final String deskripsi;
  final double latitude;
  final double longitude;

  PedagangModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.latitude,
    required this.longitude,
  });

  // Konversi dari dokumen Firestore ke Object PedagangModel
  factory PedagangModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PedagangModel(
      id: id,
      nama: data['nama'] ?? '',
      kategori: data['kategori'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
    );
  }

  // Getter koordinat LatLng untuk FlutterMap
  LatLng get latLng => LatLng(latitude, longitude);
}