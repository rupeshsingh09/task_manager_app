import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

/// ApiService - handles REST API calls for motivational quotes
class ApiService {
  static const String _baseUrl = 'https://api.quotable.io/random';

  /// Fetches a random motivational quote from the Quotable API
  /// Returns a [QuoteModel] on success
  /// Throws an exception with a user-friendly message on failure
  Future<QuoteModel> fetchRandomQuote() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return QuoteModel.fromJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Failed to fetch quote (${response.statusCode}).');
      }
    } on http.ClientException {
      throw Exception('Network error. Check your internet connection.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
