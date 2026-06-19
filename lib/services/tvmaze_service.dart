import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/serie.dart';

class TVMazeService {
  static const _base = 'https://api.tvmaze.com';

  static Future<List<Serie>> getShows({required int page}) async {
    final response = await http.get(Uri.parse('$_base/shows?page=$page'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((s) => Serie.fromTVMaze(s as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Error TVMaze: ${response.statusCode}');
  }

  static Future<List<Serie>> searchShows(String query) async {
    final response = await http.get(
        Uri.parse('$_base/search/shows?q=${Uri.encodeComponent(query)}'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((r) => Serie.fromTVMaze(r['show'] as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error búsqueda: ${response.statusCode}');
  }

  // Detalle completo desde TVMaze (incluye más campos)
  static Future<Map<String, dynamic>> getShowDetail(int id) async {
    final response = await http.get(Uri.parse('$_base/shows/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Error detalle: ${response.statusCode}');
  }

  // Series por género
  static Future<List<Serie>> getByGenre(String genre, {int page = 0}) async {
    // TVMaze no filtra por género directamente; traemos página y filtramos
    final shows = await getShows(page: page);
    return shows
        .where((s) => s.genero.toLowerCase().contains(genre.toLowerCase()))
        .toList();
  }

  // Top rated (traemos varias páginas y ordenamos)
  static Future<List<Serie>> getTopRated() async {
    final List<Serie> all = [];
    for (int p = 0; p < 3; p++) {
      all.addAll(await getShows(page: p));
    }
    all.sort((a, b) => b.rating.compareTo(a.rating));
    return all.where((s) => s.rating > 0).take(50).toList();
  }
}
