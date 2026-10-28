class NoteModel {
  String id;
  String title;
  String description;

  NoteModel({this.id = '', required this.title, required this.description});

  Map<String, dynamic> toMap() {
    return {'title': title, 'description': description};
  }

  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
