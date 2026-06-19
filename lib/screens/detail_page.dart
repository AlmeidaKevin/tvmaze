import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../services/mongo_service.dart';
import '../theme.dart';
import 'form_page.dart';

class DetailPage extends StatefulWidget {
  final Serie serie;
  const DetailPage({super.key, required this.serie});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Serie _serie;

  @override
  void initState() { super.initState(); _serie = widget.serie; }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar serie?'),
        content: Text('Se eliminará "${_serie.titulo}".',
            style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await MongoService.delete(_serie.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final img = _serie.imagenOriginal.isNotEmpty
        ? _serie.imagenOriginal
        : _serie.imagen;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.bg,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () async {
                  final updated = await Navigator.push<Serie>(
                    context,
                    MaterialPageRoute(builder: (_) => FormPage(serie: _serie)),
                  );
                  if (updated != null) setState(() => _serie = updated);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: _delete,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  img.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: img,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _bg(),
                          errorWidget: (_, __, ___) => _bg(),
                        )
                      : _bg(),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.bg],
                        stops: [0.45, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(_serie.titulo,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: [
                    if (_serie.rating > 0)
                      _chip('★ ${_serie.rating.toStringAsFixed(1)}', AppTheme.orange),
                    _chip(
                      _serie.estado,
                      _serie.estado == 'Running' ? AppTheme.green : AppTheme.muted,
                    ),
                    if (_serie.temporadas > 0)
                      _chip('${_serie.temporadas} temp.', AppTheme.purple),
                    if (_serie.premieredYear != null)
                      _chip(_serie.premieredYear!, AppTheme.blue),
                    _chip(_serie.fuente,
                        _serie.fuente == 'TVMaze API' ? AppTheme.orange : AppTheme.muted),
                  ],
                ),
                const SizedBox(height: 14),
                _infoRow(Icons.label_rounded, 'Género', _serie.genero),
                _infoRow(Icons.live_tv_rounded, 'Canal', _serie.canal),
                if (_serie.idioma != null && _serie.idioma!.isNotEmpty)
                  _infoRow(Icons.language_rounded, 'Idioma', _serie.idioma!),
                if (_serie.sinopsis.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Sinopsis',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(_serie.sinopsis,
                      style: const TextStyle(
                          color: AppTheme.muted, height: 1.65, fontSize: 13)),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bg() => Container(
      color: AppTheme.surface,
      child: const Center(child: Icon(Icons.tv, color: AppTheme.muted, size: 64)));

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 15, color: AppTheme.orange),
          const SizedBox(width: 7),
          Text('$label: ',
              style: const TextStyle(
                  color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value.isNotEmpty ? value : '-',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ),
        ]),
      );
}
