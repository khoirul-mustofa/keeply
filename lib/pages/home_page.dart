import 'package:flutter/material.dart';
import 'package:keeply/models/note.dart';
import 'package:keeply/services/hive_service.dart';
import 'package:keeply/widgets/home_app_bar_search_box_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  final hive = HiveService();

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
                  return GestureDetector(
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
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/editor',
                        arguments: {'isEdit': true, 'note': note},
                      ).then((_) {
                        _refreshNotes();
                      });
                    },
                    child: _buildNoteCard(note),
                  );
                },
              ),
      ),
    );
  }

  Card _buildNoteCard(Note note) {
    return Card(
      color: Color(int.parse(note.color)),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (note.title.isNotEmpty)
              Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (note.title.isNotEmpty && note.content.isNotEmpty)
              const SizedBox(height: 4),
            // Content preview
            if (note.content.isNotEmpty) ..._buildContentPreview(note.content),
          ],
        ),
      ),
    );
  }

  // Build content preview for the card
  List<Widget> _buildContentPreview(List<NoteContent> contents) {
    List<Widget> widgets = [];
    int itemsToShow = 3; // Limit preview items

    for (int i = 0; i < contents.length && i < itemsToShow; i++) {
      final content = contents[i];

      if (content.type == 'text' && content.value != null) {
        widgets.add(
          Text(
            content.value!,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
        if (i < contents.length - 1 && i < itemsToShow - 1) {
          widgets.add(const SizedBox(height: 4));
        }
      } else if (content.type == 'checkbox' && content.label != null) {
        widgets.add(
          Row(
            children: [
              Icon(
                content.checked == true
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  content.label!,
                  style: TextStyle(
                    fontSize: 14,
                    decoration: content.checked == true
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
        if (i < contents.length - 1 && i < itemsToShow - 1) {
          widgets.add(const SizedBox(height: 4));
        }
      }
    }

    // Show indicator if there are more items
    if (contents.length > itemsToShow) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '+ ${contents.length - itemsToShow} more',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return widgets;
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
