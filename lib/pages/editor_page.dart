import 'package:flutter/material.dart';
import 'package:keeply/models/note.dart';
import 'package:keeply/services/hive_service.dart';
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
  final FocusNode _contentFocusNode = FocusNode();

  Note? note;
  bool isDeleted = false;
  late bool isEdit;
  String selectedColor = '0xFFFFFFFF'; // Default white
  bool isPinned = false;
  bool _isDataInitialized = false;

  // Checkbox mode
  bool isCheckboxMode = false;
  List<CheckboxItem> checkboxItems = [];

  final List<Map<String, dynamic>> colorPalette = [
    {'name': 'Default', 'hex': '0xFFFFFFFF'}, // Putih bersih
    {'name': 'Rose', 'hex': '0xFFFFEBEE'}, // Pink muda lembut
    {'name': 'Blush', 'hex': '0xFFFFF0F5'}, // Pink pastel
    {'name': 'Peach', 'hex': '0xFFFFF3E0'}, // Oranye pastel
    {'name': 'Apricot', 'hex': '0xFFFFE0B2'}, // Peach creamy
    {'name': 'Lemon', 'hex': '0xFFFFF9C4'}, // Kuning lembut
    {'name': 'Butter', 'hex': '0xFFFFFDE7'}, // Kuning pucat
    {'name': 'Mint', 'hex': '0xFFE0F7FA'}, // Hijau kebiruan lembut
    {'name': 'Aqua', 'hex': '0xFFE1F5FE'}, // Biru muda segar
    {'name': 'Sky', 'hex': '0xFFB3E5FC'}, // Biru langit pastel
    {'name': 'Cerulean', 'hex': '0xFFBBDEFB'}, // Biru lembut natural
    {'name': 'Lilac', 'hex': '0xFFF3E5F5'}, // Ungu pastel muda
    {'name': 'Lavender', 'hex': '0xFFEDE7F6'}, // Ungu keabu-abuan
    {'name': 'Periwinkle', 'hex': '0xFFC5CAE9'}, // Ungu kebiruan lembut
    {'name': 'Mauve', 'hex': '0xFFF8BBD0'}, // Ungu pink pastel
    {'name': 'Sage', 'hex': '0xFFE8F5E9'}, // Hijau lembut alami
    {'name': 'Tea Green', 'hex': '0xFFD0F8CE'}, // Hijau pastel cerah
    {'name': 'Sand', 'hex': '0xFFFFF8E1'}, // Krem muda alami
    {'name': 'Latte', 'hex': '0xFFFFECB3'}, // Cokelat susu lembut
    {'name': 'Mist', 'hex': '0xFFE8EAF6'}, // Biru keabu lembut
    {'name': 'Ash', 'hex': '0xFFF5F5F5'}, // Abu netral
    {'name': 'Pebble', 'hex': '0xFFEEEEEE'}, // Abu terang lembut
    {'name': 'Cloud', 'hex': '0xFFE0E0E0'}, // Abu keperakan natural
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Focus after the widget is successfully rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentFocusNode.requestFocus();
    });
    if (!_isDataInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      isEdit = args['isEdit'] as bool;
      note = args['note'];

      if (isEdit && note != null) {
        titleController.text = note!.title;
        selectedColor = note!.color;
        isPinned = note!.pinned;

        // Check if note has checkboxes
        final hasCheckboxes = note!.content.any((c) => c.type == 'checkbox');

        if (hasCheckboxes) {
          isCheckboxMode = true;
          // Load checkbox items
          checkboxItems = note!.content
              .where((c) => c.type == 'checkbox')
              .map(
                (c) => CheckboxItem(
                  label: c.label ?? '',
                  checked: c.checked ?? false,
                ),
              )
              .toList();
        } else {
          // Load text content
          final textContents = note!.content
              .where((c) => c.type == 'text' && c.value != null)
              .map((c) => c.value!)
              .join('\n');
          contentController.text = textContents;
        }
      }
      _isDataInitialized = true;
    }
  }

  void saveNote() {
    final now = DateTime.now();
    final title = titleController.text.trim();
    List<NoteContent> noteContents = [];
    if (isCheckboxMode) {
      // Save checkbox items
      if (title.isEmpty && checkboxItems.isEmpty) {
        return;
      }

      for (var item in checkboxItems) {
        final label = item.controller.text.trim();
        if (label.isNotEmpty) {
          noteContents.add(
            NoteContent(type: 'checkbox', label: label, checked: item.checked),
          );
        }
      }
    } else {
      // Save text content
      final content = contentController.text.trim();
      if (title.isEmpty && content.isEmpty && note?.uuid != null) {
        hive.delete(note!.uuid);
        isDeleted = true;
      }
      if (title.isEmpty && content.isEmpty) {
        return;
      }

      if (content.isNotEmpty) {
        final lines = content.split('\n');
        for (var line in lines) {
          if (line.trim().isNotEmpty) {
            noteContents.add(NoteContent(type: 'text', value: line));
          }
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
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
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
                          color: isSelected
                              ? Colors.black
                              : Colors.grey.shade300,
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
      ),
    );
    if (selectedHex != null) {
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
            // ListTile(
            //   leading: const Icon(Icons.content_copy),
            //   title: const Text('Make a copy'),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.share),
            //   title: const Text('Send'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // TODO: Implement share functionality
            //   },
            // ),
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
    // Dispose all checkbox controllers
    for (var item in checkboxItems) {
      item.dispose();
    }
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // IconButton(
            //   icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            //   onPressed: () {
            //     setState(() {
            //       isPinned = !isPinned;
            //     });
            //   },
            // ),
            // IconButton(
            //   icon: const Icon(Icons.notifications_outlined),
            //   onPressed: () {
            //     // TODO: Implement reminder functionality
            //   },
            // ),
            // IconButton(
            //   icon: const Icon(Icons.archive_outlined),
            //   onPressed: () {
            //     // TODO: Implement archive functionality
            //   },
            // ),
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
                      // Show either text field or checkbox list
                      if (!isCheckboxMode)
                        TextField(
                          controller: contentController,
                          focusNode: _contentFocusNode,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Note',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                      else
                        ..._buildCheckboxList(),
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
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFFEFF3F5),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (context) => SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // _buildOption(
                                //   Icons.camera_alt_outlined,
                                //   'Ambil foto',
                                //   () {},
                                // ),
                                // _buildOption(
                                //   Icons.image_outlined,
                                //   'Tambahkan gambar',
                                //   () {},
                                // ),
                                // _buildOption(
                                //   Icons.brush_outlined,
                                //   'Gambar',
                                //   () {},
                                // ),
                                // _buildOption(
                                //   Icons.mic_none_outlined,
                                //   'Rekaman',
                                //   () {},
                                // ),
                                _buildOption(
                                  Icons.check_box_outlined,
                                  'Kotak Centang',
                                  () {
                                    Navigator.pop(context);
                                    setState(() {
                                      if (!isCheckboxMode) {
                                        isCheckboxMode = true;
                                        // Add first checkbox item
                                        if (checkboxItems.isEmpty) {
                                          checkboxItems.add(
                                            CheckboxItem(label: ''),
                                          );
                                        }
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
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

  List<Widget> _buildCheckboxList() {
    List<Widget> widgets = [];

    for (int i = 0; i < checkboxItems.length; i++) {
      final item = checkboxItems[i];
      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: item.checked,
              onChanged: (value) {
                setState(() {
                  item.checked = value ?? false;
                });
              },
              activeColor: Colors.black,
            ),
            Expanded(
              child: TextField(
                controller: item.controller,
                style: TextStyle(
                  fontSize: 16,
                  decoration: item.checked ? TextDecoration.lineThrough : null,
                ),
                decoration: const InputDecoration(
                  hintText: 'List item',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  item.label = value;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() {
                  item.dispose();
                  checkboxItems.removeAt(i);
                });
              },
            ),
          ],
        ),
      );
    }

    // Add "Add item" button
    widgets.add(
      TextButton.icon(
        onPressed: () {
          setState(() {
            checkboxItems.add(CheckboxItem(label: ''));
          });
        },
        icon: const Icon(Icons.add, size: 20),
        label: const Text('List item'),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );

    return widgets;
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
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

// Helper class for checkbox items
class CheckboxItem {
  String label;
  bool checked;
  final TextEditingController controller;

  CheckboxItem({required this.label, this.checked = false})
    : controller = TextEditingController(text: label);

  void dispose() {
    controller.dispose();
  }
}
