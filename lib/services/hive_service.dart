import 'package:hive/hive.dart';
import '../models/note.dart';

class HiveService {
  static const _noteBox = 'notes';
  static HiveService? _instance;
  Box<Note>? _box;

  factory HiveService() {
    _instance ??= HiveService._();
    return _instance!;
  }

  HiveService._();

  Future<void> init() async {
    _box = await Hive.openBox<Note>(_noteBox);
  }

  // Get all notes sorted by updatedAt
  List<Note> getAll() {
    final notes = _box?.values.toList() ?? [];
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  // Add new note
  Future<void> add(Note note) async {
    await _box?.put(note.uuid, note);
  }

  // Update note
  Future<void> update(Note note) async {
    await _box?.put(note.uuid, note);
  }

  // Delete note
  Future<void> delete(String uuid) async {
    try {
      await _box?.delete(uuid).then((value) {
        print('berhasil hapus');
      });
    } catch (e) {
      print('gagal hapus: $e');
    }
  }

  // Clear all
  Future<void> clear() async {
    await _box?.clear();
  }
}
