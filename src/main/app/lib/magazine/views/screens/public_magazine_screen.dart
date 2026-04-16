import 'package:app/feed/models/feed_item.dart';
import 'package:app/feed/views/components/search_result.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/magazine/services/magazine_tab_service.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/utils/utils.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class PublicMagazineScreen extends StatefulWidget {
  final String tabId;

  const PublicMagazineScreen({super.key, required this.tabId});

  @override
  State<PublicMagazineScreen> createState() => _PublicMagazineScreenState();
}

class _PublicMagazineScreenState extends State<PublicMagazineScreen> {
  List<FeedItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final url = serverUrl ?? _deriveServerUrl();
      if (url == null) {
        setState(() {
          _loading = false;
          _error = 'Server-URL nicht konfiguriert';
        });
        return;
      }
      final items = await PublicMagazineService(url).getItems(widget.tabId);
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  String? _deriveServerUrl() {
    try {
      return getIt.get<IdentityCubit>().state.serverUrl;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsku'),
        actions: [
          BlocBuilder<IdentityCubit, IdentityState>(
            bloc: getIt.get<IdentityCubit>(),
            builder: (context, state) {
              if (state.isLoggedIn) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => AutoRouter.of(context).replaceAll([LandingRoute()]),
                child: const Text('Anmelden'),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(pu4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: colors.error),
                        const SizedBox(height: 16),
                        Text(_error!, style: TextStyle(color: colors.error)),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              _error = null;
                            });
                            _loadItems();
                          },
                          child: const Text('Erneut versuchen'),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        'Keine Artikel vorhanden',
                        style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadItems,
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) => SearchResult(
                          item: _items[index],
                          fullDate: true,
                          noDimming: true,
                        ),
                      ),
                    ),
    );
  }
}
