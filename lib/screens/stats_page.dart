import 'package:flutter/material.dart';
import '../services/mongo_service.dart';
import '../theme.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final s = await MongoService.getStats();
      setState(() { _stats = s; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orange))
          : _stats == null
              ? const Center(
                  child: Text('Error al cargar',
                      style: TextStyle(color: AppTheme.muted)))
              : RefreshIndicator(
                  color: AppTheme.orange,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _statCard(
                        Icons.video_library_rounded,
                        'Total de series',
                        '${_stats!['total']}',
                        AppTheme.purple,
                      ),
                      _statCard(
                        Icons.star_rounded,
                        'Rating promedio',
                        '${(_stats!['avgRating'] as double).toStringAsFixed(2)} / 10',
                        AppTheme.orange,
                      ),
                      _statCard(
                        Icons.label_rounded,
                        'Género más frecuente',
                        '${_stats!['topGenero']}',
                        AppTheme.green,
                      ),
                      _statCard(
                        Icons.tv_rounded,
                        'Importadas de TVMaze',
                        '${_stats!['desdeTVMaze']}',
                        const Color(0xFFFD79A8),
                      ),
                      _statCard(
                        Icons.play_circle_rounded,
                        'En emisión',
                        '${_stats!['running']}',
                        AppTheme.blue,
                      ),

                      // Géneros breakdown
                      if ((_stats!['generos'] as Map).isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Desglose por género',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ...((_stats!['generos'] as Map<String, int>)
                                .entries
                                .toList()
                              ..sort((a, b) => b.value.compareTo(a.value)))
                            .take(8)
                            .map((e) => _genreBar(
                                e.key, e.value, _stats!['total'] as int))
                            .toList(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.muted, fontSize: 12)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      );

  Widget _genreBar(String genre, int count, int total) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(genre,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$count',
                  style: const TextStyle(
                      color: AppTheme.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppTheme.border,
              color: AppTheme.orange,
            ),
          ),
        ],
      ),
    );
  }
}