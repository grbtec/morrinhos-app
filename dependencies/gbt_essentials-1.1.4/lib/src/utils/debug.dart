import 'package:flutter/foundation.dart';

/// Debug with timestamp prefix
///
/// text = Object | List<Object>
@Deprecated("⚠️ DEBUG PURPOSE ONLY. REMOVE IT!")
void debug(dynamic text) {
  if (kDebugMode) {
    assert(text is Object || text is List<Object>);
    if (text is List<Object>) {
      print('>${DateTime.now().toString().split(" ").last} ${text.join(" ")}');
      return;
    }
    if (text is Object) {
      print('${DateTime.now().toString().split(" ").last} $text');
      return;
    }
  }
}
