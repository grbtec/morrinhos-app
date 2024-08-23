// ignore:public_member_api_docs
typedef JsonObject = Map<String, Object?>;
// ignore:public_member_api_docs
typedef JsonList = List<Object?>;

/// Error interface
abstract class ConnectionError {
  // ignore:public_member_api_docs
  String get message;

  // ignore:public_member_api_docs
  bool get isNetworkError;
}

// ignore:public_member_api_docs
class HttpError implements ConnectionError {
  @override
  final String message;

  @override
  bool get isNetworkError => false;

  // ignore:public_member_api_docs
  final int status;

  // ignore:public_member_api_docs
  final String? additionalInfo;

  // ignore:public_member_api_docs
  const HttpError({required this.message, required this.status, this.additionalInfo});

  @override
  String toString() {
    return "[$status] $message ${additionalInfo ?? ""}";
  }
}

// ignore:public_member_api_docs
class NetworkError implements ConnectionError {
  @override
  final String message;

  @override
  bool get isNetworkError => true;

  // ignore:public_member_api_docs
  const NetworkError({this.message = "Sem conexão"});
}
