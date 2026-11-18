class StorageException implements Exception {
  final String message;

  const StorageException([
    this.message = 'Terjadi kesalahan pada penyimpanan lokal.',
  ]);

  @override
  String toString() => message;
}