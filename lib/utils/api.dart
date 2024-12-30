class ApiConfig {
  static const String baseUrl = "http://localhost:5000/api";

  static Uri buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    if (queryParams != null) {
      return Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);
    }
    return Uri.parse('$baseUrl/$endpoint');
  }
}
