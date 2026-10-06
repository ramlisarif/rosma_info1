import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pedagang_model.dart';

class PedagangService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'pedagang',
  );

  // Mengaktifkan & Mengambil Lokasi GPS Pengguna
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  // Mengambil & Memfilter Data Pedagang dari Firebase
  Future<List<PedagangModel>> searchPedagang(String query) async {
    try {
      final snapshot = await _collection.get();

      // Ubah semua data Firestore ke objek PedagangModel
      List<PedagangModel> allPedagang = snapshot.docs.map((doc) {
        return PedagangModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Jika kolom pencarian kosong, tampilkan semua pedagang
      String cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) {
        return allPedagang;
      }

      // Pecah kata kunci berdasarkan spasi
      List<String> queryWords = cleanQuery
          .split(' ')
          .where((w) => w.isNotEmpty)
          .toList();

      // Filter HANYA berdasarkan field 'nama' pedagang
      return allPedagang.where((pedagang) {
        final nama = pedagang.nama.toLowerCase();

        // Cocok jika ada salah satu kata kunci yang ada di dalam nama pedagang
        return queryWords.any((word) => nama.contains(word));
      }).toList();
    } catch (e) {
      print("Error searchPedagang: $e");
      return [];
    }
  }
}
