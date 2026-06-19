import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../services/mongo_service.dart';
import '../theme.dart';
import '../widgets/serie_card.dart';
import 'form_page.dart';
import 'detail_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();
  List<Serie> _series = [];
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); _search.dispose(); super.dispose(); }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || _searching) return;
    setState(() => _loading = true);
    try {
      final nuevas = await MongoService.getAll(page: _page, limit: 20);
      setState(() {
        _page++;
        _series.addAll(nuevas);
        _loading = false;
        if (nuevas.length < 20) _hasMore = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _snack('Error: $e');
    }
  }

  Future<void> _refresh() async {
    setState(() { _series = []; _page = 0; _hasMore = true; _searching = false; });
    _search.clear();
    await _loadMore();
  }

  Future<void> _doSearch(String q) async {
    if (q.isEmpty) return _refresh();
    setState(() { _searching = true; _loading = true; });
    try {
      final r = await MongoService.search(q);
      setState(() { _series = r; _loading = false; _hasMore = false; });
    } catch (e) {
      setState(() => _loading = false);
      _snack('Error: $e');
    }
  }

  Future<void> _delete(Serie s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar serie?'),
        content: Text('Se eliminará "${s.titulo}".',
            style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await MongoService.delete(s.id);
      setState(() => _series.removeWhere((x) => x.id == s.id));
      _snack('Serie eliminada');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Colección'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: TextField(
              controller: _search,
              onSubmitted: _doSearch,
              decoration: InputDecoration(
                hintText: 'Buscar en mi colección…',
                prefixIcon: const Icon(Icons.search, color: AppTheme.muted, size: 18),
                isDense: true,
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: _refresh)
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.orange,
        onRefresh: _refresh,
        child: _series.isEmpty && !_loading
            ? _empty()
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.only(top: 8, bottom: 90),
                itemCount: _series.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _series.length) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.orange)),
                    );
                  }
                  final s = _series[i];
                  return SerieCard(
                    serie: s,
                    onTap: () async {
                      final updated = await Navigator.push<Serie>(
                        context,
                        MaterialPageRoute(builder: (_) => DetailPage(serie: s)),
                      );
                      if (updated != null) {
                        setState(() {
                          final idx = _series.indexWhere((x) => x.id == updated.id);
                          if (idx >= 0) _series[idx] = updated;
                        });
                      }
                    },
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppTheme.muted, size: 20),
                      color: AppTheme.card,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (v) async {
                        if (v == 'edit') {
                          final updated = await Navigator.push<Serie>(
                            context,
                            MaterialPageRoute(builder: (_) => FormPage(serie: s)),
                          );
                          if (updated != null) {
                            setState(() {
                              final idx = _series.indexWhere((x) => x.id == updated.id);
                              if (idx >= 0) _series[idx] = updated;
                            });
                          }
                        } else if (v == 'delete') {
                          await _delete(s);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('✏️  Editar')),
                        PopupMenuItem(
                            value: 'delete',
                            child: Text('🗑️  Eliminar',
                                style: TextStyle(color: Colors.redAccent))),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nueva = await Navigator.push<Serie>(
            context,
            MaterialPageRoute(builder: (_) => const FormPage()),
          );
          if (nueva != null) setState(() => _series.insert(0, nueva));
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva serie'),
      ),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tv_off_rounded, size: 60, color: AppTheme.muted),
              const SizedBox(height: 14),
              const Text('Colección vacía',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.muted)),
              const SizedBox(height: 6),
              const Text('Agrega series manualmente o desde TVMaze',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.muted, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final nueva = await Navigator.push<Serie>(
                    context, MaterialPageRoute(builder: (_) => const FormPage()));
                  if (nueva != null) setState(() => _series.insert(0, nueva));
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar serie'),
              ),
            ],
          ),
        ),
      );
}
