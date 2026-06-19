class Serie {
  final String id;
  final String titulo;
  final String genero;
  final String estado;
  final double rating;
  final int temporadas;
  final String imagen;
  final String imagenOriginal;
  final String sinopsis;
  final String canal;
  final String fuente;
  final int? tvmazeId;
  final String? premieredYear;
  final String? idioma;

  Serie({
    required this.id,
    required this.titulo,
    required this.genero,
    required this.estado,
    required this.rating,
    required this.temporadas,
    required this.imagen,
    this.imagenOriginal = '',
    required this.sinopsis,
    required this.canal,
    required this.fuente,
    this.tvmazeId,
    this.premieredYear,
    this.idioma,
  });

  Map<String, dynamic> toMap() => {
        '_id': id,
        'titulo': titulo,
        'genero': genero,
        'estado': estado,
        'rating': rating,
        'temporadas': temporadas,
        'imagen': imagen,
        'imagenOriginal': imagenOriginal,
        'sinopsis': sinopsis,
        'canal': canal,
        'fuente': fuente,
        'tvmazeId': tvmazeId,
        'premieredYear': premieredYear,
        'idioma': idioma,
      };

  factory Serie.fromMap(Map<String, dynamic> map) => Serie(
        id: map['_id']?.toString() ?? '',
        titulo: map['titulo'] ?? '',
        genero: map['genero'] ?? '',
        estado: map['estado'] ?? '',
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        temporadas: (map['temporadas'] as num?)?.toInt() ?? 0,
        imagen: map['imagen'] ?? '',
        imagenOriginal: map['imagenOriginal'] ?? '',
        sinopsis: map['sinopsis'] ?? '',
        canal: map['canal'] ?? '',
        fuente: map['fuente'] ?? 'manual',
        tvmazeId: map['tvmazeId'] as int?,
        premieredYear: map['premieredYear'],
        idioma: map['idioma'],
      );

  factory Serie.fromTVMaze(Map<String, dynamic> show) {
    final generos = (show['genres'] as List?)?.cast<String>() ?? [];
    final sinopsis = (show['summary'] as String? ?? '')
        .replaceAll(RegExp(r'<[^>]*>'), '');
    final premiered = show['premiered'] as String?;
    final year = premiered != null && premiered.length >= 4
        ? premiered.substring(0, 4)
        : null;

    return Serie(
      id: '',
      titulo: show['name'] ?? 'Sin título',
      genero: generos.isNotEmpty ? generos.join(', ') : 'Desconocido',
      estado: show['status'] ?? 'Unknown',
      rating: (show['rating']?['average'] as num?)?.toDouble() ?? 0.0,
      temporadas: 0,
      imagen: show['image']?['medium'] ?? '',
      imagenOriginal: show['image']?['original'] ?? '',
      sinopsis: sinopsis,
      canal: show['network']?['name'] ??
          show['webChannel']?['name'] ?? 'Sin canal',
      fuente: 'TVMaze API',
      tvmazeId: show['id'] as int?,
      premieredYear: year,
      idioma: show['language'] as String?,
    );
  }

  Serie copyWith({
    String? id,
    String? titulo,
    String? genero,
    String? estado,
    double? rating,
    int? temporadas,
    String? imagen,
    String? imagenOriginal,
    String? sinopsis,
    String? canal,
    String? fuente,
    int? tvmazeId,
    String? premieredYear,
    String? idioma,
  }) =>
      Serie(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        genero: genero ?? this.genero,
        estado: estado ?? this.estado,
        rating: rating ?? this.rating,
        temporadas: temporadas ?? this.temporadas,
        imagen: imagen ?? this.imagen,
        imagenOriginal: imagenOriginal ?? this.imagenOriginal,
        sinopsis: sinopsis ?? this.sinopsis,
        canal: canal ?? this.canal,
        fuente: fuente ?? this.fuente,
        tvmazeId: tvmazeId ?? this.tvmazeId,
        premieredYear: premieredYear ?? this.premieredYear,
        idioma: idioma ?? this.idioma,
      );
}
