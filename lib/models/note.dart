import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  late String uuid;
  @HiveField(1)
  String title;
  @HiveField(2)
  List<NoteContent> content;
  @HiveField(3)
  String color;
  @HiveField(4)
  bool pinned;
  @HiveField(5)
  DateTime createdAt;
  @HiveField(6)
  DateTime updatedAt;

  Note({
    required this.uuid,
    required this.title,
    required this.content,
    this.color = '0xFFE5E5E5',
    this.pinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? uuid,
    String? title,
    List<NoteContent>? content,
    String? color,
    bool? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Factory constructor to create Note From Json
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      uuid: json['uuid'] ?? const Uuid().v4(),
      title: json['title'] ?? '',
      content: (json['content'] as List<dynamic>)
          .map((e) => NoteContent.fromJson(e))
          .toList(),
      color: json['color'] ?? '0xFFE5E5E5',
      pinned: json['pinned'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']) ?? DateTime.now(),
    );
  }

  // Convert Note to Json
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
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
    final now = DateTime.now();
    return Note(
      uuid: const Uuid().v4(),
      title: '',
      content: [],
      color: '0xFFE5E5E5',
      pinned: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}

// Representation one element in note content (text or checkbox or image)
@HiveType(typeId: 1)
class NoteContent {
  @HiveField(0)
  final String? type;
  @HiveField(1)
  String? value; // for text
  @HiveField(2)
  String? label; // for checkbox
  @HiveField(3)
  bool? checked; // for checkbox
  @HiveField(4)
  String? url; // for image

  NoteContent({this.type, this.value, this.label, this.checked, this.url});

  // Factory constructor to create NoteContent From Json
  factory NoteContent.fromJson(Map<String, dynamic> json) {
    return NoteContent(
      type: json['type'] ?? 'text',
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
