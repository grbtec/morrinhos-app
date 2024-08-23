// ignore:public_member_api_docs
class ValidationErrors {
  // ignore:public_member_api_docs
  final Map<String, List<String>> errors;

  const ValidationErrors._raw({
    required this.errors,
  });

  // ignore:public_member_api_docs
  factory ValidationErrors.fromJson(Map<String, Object?> json) {
    return ValidationErrors._raw(
      errors: (json["errors"]! as Map<String, Object?>).map(
        (key, value) => MapEntry(key, (value! as List).cast()),
      ),
    );
  }

  @override
  String toString() {
    return errors.entries.map((e) => "${e.key}: ${e.value.join()}").join("\n");
  }
}
