import 'package:flutter/material.dart';
import 'package:note_keep/models/note.dart';
import 'package:note_keep/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final hive = HiveService();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  Note? note;
  bool isDeleted = false;
  late bool isEdit;
  String selectedColor = '0xFFFFFFFF'; // Default white
  bool isPinned = false;
  bool _isDataInitialized = false;

  // Google Keep color palette
  final List<Map<String, dynamic>> colorPalette = [
    {'name': 'Default', 'hex': '0xFFFFFFFF'},
    {'name': 'Red', 'hex': '0xFFF28B82'},
    {'name': 'Orange', 'hex': '0xFFFBBC04'},
    {'name': 'Yellow', 'hex': '0xFFFFF475'},
    {'name': 'Green', 'hex': '0xFFCCFF90'},
    {'name': 'Teal', 'hex': '0xFFA7FFEB'},
    {'name': 'Blue', 'hex': '0xFFCBF0F8'},
    {'name': 'Dark Blue', 'hex': '0xFFAECBFA'},
    {'name': 'Purple', 'hex': '0xFFD7AEFB'},
    {'name': 'Pink', 'hex': '0xFFFDCFE8'},
    {'name': 'Brown', 'hex': '0xFFE6C9A8'},
    {'name': 'Gray', 'hex': '0xFFE8EAED'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hanya jalankan inisialisasi data JIKA belum pernah dilakukan
    if (!_isDataInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      isEdit = args['isEdit'] as bool;
      note = args['note'];

      if (isEdit && note != null) {
        titleController.text = note!.title;
        // Ambil warna dari note HANYA saat inisialisasi
        selectedColor = note!.color;
        isPinned = note!.pinned;

        // Extract text content...
        final textContents = note!.content
            .where((c) => c.type == 'text' && c.value != null)
            .map((c) => c.value!)
            .join('\n');
        contentController.text = textContents;
      }

      // Setelah inisialisasi selesai, set flag ke true
      _isDataInitialized = true;
    }
  }

  void saveNote() {
    final now = DateTime.now();
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      return;
    }

    // Convert content to List<NoteContent>
    List<NoteContent> noteContents = [];
    if (content.isNotEmpty) {
      // Split by newlines and create separate NoteContent for each line
      final lines = content.split('\n');
      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          noteContents.add(NoteContent(type: 'text', value: line));
        }
      }
    }

    if (isEdit && note != null) {
      final updatedNote = note!.copyWith(
        title: title,
        content: noteContents,
        color: selectedColor,
        pinned: isPinned,
        updatedAt: now,
      );
      hive.update(updatedNote);
    } else {
      final newNote = Note(
        uuid: const Uuid().v4(),
        title: title,
        content: noteContents,
        color: selectedColor,
        pinned: isPinned,
        createdAt: now,
        updatedAt: now,
      );
      hive.add(newNote);
    }
  }

  void _showColorPicker() async {
    final selectedHex = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _parseHexColor(selectedColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colorPalette.map((color) {
                final isSelected = selectedColor == color['hex'];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, color['hex']);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _parseHexColor(color['hex']),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Color.fromARGB(255, 20, 11, 11),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    // Bagian PENTING: Lakukan setState HANYA di sini
    if (selectedHex != null) {
      // selectedColor kini diperbarui dengan warna baru
      setState(() {
        selectedColor = selectedHex;
      });
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _parseHexColor(selectedColor),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () {
                if (isEdit && note != null) {
                  isDeleted = true;
                  hive.delete(note!.uuid);
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.pop(context); // Go back to home
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Make a copy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement copy functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Send'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _parseHexColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '').replaceAll('0x', '');
    if (hexColor.length == 3) {
      hexColor = hexColor.split('').map((c) => '$c$c').join();
    }
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build ulang dengan warna: $selectedColor');
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (isDeleted) {
          } else {
            saveNote();
          }
        }
      },
      child: Scaffold(
        backgroundColor: _parseHexColor(selectedColor),
        appBar: AppBar(
          backgroundColor: _parseHexColor(selectedColor),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: () {
                setState(() {
                  isPinned = !isPinned;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Implement reminder functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              onPressed: () {
                // TODO: Implement archive functionality
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: contentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Note',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _parseHexColor(selectedColor),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined, size: 22),
                    onPressed: () {
                      // TODO: Add checkbox list
                    },
                    tooltip: 'Add checkbox',
                  ),
                  IconButton(
                    icon: const Icon(Icons.palette_outlined, size: 22),
                    onPressed: _showColorPicker,
                    tooltip: 'Change color',
                  ),
                  const Spacer(),
                  if (isEdit && note != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        'Edited ${_formatDate(note!.updatedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 22),
                    onPressed: _showMoreOptions,
                    tooltip: 'More',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
