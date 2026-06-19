import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../services/mongo_service.dart';
import '../services/tvmaze_service.dart';
import '../theme.dart';
import '../widgets/serie_card.dart';
import 'tvmaze_detail_page.dart';

class TopRatedPage extends StatefulWidget {
  const TopRatedPage({super.key});
  @override
  State<TopRatedPage> createState() => _TopRatedPageState();
}

class _TopRatedPageState extends State<TopRatedPage> {
  List<Serie> _shows = [];
  Set<int> _savedIds = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await TVMazeService.getTopRated();
      final ids = await MongoService.getSavedTvmazeIds();
      setState(() { _shows = results; _savedIds = ids; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  bool _isSaved(Serie s) => s.tvmazeId != null && _savedIds.contains(s.tvmazeId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Rated · TVMaze')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orange))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _shows.length,
              itemBuilder: (_, i) {
                final s = _shows[i];
                final saved = _isSaved(s);
                return SerieCard(
                  serie: s,
                  saved: saved,
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) =>
                            TVMazeDetailPage(serie: s, alreadySaved: saved)));
                    final ids = await MongoService.getSavedTvmazeIds();
                    setState(() => _savedIds = ids);
                  },
                  trailing: saved
                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.green, size: 22)
                      : Text(
                          '#${i + 1}',
                          style: const TextStyle(
                              color: AppTheme.orange,
                              fontWeight: FontWeight.w800,
                              fontSize: 15),
                        ),
                );
              },
            ),
    );
  }
}
