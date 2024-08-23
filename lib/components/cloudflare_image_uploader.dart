import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:gbt_identity/user_credential.dart';
import 'package:http/http.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/auth/user_credential_provider.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:mobile/utils/exception_handler.dart';

class CloudflareImageUploader extends ConsumerStatefulWidget {
  final String? imageUrl;
  final void Function(String?) onChange;
  final String text;

  const CloudflareImageUploader({
    super.key,
    this.imageUrl,
    required this.onChange,
    this.text = "imagem",
  });

  @override
  ConsumerState<CloudflareImageUploader> createState() =>
      _CloudflareImageUploaderState();
}

class _CloudflareImageUploaderState
    extends ConsumerState<CloudflareImageUploader> {
  late final controller = CludflareImageUploadController(
    httpClient: ref.read(DefaultHttpClientProvider.instance),
    apiBaseUri: MyConfig.instance.api.getBaseUri(ref.tenantSlug),
    userCredential: ref.watch(userCredentialProvider).valueOrNull,
    text: widget.text,
  );

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(widget.imageUrl!),
          FluentButton(
            variant: FluentButtonVariant.outline,
            onPressed: () => widget.onChange(null),
            title: 'Remover ${widget.text}',
          ),
        ],
      );
    }
    return FluentButton(
      variant: FluentButtonVariant.outline,
      onPressed: () async {
        final uploadImageUrlFutureResult = controller.getUploadUrl();

        await FluentHeadsUpDisplayDialog(
          future: uploadImageUrlFutureResult,
          confirmStopMessage: "Deseja mesmo cancelar o envio?",
          hud: const FluentHeadsUpDisplay(
            text: "Obtendo url...",
          ),
        ).show(context);
        final uploadImageUrlResult = await uploadImageUrlFutureResult;

        if (uploadImageUrlResult is ErrorResult) {
          if (context.mounted) {
            FluentToast(
              text:
                  FluentText("Erro: ${uploadImageUrlResult.error.toString()}"),
              icon: const Icon(Icons.cancel),
            ).show(context: context);
          }
          return;
        }
        final uploadImageUrl = uploadImageUrlResult.asValue!.value;

        final file = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (file == null) {
          if (context.mounted) {
            FluentToast(
              text: FluentText("Cancelado"),
              icon: const Icon(Icons.cancel),
            ).show(context: context);
          }
          return;
        }
        final futureUploadResult =
            controller.uploadImage(uploadImageUrl, file.path);
        if (context.mounted) {
          await FluentHeadsUpDisplayDialog(
            future: futureUploadResult,
            confirmStopMessage: "Deseja mesmo cancelar o envio?",
            hud: const FluentHeadsUpDisplay(text: "Enviando..."),
          ).show(context);
        }
        final uploadResult = await futureUploadResult;
        switch (uploadResult) {
          case ErrorResult():
            if (context.mounted) {
              FluentToast(
                text: FluentText("Erro: ${uploadResult.error.toString()}"),
                icon: const Icon(Icons.error),
                toastColor: FluentToastColor.danger,
              ).show(context: context);
            }
            break;
          case ValueResult(value: final String imageUrl):
            widget.onChange(imageUrl);
            break;
        }
      },
      title: 'Enviar ${widget.text}',
    );
  }
}

class CludflareImageUploadController {
  final Client httpClient;
  final Uri apiBaseUri;
  final UserCredential? userCredential;
  final String text;

  CludflareImageUploadController({
    required this.httpClient,
    required this.apiBaseUri,
    required this.userCredential,
    required this.text,
  });

  Future<Result<Uri>> getUploadUrl() async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(
          path: "/cloudflare-images/generate-upload-url",
          queryParameters: {if (kDebugMode) "mock": "true"});
      final userTokens = await userCredential?.getValidUserTokens();
      final response = await httpClient.post(url, headers: {
        if (userTokens != null)
          "Authorization": "${userTokens.tokenType} ${userTokens.accessToken}",
      });
      if (response.statusCode != 200) {
        return Result.error("Erro ao obter url de upload");
      }
      final json = jsonDecode(response.body) as Map<String, Object?>;
      assert(json["uploadUrl"] is String);
      final responseUrl = json['uploadUrl']! as String;
      final uri = Uri.parse(responseUrl);
      return Result.value(uri);
    });
  }

  Future<Result<String>> uploadImage(Uri uploadUrl, String imagePath) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final request = MultipartRequest("POST", uploadUrl);
      request.files.add(
        await MultipartFile.fromPath(
          "file",
          imagePath,
          contentType: switch(imagePath.split(".").lastOrNull){
            "jpg"=>MediaType("image", "jpeg"),
            "jpeg"=>MediaType("image", "jpeg"),
            "png"=>MediaType("image", "png"),
            _=>null
          },
        ),
      );
      final response = await request.send();
      if (response.statusCode != 200) {
        final body = utf8.decode(await response.stream.toBytes());
        return Result.error("[${response.statusCode}] $body");
      }
      final body = utf8.decode(await response.stream.toBytes());
      final json = jsonDecode(body) as Map<String, Object?>;
      if (json["success"] != true) {
        if (kDebugMode) {
          print(json);
        }
        return Result.error("Erro ao enviar $text");
      }
      final variants = ((json["result"] as Map<String, Object?>)["variants"]
              as List<Object?>)
          .cast<String>();
      final publicVariant =
          variants.firstWhere((variant) => variant.contains("/public"));
      return Result.value(publicVariant);
    });
  }
}
