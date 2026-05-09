/// Quote Model - represents a motivational quote from the Quotable API
class QuoteModel {
  final String content;
  final String author;

  QuoteModel({
    required this.content,
    required this.author,
  });

  /// Creates a QuoteModel from a JSON response map
  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      content: json['content'] ?? '',
      author: json['author'] ?? 'Unknown',
    );
  }
}
