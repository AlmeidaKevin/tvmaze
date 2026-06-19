import 'package:flutter/material.dart';
import '../theme.dart';
import 'collection_page.dart';
import 'api_explorer_page.dart';
import 'stats_page.dart';
import 'about_page.dart';
import 'search_page.dart';
import 'top_rated_page.dart';
import 'genres_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A0F02), Color(0xFF0A0A0F)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppTheme.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppTheme.orange.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.tv_rounded,
                                  color: AppTheme.orange, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SeriesVault',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('Powered by TVMaze',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.orange,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Search bar decorativa
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SearchPage())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: AppTheme.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.search, color: AppTheme.muted, size: 18),
                                SizedBox(width: 8),
                                Text('Buscar series o películas…',
                                    style: TextStyle(
                                        color: AppTheme.muted, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionLabel('Mi contenido'),
                const SizedBox(height: 10),
                _MenuItem(
                  icon: Icons.video_library_rounded,
                  title: 'Mi Colección',
                  subtitle: 'Series guardadas en MongoDB Atlas',
                  color: AppTheme.purple,
                  onTap: () => _push(context, const CollectionPage()),
                ),
                const SizedBox(height: 8),
                _MenuItem(
                  icon: Icons.search_rounded,
                  title: 'Buscar',
                  subtitle: 'Busca en tu colección o en TVMaze',
                  color: AppTheme.blue,
                  onTap: () => _push(context, const SearchPage()),
                ),
                const SizedBox(height: 18),
                const _SectionLabel('Explorar TVMaze'),
                const SizedBox(height: 10),
                _MenuItem(
                  icon: Icons.explore_rounded,
                  title: 'Explorador',
                  subtitle: 'Todas las series con infinite scrolling',
                  color: AppTheme.orange,
                  onTap: () => _push(context, const ApiExplorerPage()),
                ),
                const SizedBox(height: 8),
                _MenuItem(
                  icon: Icons.star_rounded,
                  title: 'Top Rated',
                  subtitle: 'Las series mejor puntuadas de TVMaze',
                  color: const Color(0xFFFD79A8),
                  onTap: () => _push(context, const TopRatedPage()),
                ),
                const SizedBox(height: 8),
                _MenuItem(
                  icon: Icons.label_rounded,
                  title: 'Por Género',
                  subtitle: 'Filtra series por categoría',
                  color: const Color(0xFF00CEC9),
                  onTap: () => _push(context, const GenresPage()),
                ),
                const SizedBox(height: 18),
                const _SectionLabel('Info'),
                const SizedBox(height: 10),
                _MenuItem(
                  icon: Icons.bar_chart_rounded,
                  title: 'Estadísticas',
                  subtitle: 'Análisis de tu colección',
                  color: AppTheme.green,
                  onTap: () => _push(context, const StatsPage()),
                ),
                const SizedBox(height: 8),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'Acerca de',
                  subtitle: 'Integrantes, API y tecnologías',
                  color: AppTheme.muted,
                  onTap: () => _push(context, const AboutPage()),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext ctx, Widget page) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2));
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.muted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
