import 'package:async/async.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';

Future<Result<TModel>> httpErrorHandler<TModel>(int statusCode) async {
  switch (statusCode) {
    case 404:
      return Result.error(
        HttpError(
          message:
              'Recurso não encontrado. Verifique a URL ou tente novamente mais tarde',
          status: statusCode,
        ),
      );
    case 500:
      return Result.error(
        HttpError(
          message: 'Erro Interno do Servidor.',
          status: statusCode,
        ),
      );
    default:
      return Result.error(
        HttpError(message: 'Erro Http', status: statusCode),
      );
  }
}
