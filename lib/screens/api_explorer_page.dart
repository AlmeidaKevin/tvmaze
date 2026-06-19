import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../services/mongo_service.dart';
import '../services/tvmaze_service.dart';
import '../theme.dart';
import '../widgets/serie_card.dart';
import 'tvmaze_detail_page.dart';

class ApiExplorerPage extends StatefulWidget {
  const ApiExplorerPage({super.key});

  @override
  State<ApiExplorerPage> createState() => _ApiExplorerPageState();
}

class _ApiExplorerPageState extends State<ApiExplorerPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  List<Serie> _shows = [];
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  bool _searching = false;
  Set<int> _savedIds = {};

  @override
  void initState() {
    super.initState();
    _loadSavedIds();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 250) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadSavedIds() async {
    try {
      final ids = await MongoService.getSavedTvmazeIds();
      setState(() => _savedIds = ids);
    } catch (_) {}
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || _searching) return;
    setState(() => _loading = true);
    try {
      final nuevos = await TVMazeService.getShows(page: _page);
      setState(() {
        _page++;
        _shows.addAll(nuevos);
        _loading = false;
        if (nuevos.isEmpty) _hasMore = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _snack('Error: $e');
    }
  }

  Future<void> _doSearch(String query) async {
    if (query.isEmpty) return _reset();
    setState(() { _searching = true; _loading = true; _shows = []; });
    try {
      final results = await TVMazeService.searchShows(query);
      setState(() { _shows = results; _loading = false; _hasMore = false; });
    } catch (e) {
      setState(() => _loading = false);
      _snack('Error: $e');
    }
  }

  Future<void> _reset() async {
    setState(() { _shows = []; _page = 0; _hasMore = true; _searching = false; });
    _search.clear();
    await _loadSavedIds();
    await _loadMore();
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  bool _isSaved(Serie s) =>
      s.tvmazeId != null && _savedIds.contains(s.tvmazeId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar TVMaze'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: TextField(
              controller: _search,
              onSubmitted: _doSearch,
              decoration: InputDecoration(
                hintText: 'Buscar en TVMaze…',
                prefixIcon: const Icon(Icons.search, color: AppTheme.muted, size: 18),
                isDense: true,
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: _reset)
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: _shows.isEmpty && !_loading
          ? const Center(
              child: Text('Sin resultados',
                  style: TextStyle(color: AppTheme.muted)))
          : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: _shows.length + (_hasMore && !_searching ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _shows.length) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                        child: CircularProgressIndicator(color: AppTheme.orange)),
                  );
                }
                final show = _shows[i];
                final saved = _isSaved(show);
                return SerieCard(
                  serie: show,
                  saved: saved,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TVMazeDetailPage(
                          serie: show,
                          alreadySaved: saved,
                        ),
                      ),
                    );
                    // Refrescar IDs por si guardaron desde el detalle
                    await _loadSavedIds();
                    setState(() {});
                  },
                  trailing: saved
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppTheme.green, size: 22)
                      : IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded,
                              color: AppTheme.orange, size: 22),
                          onPressed: () async {
                            final existe = show.tvmazeId != null &&
                                await MongoService.existeTvmazeId(show.tvmazeId!);
                            if (existe) {
                              setState(() => _savedIds.add(show.tvmazeId!));
                              _snack('⚠️ Ya está en tu colección');
                              return;
                            }
                            await MongoService.insert(show);
                            setState(() => _savedIds.add(show.tvmazeId!));
                            _snack('✅ "${show.titulo}" guardada');
                          },
                        ),
                );
              },
            ),
    );
  }
}
