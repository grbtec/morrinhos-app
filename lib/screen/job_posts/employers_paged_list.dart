part of 'job_posts_view.dart';

class _EmployersPagedList extends ConsumerStatefulWidget {
  final Rx<String?> selectedEmployerRx;

  const _EmployersPagedList({
    super.key,
    required this.selectedEmployerRx,
  });

  @override
  ConsumerState<_EmployersPagedList> createState() =>
      _EmployersPagedListState();
}

class _EmployersPagedListState extends ConsumerState<_EmployersPagedList> {
  late final employerPagedListController = RiverpodPagedListController(
    this,
    _pagedPinnedEmployersProvider,
    search: null,
  );

  void _onEmployerClick(String id) {
    if (widget.selectedEmployerRx() == id) {
      widget.selectedEmployerRx.value = null;
    } else {
      widget.selectedEmployerRx(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, IdHolder>(
      scrollDirection: Axis.horizontal,
      pagingController: employerPagedListController.pagingController,
      builderDelegate: MyPagedChildBuilderDelegate(
          controller: employerPagedListController.pagingController,
          itemBuilder: (BuildContext context, item, int index) {
            return Consumer(builder: (context, ref, child) {
              const width = 86.0;
              final employerAsync = ref.watch(employerProvider(item.id));
              final employer = employerAsync.valueOrNull;

              if (employerAsync.hasError && employer == null) {
                return const SizedBox(
                  width: 300,
                  child: ListTile(
                    title: Text("Erro ao carregar empregador"),
                    leading: Icon(FluentIcons.error_circle_24_regular),
                  ),
                );
              }

              if (employer == null) {
                return const SizedBox(
                  width: width,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final isSelected = () => widget.selectedEmployerRx() != item.id;
              return SizedBox(
                width: width,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: FluentSize.size120.value,
                  ),
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Column(
                        children: [
                          Obx(
                            () => FluentAvatar(
                              strokeStyle: isSelected()
                                  ? null
                                  : FluentStrokeStyle(
                                      thickness:
                                          FluentStrokeThickness.strokeWidth40,
                                      color: FluentColors.of(context)
                                          ?.brandStroke1Selected),
                              child: SizedBox(
                                width: double.maxFinite,
                                height: double.maxFinite,
                                child: Image.network(
                                  employer.logoUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: FluentSize.size120.value,
                          ),
                          FluentText(
                            employer.name,
                            textAlign: TextAlign.center,
                            textOverflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                      MaterialButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _onEmployerClick(item.id),
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
    );
  }
}
