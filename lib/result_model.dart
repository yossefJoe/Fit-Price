class ResultModel {
  final String title;
  final String link;
  final String snippet;
  final String? imageUrl; // موجود فقط للبحث بالصور
  final String? thumbnailUrl;
  final String? source;

  ResultModel({
    required this.title,
    required this.link,
    this.snippet = '',
    this.imageUrl,
    this.thumbnailUrl,
    this.source,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      title: json['title'] ?? 'غير متوفر',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? '',
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      source: json['source'],
    );
  }
}
