import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../services/mongo_service.dart';
import '../services/tvmaze_service.dart';
import '../theme.dart';

/// Detalle de una serie proveniente de TVMaze (antes de guardarla)
class TVMazeDetailPage extends StatefulWidget {
  final Serie serie;
  final bool alreadySaved;

  const TVMazeDetailPage({
    super.key,
    required this.serie,
    required this.alreadySaved,
  });

  @override
  State<TVMazeDetailPage> createState() => _TVMazeDetailPageState();
}

class _TVMazeDetailPageState extends State<TVMazeDetailPage> {
  bool _saved = false;
  bool _saving = false;
  Map<String, dynamic>? _extra; // datos extra del endpoint /shows/{id}
  bool _loadingExtra = true;

  @override
  void initState() {
    super.initState();
    _saved = widget.alreadySaved;
    _loadExtra();
  }

  Future<void> _loadExtra() async {
    if (widget.serie.tvmazeId == null) {
      setState(() => _loadingExtra = false);
      return;
    }
    try {
      final data = await TVMazeService.getShowDetail(widget.serie.tvmazeId!);
      setState(() {
        _extra = data;
        _loadingExtra = false;
      });
    } catch (_) {
      setState(() => _loadingExtra = false);
    }
  }

  Future<void> _guardar() async {
    if (_saved || _saving) return;
    setState(() => _saving = true);
    try {
      // Verificar duplicado en BD
      if (widget.serie.tvmazeId != null) {
        final existe = await MongoService.existeTvmazeId(widget.serie.tvmazeId!);
        if (existe) {
          setState(() { _saved = true; _saving = false; });
          _snack('⚠️ Ya está en tu colección');
          return;
        }
      }
      await MongoService.insert(widget.serie);
      setState(() { _saved = true; _saving = false; });
      _snack('✅ "${widget.serie.titulo}" guardada en tu colección');
    } catch (e) {
      setState(() => _saving = false);
      _snack('Error al guardar: $e');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final s = widget.serie;
    final imgOriginal = s.imagenOriginal.isNotEmpty ? s.imagenOriginal : s.imagen;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // ── Hero poster ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  imgOriginal.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imgOriginal,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _bgPlaceholder(),
                          errorWidget: (_, __, ___) => _bgPlaceholder(),
                        )
                      : _bgPlaceholder(),
                  // Gradiente inferior
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.bg],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Título
                Text(s.titulo,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2)),
                const SizedBox(height: 10),

                // Chips de info
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (s.rating > 0)
                      _chip('★ ${s.rating.toStringAsFixed(1)}', AppTheme.orange),
                    _chip(
                      s.estado,
                      s.estado == 'Running' ? AppTheme.green : AppTheme.muted,
                    ),
                    if (s.premieredYear != null)
                      _chip(s.premieredYear!, AppTheme.blue),
                    if (s.idioma != null && s.idioma!.isNotEmpty)
                      _chip(s.idioma!, AppTheme.purple),
                  ],
                ),
                const SizedBox(height: 14),

                // Géneros
                if (s.genero.isNotEmpty && s.genero != 'Desconocido')
                  _infoRow(Icons.label_rounded, 'Géneros', s.genero),
                _infoRow(Icons.live_tv_rounded, 'Canal', s.canal),

                // Datos extra de TVMaze
                if (_loadingExtra)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.orange))),
                  ),
                if (_extra != null) ...[
                  if (_extra!['schedule']?['time'] != null &&
                      (_extra!['schedule']['time'] as String).isNotEmpty)
                    _infoRow(Icons.schedule_rounded, 'Horario',
                        '${_extra!['schedule']['days']?.join(', ') ?? ''} ${_extra!['schedule']['time']}'),
                  if (_extra!['runtime'] != null)
                    _infoRow(Icons.timer_rounded, 'Duración',
                        '${_extra!['runtime']} min por episodio'),
                  if (_extra!['type'] != null)
                    _infoRow(Icons.category_rounded, 'Tipo', _extra!['type']),
                ],

                // Sinopsis
                if (s.sinopsis.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Sinopsis',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(s.sinopsis,
                      style: const TextStyle(
                          color: AppTheme.muted, height: 1.65, fontSize: 13)),
                ],

                const SizedBox(height: 24),

                // Botón guardar
                _saved
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.green.withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: AppTheme.green, size: 18),
                            SizedBox(width: 8),
                            Text('En tu colección',
                                style: TextStyle(
                                    color: AppTheme.green,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _saving ? null : _guardar,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black))
                            : const Icon(Icons.add_rounded),
                        label: Text(_saving
                            ? 'Guardando…'
                            : '+ Guardar en mi colección'),
                      ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bgPlaceholder() => Container(
      color: AppTheme.surface,
      child: const Center(
          child: Icon(Icons.tv, color: AppTheme.muted, size: 64)));

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: AppTheme.orange),
            const SizedBox(width: 7),
            Text('$label: ',
                style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            Expanded(
              child: Text(value.isNotEmpty ? value : '-',
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ),
          ],
        ),
      );
}
