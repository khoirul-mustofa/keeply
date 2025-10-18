import 'package:flutter/material.dart';
import 'package:keeply/models/note.dart';

class NoteCardWidget extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String? searchQuery;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
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
                searchQuery != null && searchQuery!.isNotEmpty
                    ? RichText(
                        text: _highlightText(note.title, searchQuery!, true),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
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
              if (note.content.isNotEmpty)
                ..._buildContentPreview(note.content, searchQuery),
            ],
          ),
        ),
      ),
    );
  }

  // Build content preview for the card
  List<Widget> _buildContentPreview(
      List<NoteContent> contents, String? query) {
    List<Widget> widgets = [];
    int itemsToShow = 3; // Limit preview items

    for (int i = 0; i < contents.length && i < itemsToShow; i++) {
      final content = contents[i];

      if (content.type == 'text' && content.value != null) {
        widgets.add(
          query != null && query.isNotEmpty
              ? RichText(
                  text: _highlightText(content.value!, query, false),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
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
                child: query != null && query.isNotEmpty
                    ? RichText(
                        text: _highlightText(content.label!, query, false),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
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

  // Highlight matching text in search results
  TextSpan _highlightText(String source, String query, bool isBold) {
    if (query.isEmpty) {
      return TextSpan(
        text: source,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: isBold ? 16 : 14,
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
        matches.add(
          TextSpan(
            text: source.substring(start),
            style: TextStyle(
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        );
        break;
      }

      if (index > start) {
        matches.add(
          TextSpan(
            text: source.substring(start, index),
            style: TextStyle(
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        );
      }

      // Highlighted part
      matches.add(
        TextSpan(
          text: source.substring(index, index + query.length),
          style: TextStyle(
            color: Colors.amber,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      );

      start = index + query.length;
    }

    return TextSpan(children: matches);
  }
}
