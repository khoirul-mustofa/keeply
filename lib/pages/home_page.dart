import 'package:flutter/material.dart';
import 'package:keeply/models/note.dart';
import 'package:keeply/services/hive_service.dart';
import 'package:keeply/widgets/home_app_bar_search_box_widget.dart';
import 'package:keeply/widgets/note_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  final HiveService hive = HiveService();

  Future<void> _getNotes() async {
    notes.clear();
    notes = hive.getAll();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getNotes();
  }

  void _refreshNotes() {
    setState(() {
      _getNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/editor',
            arguments: {'isEdit': false},
          ).then((_) {
            _refreshNotes();
          });
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: HomeAppBarSearchBoxWidget(
          onTap: () {
            Navigator.pushNamed(context, '/search').then((_) {
              _refreshNotes();
            });
          },
        ),
      ),
      body: RefreshIndicator(
        color: Colors.black,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          _refreshNotes();
        },
        child: notes.isEmpty
            ? const Center(child: Text('Tidak ada catatan'))
            : ListView.builder(
                itemCount: notes.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteCardWidget(
                    note: note,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/editor',
                        arguments: {'isEdit': true, 'note': note},
                      ).then((_) {
                        _refreshNotes();
                      });
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text('Hapus catatan?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  hive.delete(note.uuid);
                                  Navigator.pop(ctx);
                                  _refreshNotes();
                                },
                                child: const Text('Hapus'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

// Color parseHexColor(String hexColor) {
//   // Hapus # atau 0x
//   hexColor = hexColor.replaceAll('#', '').replaceAll('0x', '');

//   // Kalau 3 digit (#RGB), expand jadi 6 digit
//   if (hexColor.length == 3) {
//     hexColor = hexColor.split('').map((c) => '$c$c').join();
//   }

//   // Tambahkan alpha FF di depan
//   if (hexColor.length == 6) {
//     hexColor = 'FF$hexColor';
//   }

//   return Color(int.parse(hexColor, radix: 16));
// }
