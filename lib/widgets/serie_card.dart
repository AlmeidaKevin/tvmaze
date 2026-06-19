import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../theme.dart';

class SerieCard extends StatelessWidget {
  final Serie serie;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool saved; // marca verde si ya está en colección

  const SerieCard({
    super.key,
    required this.serie,
    this.onTap,
    this.trailing,
    this.saved = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: saved ? AppTheme.green.withOpacity(0.5) : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
              child: Stack(
                children: [
                  serie.imagen.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: serie.imagen,
                          width: 68,
                          height: 96,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _poster(),
                          errorWidget: (_, __, ___) => _poster(),
                        )
                      : _poster(),
                  if (saved)
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppTheme.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 10, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serie.titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      serie.genero,
                      style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (serie.rating > 0) ...[
                          const Icon(Icons.star_rounded,
                              size: 13, color: AppTheme.orange),
                          const SizedBox(width: 2),
                          Text(
                            serie.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                color: AppTheme.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _statusDot(serie.estado),
                        const SizedBox(width: 4),
                        Text(serie.estado,
                            style: const TextStyle(
                                color: AppTheme.muted, fontSize: 11)),
                      ],
                    ),
                    if (serie.canal.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(serie.canal,
                            style: const TextStyle(
                                color: AppTheme.muted, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _poster() => Container(
        width: 68,
        height: 96,
        color: AppTheme.surface,
        child: const Icon(Icons.tv, color: AppTheme.muted, size: 26),
      );

  Widget _statusDot(String status) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: status == 'Running' ? AppTheme.green : AppTheme.muted,
        ),
      );
}
