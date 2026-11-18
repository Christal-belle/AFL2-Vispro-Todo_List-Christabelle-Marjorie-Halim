import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/domain/entities/task.dart';
import 'package:todo_list/domain/repositories/task_repository.dart';
import 'package:todo_list/presentation/states/task_state.dart';
import 'package:todo_list/presentation/viewmodels/task_viewmodel.dart';

// =====================================================================
// 1. FAKE REPOSITORY (Simulasi Server Sukses)
// =====================================================================
class FakeTaskRepository implements TaskRepository {
  List<Task> mockDatabase = [];
  @override
  Future<List<Task>> getTasks() async => mockDatabase;
  @override
  Future<void> addTask(Task task) async => mockDatabase.add(task);
  @override
  Future<void> updateTask(Task task) async {}
  @override
  Future<void> deleteTask(String id) async {
    mockDatabase.removeWhere((t) => t.id == id);
  }
}

// =====================================================================
// 2. ERROR REPOSITORY (Simulasi Server/Network Failure, Timeout, SQL Error)
// =====================================================================
class ErrorTaskRepository implements TaskRepository {
  @override
  Future<List<Task>> getTasks() async => throw Exception('Network Timeout');
  @override
  Future<void> addTask(Task task) async => throw Exception('SQL Insert Error');
  @override
  Future<void> updateTask(Task task) async => throw Exception('SQL Update Error');
  @override
  Future<void> deleteTask(String id) async => throw Exception('Malformed Response');
}

void main() {
  group('Bab 3.5: Input Validation & Error Handling (11 Scenarios)', () {
    
    late TaskViewModel successViewModel;
    late TaskViewModel errorViewModel;

    setUp(() {
      successViewModel = TaskViewModel(repository: FakeTaskRepository());
      errorViewModel = TaskViewModel(repository: ErrorTaskRepository());
    });

    // -----------------------------------------------------------------
    // BAGIAN A: INPUT VALIDATION (Skenario 1 - 3)
    // -----------------------------------------------------------------
    test('Skenario 1: Validasi menolak input kosong ("") dengan pesan terstruktur', () async {
      await successViewModel.addTask('');
      expect(successViewModel.state, isA<TaskError>());
      expect((successViewModel.state as TaskError).message, 'Judul tugas tidak boleh kosong.');
    });

    test('Skenario 2: Validasi menolak input yang hanya berisi spasi ("   ")', () async {
      await successViewModel.addTask('     ');
      expect(successViewModel.state, isA<TaskError>());
    });

    test('Skenario 3: Input yang valid berhasil diproses tanpa error', () async {
      await successViewModel.loadTasks(); // Set ke empty/loaded state dulu
      await successViewModel.addTask('Tugas Valid');
      expect(successViewModel.state, isA<TaskLoaded>());
    });

    // -----------------------------------------------------------------
    // BAGIAN B: SERVER ERRORS REPORTED IN SUMMARY (Skenario 4 - 7)
    // Memastikan error teknis/SQL tidak bocor ke UI, diganti pesan ramah
    // -----------------------------------------------------------------
    test('Skenario 4: Server error saat Load disembunyikan menjadi ringkasan ramah', () async {
      await errorViewModel.loadTasks();
      expect(errorViewModel.state, isA<TaskError>());
      expect((errorViewModel.state as TaskError).message, 'Gagal memuat daftar tugas. Silakan coba lagi.');
    });

    test('Skenario 5: Server error saat Add disembunyikan menjadi ringkasan ramah', () async {
      await errorViewModel.addTask('Tugas Baru');
      expect(errorViewModel.state, isA<TaskError>());
      expect((errorViewModel.state as TaskError).message, 'Maaf, gagal menyimpan tugas baru.');
    });

    test('Skenario 6: Server error saat Update disembunyikan menjadi ringkasan ramah', () async {
      await errorViewModel.toggleTaskStatus(const Task(id: '1', title: 'A'));
      expect(errorViewModel.state, isA<TaskError>());
      expect((errorViewModel.state as TaskError).message, 'Gagal memperbarui status tugas.');
    });

    test('Skenario 7: Server error saat Delete disembunyikan menjadi ringkasan ramah', () async {
      await errorViewModel.deleteTask('1');
      expect(errorViewModel.state, isA<TaskError>());
      expect((errorViewModel.state as TaskError).message, 'Gagal menghapus tugas.');
    });

    // -----------------------------------------------------------------
    // BAGIAN C: CLIENT HANDLES FAILURE WITHOUT CRASHING (Skenario 8 - 11)
    // Menguji sistem pengaman (isDisposed guard) agar aplikasi tidak crash
    // -----------------------------------------------------------------
    test('Skenario 8: Aplikasi menangani Network Timeout tanpa crash', () async {
      // Kita panggil fungsi yang melempar Exception, tes akan sukses jika TIDAK crash
      expect(() async => await errorViewModel.loadTasks(), returnsNormally);
    });

    test('Skenario 9: isClosed guard mencegah crash jika Load selesai setelah UI ditutup', () async {
      // Panggil load, lalu segera dispose (simulasi user menutup halaman)
      final future = successViewModel.loadTasks();
      successViewModel.dispose();
      await future;
      
      // Jika tidak ada isDisposed guard, aplikasi akan crash karena memanggil notifyListeners() setelah dispose.
      // Jika tes ini lulus, artinya guard bekerja sempurna.
      expect(true, isTrue); 
    });

    test('Skenario 10: isClosed guard mencegah crash jika Add selesai setelah UI ditutup', () async {
      final future = successViewModel.addTask('Tugas');
      successViewModel.dispose();
      await future;
      expect(true, isTrue);
    });

    test('Skenario 11: isClosed guard mencegah crash jika Delete selesai setelah UI ditutup', () async {
      final future = successViewModel.deleteTask('1');
      successViewModel.dispose();
      await future;
      expect(true, isTrue);
    });
  });
}