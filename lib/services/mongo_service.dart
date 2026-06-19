import 'package:mongo_dart/mongo_dart.dart';
import 'package:uuid/uuid.dart';
import '../models/serie.dart';

class MongoService {
  static late Db _db;
  static late DbCollection _col;

  // ⚠️ Reemplaza con tu connection string de MongoDB Atlas
  static const _connectionString = 'mongodb+srv://peliculasyseries459_db_user:4T55XSanp7Ynpai0@cluster0.cfyrp4w.mongodb.net/?appName=Cluster0';

  static Future<void> connect() async {
    _db = await Db.create(_connectionString);
    await _db.open();
    _col = _db.collection('series');
  }

  static Future<void> disconnect() async => _db.close();

  // CREATE
  static Future<Serie> insert(Serie serie) async {
    final id = const Uuid().v4();
    final s = serie.copyWith(id: id);
    await _col.insertOne(s.toMap());
    return s;
  }

  // READ paginado
  static Future<List<Serie>> getAll({int page = 0, int limit = 20}) async {
    final docs = await _col
        .find(where.skip(page * limit).limit(limit))
        .toList();
    return docs.map(Serie.fromMap).toList();
  }

  // READ búsqueda
  static Future<List<Serie>> search(String query) async {
    final docs = await _col
        .find(where.match('titulo', query, caseInsensitive: true))
        .toList();
    return docs.map(Serie.fromMap).toList();
  }

  // READ por género
  static Future<List<Serie>> getByGenero(String genero) async {
    final docs = await _col
        .find(where.match('genero', genero, caseInsensitive: true))
        .toList();
    return docs.map(Serie.fromMap).toList();
  }

  // UPDATE
  static Future<void> update(Serie serie) async {
    await _col.updateOne(
      where.eq('_id', serie.id),
      modify
          .set('titulo', serie.titulo)
          .set('genero', serie.genero)
          .set('estado', serie.estado)
          .set('rating', serie.rating)
          .set('temporadas', serie.temporadas)
          .set('imagen', serie.imagen)
          .set('sinopsis', serie.sinopsis)
          .set('canal', serie.canal)
          .set('idioma', serie.idioma)
          .set('premieredYear', serie.premieredYear),
    );
  }

  // DELETE
  static Future<void> delete(String id) async {
    await _col.deleteOne(where.eq('_id', id));
  }

  // Verificar duplicado
  static Future<bool> existeTvmazeId(int tvmazeId) async {
    final doc = await _col.findOne(where.eq('tvmazeId', tvmazeId));
    return doc != null;
  }

  // Obtener todos los tvmazeIds guardados
  static Future<Set<int>> getSavedTvmazeIds() async {
    final docs = await _col.find().toList();
    return docs
        .map(Serie.fromMap)
        .where((s) => s.tvmazeId != null)
        .map((s) => s.tvmazeId!)
        .toSet();
  }

  // Stats
  static Future<Map<String, dynamic>> getStats() async {
    final docs = await _col.find().toList();
    final series = docs.map(Serie.fromMap).toList();
    final total = series.length;
    final conRating = series.where((s) => s.rating > 0).toList();
    final avgRating = conRating.isEmpty
        ? 0.0
        : conRating.map((s) => s.rating).reduce((a, b) => a + b) /
            conRating.length;

    final generoCount = <String, int>{};
    for (final s in series) {
      for (final g in s.genero.split(', ')) {
        final g2 = g.trim();
        if (g2.isNotEmpty) generoCount[g2] = (generoCount[g2] ?? 0) + 1;
      }
    }
    final topGenero = generoCount.isEmpty
        ? '-'
        : (generoCount.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    return {
      'total': total,
      'avgRating': avgRating,
      'topGenero': topGenero,
      'desdeTVMaze': series.where((s) => s.fuente == 'TVMaze API').length,
      'running': series.where((s) => s.estado == 'Running').length,
      'generos': generoCount,
    };
  }
}
