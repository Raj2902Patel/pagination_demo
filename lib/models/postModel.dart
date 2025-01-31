class PostModel {
  final int id;
  final String name;
  final String email;

  PostModel({required this.id, required this.name, required this.email});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
