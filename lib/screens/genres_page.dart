import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../services/mongo_service.dart';
import '../services/tvmaze_service.dart';
import '../theme.dart';
import '../widgets/serie_card.dart';
import 'tvmaze_detail_page.dart';

const _genres = [
  ('Drama',     Icons.theater_comedy_rounded,  Color(0xFF6C5CE7)),
  ('Comedy',    Icons.sentiment_very_satisfied_rounded, Color(0xFFFD79A8)),
  ('Crime',     Icons.local_police_rounded,    Color(0xFFE17055)),
  ('Thriller',  Icons.bolt_rounded,            Color(0xFFF5A623)),
  ('Action',    Icons.flash_on_rounded,        Color(0xFFFF7675)),
  ('Science-Fiction',    Icons.rocket_launch_rounded,   Color(0xFF74B9FF)),
  ('Horror',    Icons.dark_mode_rounded,       Color(0xFF636E72)),
  ('Adventure', Icons.explore_rounded,         Color(0xFF00B894)),
  ('Fantasy',   Icons.auto_awesome_rounded,    Color(0xFFA29BFE)),
  ('Romance',   Icons.favorite_rounded,        Color(0xFFE84393)),
  ('Mystery',   Icons.search_rounded,          Color(0xFF00CEC9)),
  ('Anime',     Icons.animation_rounded,       Color(0xFFFECE00)),
];

class GenresPage extends StatelessWidget {
  const GenresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Por Género')),
      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.4,
        ),
        itemCount: _genres.length,
        itemBuilder: (context, i) {
          final (name, icon, color) = _genres[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => GenreResultsPage(genre: name, color: color)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 8),
                  Text(name,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GenreResultsPage extends StatefulWidget {
  final String genre;
  final Color color;
  const GenreResultsPage({super.key, required this.genre, required this.color});
  @override
  State<GenreResultsPage> createState() => _GenreResultsPageState();
}

class _GenreResultsPageState extends State<GenreResultsPage> {
  final ScrollController _scroll = ScrollController();
  List<Serie> _shows = [];
  Set<int> _savedIds = {};
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadSavedIds();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  Future<void> _loadSavedIds() async {
    final ids = await MongoService.getSavedTvmazeIds();
    setState(() => _savedIds = ids);
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      // Traer página y filtrar por género
      final all = await TVMazeService.getShows(page: _page);
      final filtered = all
          .where((s) => s.genero.toLowerCase().contains(widget.genre.toLowerCase()))
          .toList();
      setState(() {
        _page++;
        _shows.addAll(filtered);
        _loading = false;
        if (all.isEmpty) _hasMore = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  bool _isSaved(Serie s) => s.tvmazeId != null && _savedIds.contains(s.tvmazeId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.genre)),
      body: _shows.isEmpty && !_loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orange))
          : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _shows.length + (_hasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _shows.length) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: AppTheme.orange)),
                  );
                }
                final s = _shows[i];
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
    );
  }
}
