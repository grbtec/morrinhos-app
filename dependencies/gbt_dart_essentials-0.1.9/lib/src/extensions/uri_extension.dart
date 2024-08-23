// ignore:public_member_api_docs
extension GbtUriExtension on Uri {
  // ignore:public_member_api_docs
  Uri appendPathSegment(String pathSegment) {
    return replace(
      pathSegments: [
        ...pathSegments,
        pathSegment,
      ],
    );
  }

  // ignore:public_member_api_docs
  Uri appendPathSegments(List<String> pathSegments) {
    return replace(
      pathSegments: [
        ...this.pathSegments,
        ...pathSegments,
      ],
    );
  }

  // ignore:public_member_api_docs
  Uri appendPath(String path) {
    final tempUri = Uri(scheme: "http", host: "example.com", path: path);
    return replace(
      pathSegments: [
        ...pathSegments,
        ...tempUri.pathSegments,
      ],
    );
  }
}
