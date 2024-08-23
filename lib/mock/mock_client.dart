import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

void mock(http.Client client) {
  final apiBaseUri = Uri.parse("https://app-city-guide-api.azurewebsites.net/");

  when(
    client.get(
      apiBaseUri.replace(path: "/layout-widgets/00000000000-00"),
    ),
  ).thenAnswer(
    (realInvocation) async => http.Response('''{
    "variant": "View",
    "id": "00000000000-00",
    "creationDateTime": "2024-02-28T22:21:13.0051919+00:00",
    "route": "job_vacancies",
    "title": "Vagas de Emprego",
    "backgroundImageUrl": "https://images.pexels.com/photos/8276364/pexels-photo-8276364.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load"
}''', 200),
  );

  when(
    client.get(
      apiBaseUri.replace(path: "/layout-widgets/00000000000-01"),
    ),
  ).thenAnswer(
    (realInvocation) async => http.Response('''{
    "variant": "View",
    "id": "00000000000-01",
    "creationDateTime": "2024-03-01T14:05:42.8030872+00:00",
    "route": "job_vacancies",
    "title": "Parceiros",
    "iconName": "handshake_20_filled",
    "backgroundColor": 6807525
}''', 200),
  );

  when(
    client.get(
      apiBaseUri.replace(path: "/layout-widgets/00000000000-02"),
    ),
  ).thenAnswer(
    (realInvocation) async => http.Response('''{
    "variant": "View",
    "id": "00000000000-02",
    "creationDateTime": "2024-03-01T14:05:42.8030872+00:00",
    "route": "job_vacancies",
    "title": "Parceiros",
    "iconName": "handshake_20_filled",
    "backgroundImageUrl": "https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg?auto=compress&cs=tinysrgb&w=600"
}''', 200),
  );

  when(
    client.get(
      apiBaseUri.replace(path: "/layout-widgets/00000000000-03"),
    ),
  ).thenAnswer(
    (realInvocation) async => http.Response('''{
    "variant": "Special",
    "id": "4fa4b3c6-373f-4e24-b9e2-65fde3f5c33b",
    "creationDateTime": "2024-02-28T13:37:32.8547493+00:00",
    "componentName": "LayoutClock"
}''', 200),
  );


  when(
    client.get(
      apiBaseUri.replace(path: "/mobile-preferences"),
    ),
  ).thenAnswer(
    (realInvocation) async => http.Response('''{
    "id": "MobilePreferences",
    "creationDateTime": "2024-02-28T13:32:32.7428669+00:00",
    "defaultLayout": {
        "id": "87948d18-8c47-4541-9ebe-8550f1aa7e9a"
    }
}''', 200),
  );


  when(
    client.get(
      apiBaseUri.replace(path: "/layouts/87948d18-8c47-4541-9ebe-8550f1aa7e9a"),
    ),
  ).thenAnswer(
    (realInvocation) async => http.Response('''{
    "id": "87948d18-8c47-4541-9ebe-8550f1aa7e9a",
    "creationDateTime": "2024-03-06T13:04:02.0219301+00:00",
    "tiles": [
        {
            "width": 4,
            "height": 2,
            "widget": {
                "id": "00000000000-00"
            }
        },
        {
            "width": 2,
            "height": 2,
            "widget": {
                "id": "00000000000-01"
            }
        },
        {
            "width": 2,
            "height": 2,
            "widget": {
                "id": "00000000000-03"
            }
        },
        {
            "width": 4,
            "height": 2,
            "widget": {
                "id": "00000000000-02"
            }
        },
        {
            "width": 1,
            "height": 1,
            "widget": {
                "id": "00000000000-01"
            }
        },
        {
            "width": 1,
            "height": 1,
            "widget": {
                "id": "00000000000-01"
            }
        },
        {
            "width": 1,
            "height": 1,
            "widget": {
                "id": "00000000000-01"
            }
        },
        {
            "width": 1,
            "height": 1,
            "widget": {
                "id": "00000000000-01"
            }
        }
    ]
}''', 200),
  );
}
