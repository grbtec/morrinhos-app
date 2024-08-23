import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:gbt_dart_essentials/gbt_dart_essentials.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/components/error_component.dart';
import 'package:mobile/screen/(authenticated)/employer_registry/employer_list_view.dart';
import 'package:mobile/screen/(authenticated)/employer_registry/employer_registry_view.dart';
import 'package:mobile/screen/(authenticated)/job_registry/job_list_view.dart';
import 'package:mobile/screen/(authenticated)/job_registry/job_registry_view.dart';
import 'package:mobile/screen/(deep_link)/p/post_view.dart';
import 'package:mobile/screen/home/home_view.dart';
import 'package:mobile/screen/job_posts/employers/employer_view.dart';
import 'package:mobile/screen/job_posts/job_posts_view.dart';
import 'package:mobile/screen/public_utility/public_utility_view.dart';
import 'package:mobile/screen/search/search_view.dart';

/// Routes
abstract final class Routes {
  static const home = "home";
  static const post = "post";
  static const jobPosts = "job_posts";
  static const jobPost = "job_post";
  static const employer = "employer";
  static const publicUtility = "public_utility";
  static const search = "search";
  static const jobList = "job_list";
  static const jobRegistryCreate = "job_registry_create";
  static const jobRegistryUpdate = "job_update";
  static const employerList = "employer_list";
  static const employerRegistryCreate = "employer_registry_create";
  static const employerRegistryUpdate = "employer_registry_update";
}

final router = GoRouter(
  errorBuilder: (context, state) {
    if (kDebugMode) {
      print("Uri: ${state.uri}");
      print("Host: ${state.uri.host}");
      print("Path: ${state.uri.path}");
      print("pathSegments: ${state.uri.pathSegments}");
      print("PathParameters: ${state.pathParameters}");
    }
    return _ErrorWidget(errorMessage: state.error?.message);
  },
  routes: [
    GoRoute(
      name: Routes.home,
      path: "/",
      builder: (context, state) => const HomeView(),
      routes: [
        ..._adminRoutes,
        GoRoute(path: "posts/:id", redirect: replacePath("posts", "p")),
        GoRoute(
          name: Routes.post,
          path: "p/:id",
          builder: (_, state) => PostView(id: state.pathParameters["id"]!),
        ),
        GoRoute(path: "vaga", redirect: replacePath("vaga", "vagas")),
        GoRoute(
          name: Routes.jobPosts,
          path: "vagas",
          builder: (_, __) => const JobPostsView(),
        ),
        GoRoute(path: "vaga/:id", redirect: replacePath("vaga", "vagas")),
        GoRoute(
          name: Routes.jobPost,
          path: "vagas/:postId",
          builder: (_, state) => JobPostsView(
            postId: state.pathParameters["postId"],
          ),
        ),
        GoRoute(
          name: Routes.publicUtility,
          path: Routes.publicUtility,
          builder: (_, __) => const PublicUtilityView(),
        ),
        GoRoute(
          name: Routes.search,
          path: Routes.search,
          builder: (_, __) => const SearchView(),
        ),
      ],
    ),
  ],
);

final _adminRoutes = [
  GoRoute(
    name: Routes.jobList,
    path: Routes.jobList,
    builder: (_, __) => const JobListView(),
  ),
  GoRoute(
    name: Routes.jobRegistryCreate,
    path: Routes.jobRegistryCreate,
    builder: (_, state) => const JobRegistryView(id: null),
  ),
  GoRoute(
    name: Routes.jobRegistryUpdate,
    path: "${Routes.jobRegistryUpdate}/:id",
    builder: (_, state) => JobRegistryView(id: state.pathParameters["id"]),
  ),
  GoRoute(
    name: Routes.employerList,
    path: Routes.employerList,
    builder: (_, __) => const EmployerListView(),
  ),
  GoRoute(
    name: Routes.employerRegistryCreate,
    path: Routes.employerRegistryCreate,
    builder: (_, state) => const EmployerRegistryView(id: null),
  ),
  GoRoute(
    name: Routes.employerRegistryUpdate,
    path: "${Routes.employerRegistryUpdate}/:id",
    builder: (_, state) => EmployerRegistryView(id: state.pathParameters["id"]),
  ),
];

class _ErrorWidget extends StatelessWidget {
  final String? errorMessage;

  const _ErrorWidget({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return FluentScaffold(
      appBar: FluentNavBar(
        title: NavLeftTitle(
          title: "Rota não encontrada",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ErrorComponent(
                message: errorMessage != null
                    ? () {
                        if (kDebugMode) {
                          print(errorMessage);
                        }

                        return "Não encontramos a página que você está procurando.";
                      }()
                    : "Erro desconhecido",
              ),
              if (errorMessage != null)
                FluentButton(
                  onPressed: () {
                    router.goNamed(Routes.home);
                  },
                  title: "Voltar para o início",
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Return the redirect callback which handles the replacement of the path
String Function(BuildContext _, GoRouterState state) replacePath(
    String from, String to) {
  return (BuildContext _, GoRouterState state) =>
      state.matchedLocation.replaceFirst(from, to);
}
