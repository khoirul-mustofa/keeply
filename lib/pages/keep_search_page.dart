import 'package:flutter/material.dart';
import 'package:keeply/models/note.dart';
import 'package:keeply/services/hive_service.dart';
import 'package:keeply/widgets/note_card_widget.dart';

class KeepSearchPage extends StatefulWidget {
  const KeepSearchPage({super.key});

  @override
  State<KeepSearchPage> createState() => _KeepSearchPageState();
}

class _KeepSearchPageState extends State<KeepSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notes = HiveService().getAll();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshNotes() {
    setState(() {
      notes = HiveService().getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.toLowerCase();
    final filteredNotes = notes.where((n) {
      // Search in title
      if (n.title.toLowerCase().contains(query)) return true;

      // Search in content (both text value and checkbox label)
      for (var content in n.content) {
        if (content.type == 'text' && content.value != null) {
          if (content.value!.toLowerCase().contains(query)) return true;
        } else if (content.type == 'checkbox' && content.label != null) {
          if (content.label!.toLowerCase().contains(query)) return true;
        }
      }

      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Hero(
              tag: 'search-bar',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          cursorColor: Colors.black87,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Cari catatan...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (_controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: filteredNotes.isEmpty
            ? Center(
                key: const ValueKey('empty'),
                child: Text(
                  query.isEmpty
                      ? 'Ketik untuk mencari catatan...'
                      : 'Tidak ditemukan hasil untuk “$query”',
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                key: const ValueKey('list'),
                padding: const EdgeInsets.all(12),
                itemCount: filteredNotes.length,
                itemBuilder: (context, i) {
                  final note = filteredNotes[i];
                  return NoteCardWidget(
                    note: note,
                    searchQuery: query,
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
                      // Optional: Add delete dialog here if needed
                    },
                  );
                },
              ),
      ),
    );
  }
}
