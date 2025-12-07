class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['message'] != null &&
               (json['message'] as String).toLowerCase().contains('success'),
      message: json['message'] ?? '',
      data: json,
    );
  }
}