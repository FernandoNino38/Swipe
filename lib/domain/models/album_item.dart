import 'package:flutter/material.dart';

/// Representa um álbum/pasta de destino rápido na barra de ações
class AlbumItem {
  final String id;
  final String name;
  final IconData icon;
  final Color? accentColor;

  const AlbumItem({
    required this.id,
    required this.name,
    required this.icon,
    this.accentColor,
  });

  /// Lista padrão de pastas rápidas sugeridas para triagem
  static const List<AlbumItem> defaultAlbums = [
    AlbumItem(
      id: 'favorites',
      name: 'Favoritos',
      icon: Icons.favorite_rounded,
      accentColor: Color(0xFFE91E63),
    ),
    AlbumItem(
      id: 'trips',
      name: 'Viagens',
      icon: Icons.flight_takeoff_rounded,
      accentColor: Color(0xFF00BCD4),
    ),
    AlbumItem(
      id: 'family',
      name: 'Família',
      icon: Icons.people_rounded,
      accentColor: Color(0xFFFF9800),
    ),
    AlbumItem(
      id: 'work',
      name: 'Trabalho',
      icon: Icons.work_rounded,
      accentColor: Color(0xFF3F51B5),
    ),
    AlbumItem(
      id: 'documents',
      name: 'Documentos',
      icon: Icons.receipt_long_rounded,
      accentColor: Color(0xFF4CAF50),
    ),
  ];
}
