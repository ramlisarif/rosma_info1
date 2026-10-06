class PedagangModel {
  final String id;
  final String nama;
  final double latitude;
  final double longitude;
  final String? deskripsi;
  final String? kategori;
  final String? foto; // Variabel foto disisipkan kembali

  PedagangModel({
    required this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
    this.deskripsi,
    this.kategori,
    this.foto,
  });

  factory PedagangModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Pengecekan aman untuk nama agar tidak muncul 'Pedagang Tanpa Nama'
    String namaPedagang = data['nama'] ??
        data['nama '] ??
        data['Nama'] ??
        data['nama_pedagang'] ??
        data['title'] ??
        '';

    return PedagangModel(
      id: id,
      nama: namaPedagang.toString().trim(),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      deskripsi: data['deskripsi'] ?? data['description'],
      kategori: data['kategori'] ?? data['category'],
      foto: data['foto'] ?? data['image'] ?? data['gambar'], // Membaca field foto dari Firestore
    );
  }
}