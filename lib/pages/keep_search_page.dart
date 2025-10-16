import 'package:flutter/material.dart';
import 'package:note_keep/models/note.dart';
import 'package:note_keep/services/hive_service.dart';

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
      return n.title.toLowerCase().contains(query) ||
          n.content
              .map((c) => c.value)
              .join('\n')
              .toLowerCase()
              .contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // lembut abu keputihan
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
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(int.parse(note.color)),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/editor',
                          arguments: {'isEdit': true, 'note': note},
                        ).then((_) {
                          _refreshNotes();
                        });
                      },

                      title: RichText(
                        text: highlightText(note.title, query, true),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: RichText(
                          text: highlightText(
                            note.content.map((c) => c.value).join('\n'),
                            query,
                            false,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  TextSpan highlightText(String source, String query, bool isBold) {
    if (query.isEmpty) {
      return TextSpan(
        text: source,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    final lowerSource = source.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final matches = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerSource.indexOf(lowerQuery, start);
      if (index < 0) {
        // tidak ada lagi yang cocok
        matches.add(
          TextSpan(
            text: source.substring(start),
            style: TextStyle(
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
        break;
      }

      // teks sebelum highlight
      if (index > start) {
        matches.add(
          TextSpan(
            text: source.substring(start, index),
            style: TextStyle(
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }

      // bagian highlight
      matches.add(
        TextSpan(
          text: source.substring(index, index + query.length),
          style: TextStyle(
            color: Colors.amber,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );

      start = index + query.length;
    }

    return TextSpan(children: matches);
  }
}
