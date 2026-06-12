class NewsModel {
  final String title;
  final String url;
  final String imageUrl;
  final String date;
  final String description;

  NewsModel({
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.date,
    required this.description,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'imageUrl': imageUrl,
      'date': date,
      'description': description,
    };
  }
}
