import 'package:photo_manager/photo_manager.dart';

/// Representa um álbum ou pasta da galeria física do dispositivo (ex: Câmera, Screenshots, WhatsApp)
class GalleryAlbum {
  final String id;
  final String name;
  final int assetCount;
  final AssetPathEntity? pathEntity;

  const GalleryAlbum({
    required this.id,
    required this.name,
    required this.assetCount,
    this.pathEntity,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryAlbum &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
