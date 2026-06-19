import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../services/mongo_service.dart';
import '../services/tvmaze_service.dart';
import '../theme.dart';
import '../widgets/serie_card.dart';
import 'detail_page.dart';
import 'tvmaze_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final TextEditingController _ctrl = TextEditingController();
  List<Serie> _localResults = [];
  List<Serie> _apiResults = [];
  Set<int> _savedIds = {};
  bool _loadingLocal = false;
  bool _loadingApi = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadSavedIds();
  }

  @override
  void dispose() { _tabs.dispose(); _ctrl.dispose(); super.dispose(); }

  Future<void> _loadSavedIds() async {
    try {
      final ids = await MongoService.getSavedTvmazeIds();
      setState(() => _savedIds = ids);
    } catch (_) {}
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searched = true;
      _loadingLocal = true;
      _loadingApi = true;
    });
    // Buscar en paralelo
    await Future.wait([
      MongoService.search(q).then((r) => setState(() { _localResults = r; _loadingLocal = false; }))
          .catchError((_) => setState(() => _loadingLocal = false)),
      TVMazeService.searchShows(q).then((r) => setState(() { _apiResults = r; _loadingApi = false; }))
          .catchError((_) => setState(() => _loadingApi = false)),
    ]);
  }

  bool _isSaved(Serie s) => s.tvmazeId != null && _savedIds.contains(s.tvmazeId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onSubmitted: _search,
          decoration: InputDecoration(
            hintText: 'Buscar series…',
            border: InputBorder.none,
            hintStyle: const TextStyle(color: AppTheme.muted),
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() { _localResults = []; _apiResults = []; _searched = false; });
                    })
                : null,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.orange,
          labelColor: AppTheme.orange,
          unselectedLabelColor: AppTheme.muted,
          tabs: [
            Tab(text: 'Mi colección (${_localResults.length})'),
            Tab(text: 'TVMaze (${_apiResults.length})'),
          ],
        ),
      ),
      body: !_searched
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, size: 56, color: AppTheme.muted),
                  SizedBox(height: 12),
                  Text('Escribe para buscar',
                      style: TextStyle(color: AppTheme.muted, fontSize: 14)),
                ],
              ),
            )
          : TabBarView(
              controller: _tabs,
              children: [
                // Local
                _loadingLocal
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.orange))
                    : _localResults.isEmpty
                        ? const Center(child: Text('Sin resultados locales', style: TextStyle(color: AppTheme.muted)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _localResults.length,
                            itemBuilder: (_, i) => SerieCard(
                              serie: _localResults[i],
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => DetailPage(serie: _localResults[i]))),
                            ),
                          ),
                // TVMaze
                _loadingApi
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.orange))
                    : _apiResults.isEmpty
                        ? const Center(child: Text('Sin resultados en TVMaze', style: TextStyle(color: AppTheme.muted)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _apiResults.length,
                            itemBuilder: (_, i) {
                              final s = _apiResults[i];
                              final saved = _isSaved(s);
                              return SerieCard(
                                serie: s,
                                saved: saved,
                                onTap: () async {
                                  await Navigator.push(context,
                                      MaterialPageRoute(builder: (_) =>
                                          TVMazeDetailPage(serie: s, alreadySaved: saved)));
                                  await _loadSavedIds();
                                  setState(() {});
                                },
                              );
                            },
                          ),
              ],
            ),
    );
  }
}
