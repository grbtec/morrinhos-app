class MyConfig {
  static MyConfig instance = MyConfig(
    api: ApiConfig(
      baseUriTemplate: "https://{tenant_slug}.city-guide-api.grbtec.com.br",
      caretVersion: "^1.0",
    ),
    auth: AuthConfig(
      clientId: "city-guide-mobile",
      baseUri: Uri.parse("NO_URL"),
    ),
  );
  final ApiConfig api;
  final AuthConfig auth;

  MyConfig({
    required this.api,
    required this.auth,
  });

  Map<String, Object?> toJson() => {
        "api": api.toJson(),
        "auth": auth.toJson(),
      };
}

class ApiConfig {
  final String baseUriTemplate;
  final String caretVersion;

  ApiConfig({
    required this.baseUriTemplate,
    required this.caretVersion,
  });

  Uri getBaseUri(String tenantSlug) =>
      Uri.parse(baseUriTemplate.replaceFirst("{tenant_slug}", tenantSlug));

  Map<String, Object?> toJson() => {
        "baseUriTemplate": baseUriTemplate.toString(),
      };
}

class AuthConfig {
  final String clientId;
  final Uri baseUri;

  const AuthConfig({
    required this.clientId,
    required this.baseUri,
  });

  Map<String, Object?> toJson() => {
        "clientId": clientId,
        "serverBaseUrl": baseUri,
      };
}
