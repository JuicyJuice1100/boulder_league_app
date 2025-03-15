class BaseReturnObject {
  final bool success;
  final String? message;
  final dynamic data;

  BaseReturnObject({
    required this.success, 
    required this.message, 
    this.data
  });
}