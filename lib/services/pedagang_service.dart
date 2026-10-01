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

      // Pecah kata kunci berdasarkan spasi (misal: "pasa" dan "tingkat")
      List<String> queryWords = cleanQuery
          .split(' ')
          .where((w) => w.isNotEmpty)
          .toList();

      // Filter fleksibel: mengecek nama, kategori, dan deskripsi
      return allPedagang.where((pedagang) {
        final nama = pedagang.nama.toLowerCase();
        final kategori = pedagang.kategori.toLowerCase();
        final deskripsi = pedagang.deskripsi.toLowerCase();
        final combinedText = '$nama $kategori $deskripsi';

        // Cocok jika ada salah satu kata kunci yang sesuai
        return queryWords.any((word) => combinedText.contains(word));
      }).toList();
    } catch (e) {
      print("Error searchPedagang: $e");
      return [];
    }
  }
}
