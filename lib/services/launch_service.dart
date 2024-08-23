import 'package:flutter/foundation.dart';
import 'package:gbt_essentials/gbt_essentials.dart';
import 'package:mobile/model/geo_location_coordinates.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LaunchService {
  Future<bool> launch(LaunchType launchType, String value) async {
    switch (launchType) {
      case LaunchType.call:
        return launchUrlString(
          _debug("tel:$value"),
          mode: LaunchMode.externalApplication,
        );
      case LaunchType.whatsApp:
        var whatsAppNumber = value;
        if (whatsAppNumber.contains("+")) {
          whatsAppNumber = whatsAppNumber.replaceFirst("+", "");
        }
        if (whatsAppNumber.length < 12) {
          whatsAppNumber = "55" + whatsAppNumber;
        }
        return launchUrlString(
          _debug("https://wa.me/$whatsAppNumber"),
          mode: LaunchMode.externalApplication,
        );
      case LaunchType.email:
        return launchEmail(_debug(value), null);
      case LaunchType.url:
        return launchUrlString(_debug(value),
            mode: LaunchMode.externalApplication);
    }
  }

  Future<bool> launchEmail(String email, String? body) {
    return launchUrlString(
      _debug("mailto:$email${body != null ? "?body=$body" : ""}"),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<bool> launchMap(GeoLocationCoordinates location) {
    Future<bool> androidSchemeLauncher() => launchUrlString(
          _debug(
              "geo:${location.latitude},${location.longitude}?q=${location.latitude},${location.longitude}"),
          mode: LaunchMode.externalApplication,
        );
    Future<bool> iosSchemeLauncher() => launchUrlString(
          _debug(
              "maps://maps.apple.com/?q=${location.latitude},${location.longitude}"),
          mode: LaunchMode.externalApplication,
        );
    // https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
    Future<bool> iosUrlLauncher() => launchUrlString(
          _debug(
              "http://maps.apple.com/?q=${location.latitude},${location.longitude}"),
          mode: LaunchMode.platformDefault,
        );
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosSchemeLauncher()
          .timeout(const Duration(seconds: 1), onTimeout: () {
            // if doesn't throw any exception before 1 seconds,
            // throw exception for skipping to the next try
            return true;
          })
          .then(
            (wasSucceeded) async => wasSucceeded || await iosUrlLauncher(),
          )
          .catchError(
            (_) => iosUrlLauncher(),
          );
    } else {
      return androidSchemeLauncher();
    }
  }
}

enum LaunchType {
  call,
  whatsApp,
  email,
  url,
}

String _debug(String value) {
  Future(() => debug(value));
  return value;
}
