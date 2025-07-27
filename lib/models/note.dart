class Note {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []), // Safe casting for tags
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert Note to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'tags': tags,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // Optional: Copy method for immutable updates
  Note copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Note(id: $id, title: $title, isArchived: $isArchived)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
