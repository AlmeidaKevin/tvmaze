import 'package:flutter/material.dart';
import '../theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1A0F02), Color(0xFF1C1C28)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.orange.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.tv_rounded, color: AppTheme.orange, size: 26),
                ),
                const SizedBox(width: 12),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SeriesVault',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  Text('Powered by TVMaze',
                      style: TextStyle(fontSize: 11, color: AppTheme.orange, fontWeight: FontWeight.w600)),
                ]),
              ]),
              const SizedBox(height: 12),
              const Text(
                'App Flutter para gestionar una colección personal de series '
                'con CRUD en MongoDB Atlas e integración con TVMaze API.',
                style: TextStyle(color: AppTheme.muted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _chip('Flutter 3', AppTheme.blue),
                _chip('MongoDB Atlas', AppTheme.green),
                _chip('TVMaze API', AppTheme.orange),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          _section('👥 Integrantes', [
            _row(Icons.person_rounded, 'Estudiante 1', 'Kevin Almeida'),
          ]),

          _section('📡 API: TVMaze', [
            _row(Icons.link_rounded, 'Base URL', 'api.tvmaze.com'),
            _row(Icons.list_rounded, 'Paginada', '/shows?page={n}'),
            _row(Icons.search_rounded, 'Búsqueda', '/search/shows?q={q}'),
            _row(Icons.info_rounded, 'Detalle', '/shows/{id}'),
            _row(Icons.lock_open_rounded, 'API Key', 'No requiere'),
          ]),

          _section('🗂️ Pantallas', [
            _row(Icons.home_rounded,          '1. HomePage',        'Menú principal'),
            _row(Icons.video_library_rounded,  '2. CollectionPage',  'CRUD + infinite scroll local'),
            _row(Icons.edit_rounded,           '3. FormPage',        'Crear y editar series'),
            _row(Icons.info_outline_rounded,   '4. DetailPage',      'Detalle de serie local'),
            _row(Icons.explore_rounded,        '5. ApiExplorerPage', 'TVMaze + infinite scroll'),
            _row(Icons.tv_rounded,             '6. TVMazeDetailPage','Detalle de serie TVMaze'),
            _row(Icons.search_rounded,         '7. SearchPage',      'Búsqueda en colección y API'),
            _row(Icons.star_rounded,           '8. TopRatedPage',    'Mejores series TVMaze'),
            _row(Icons.label_rounded,          '9. GenresPage',      'Filtro por género'),
            _row(Icons.bar_chart_rounded,      '10. StatsPage',      'Estadísticas de colección'),
            _row(Icons.info_rounded,           '11. AboutPage',      'Esta pantalla'),
          ]),

          _section('⚙️ Tecnologías', [
            _row(Icons.phone_android_rounded, 'Framework',     'Flutter 3'),
            _row(Icons.storage_rounded,       'Base de datos', 'MongoDB Atlas (mongo_dart)'),
            _row(Icons.http_rounded,          'HTTP',          'http package'),
            _row(Icons.image_rounded,         'Imágenes',      'cached_network_image'),
            _row(Icons.fingerprint_rounded,   'IDs',           'uuid package'),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.orange)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(children: children),
          ),
          const SizedBox(height: 6),
        ],
      );

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          Icon(icon, size: 16, color: AppTheme.orange),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12), textAlign: TextAlign.end),
        ]),
      );

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}
