class Note {
  String id;
  String title;
  List<NoteContent> content;
  String color;
  bool pinned;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.color = '0xFFE5E5E5',
    this.pinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create Note From Json
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'] ?? '',
      content: (json['content'] as List<dynamic>)
          .map((e) => NoteContent.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convert Note to Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content.map((e) => e.toJson()).toList(),
      'color': color,
      'pinned': pinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Utility: for new Empty Note
  factory Note.empty() {
    return Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// Representation one element in note content (text or checkbox or image)
class NoteContent {
  final String type;
  String? value; // for text
  String? label; // for checkbox
  bool? checked; // for checkbox
  String? url; // for image

  NoteContent({
    required this.type,
    this.value,
    this.label,
    this.checked,
    this.url,
  });

  // Factory constructor to create NoteContent From Json
  factory NoteContent.fromJson(Map<String, dynamic> json) {
    return NoteContent(
      type: json['type'],
      value: json['value'],
      label: json['label'],
      checked: json['checked'],
      url: json['url'],
    );
  }

  // Convert NoteContent to Json
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (value != null) 'value': value,
      if (label != null) 'label': label,
      if (checked != null) 'checked': checked,
      if (url != null) 'url': url,
    };
  }
}
