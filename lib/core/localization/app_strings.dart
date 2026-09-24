import 'package:flutter/material.dart';

/// Gerenciador de internacionalização (Português e Inglês)
/// Detecta automaticamente o idioma do sistema ou permite alternância manual.
class AppStrings {
  final Locale locale;

  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings(locale);
  }

  bool get isEnglish => locale.languageCode == 'en';

  // App & Navegação
  String get appTitle => isEnglish ? 'Photo Triage' : 'Triagem de Fotos';
  String get selectAlbum => isEnglish ? 'Select Album' : 'Selecionar Álbum';
  String get selectAlbumPrompt => isEnglish
      ? 'Choose the gallery folder you want to triage:'
      : 'Escolha a pasta da galeria que deseja triar:';
  String get allPhotos => isEnglish ? 'All Photos' : 'Todas as Fotos';
  String get noAlbumsFound => isEnglish ? 'No albums found on device.' : 'Nenhum álbum encontrado no dispositivo.';
  String photosCount(int current, int total) =>
      isEnglish ? '$current of $total photos' : '$current de $total fotos';
  String albumPhotos(int count) => isEnglish ? '$count photos' : '$count fotos';

  // Decisões dos Cards
  String get keep => isEnglish ? 'KEEP' : 'MANTER';
  String get delete => isEnglish ? 'DELETE' : 'EXCLUIR';
  String get undo => isEnglish ? 'Undo' : 'Desfazer';
  String get keepTooltip => isEnglish ? 'Keep Photo' : 'Manter Foto';
  String get deleteTooltip => isEnglish ? 'Discard / Delete' : 'Descartar / Excluir';

  // Favoritos
  String get favorites => isEnglish ? 'Favorites' : 'Favoritos';
  String get addedToFavorites => isEnglish ? 'Photo added to Favorites!' : 'Foto adicionada aos Favoritos!';
  String get favoriteTooltip => isEnglish ? 'Favorite Photo' : 'Favoritar Foto';

  // Lixeira & Revisão
  String get trash => isEnglish ? 'Trash' : 'Lixeira';
  String get reviewTrash => isEnglish ? 'Review Trash' : 'Revisar Lixeira';
  String get reviewTrashTitle => isEnglish ? 'Trash Review' : 'Revisão da Lixeira';
  String photosForDeletion(int count) =>
      isEnglish ? '$count photos marked for deletion' : '$count fotos para exclusão';
  String willFreeStorage(String storage) =>
      isEnglish ? 'Will free $storage of storage' : 'Liberará $storage de armazenamento';
  String permanentlyDeleteBtn(String storage) =>
      isEnglish ? 'Permanently Delete ($storage)' : 'Excluir Definitivamente ($storage)';
  String get emptyTrashTitle => isEnglish ? 'No photos in trash' : 'Nenhuma foto na lixeira';
  String get emptyTrashDesc => isEnglish
      ? 'Photos swiped left will appear here for your review before permanent deletion.'
      : 'As fotos descartadas deslizando para a esquerda aparecerão aqui para sua confirmação antes da exclusão física.';

  // Diálogo de confirmação de exclusão
  String get confirmDeleteTitle => isEnglish ? 'Permanent Deletion' : 'Exclusão Definitiva';
  String confirmDeleteMessage(int count, String storage) => isEnglish
      ? 'Do you want to permanently delete $count photos? This will free $storage of storage and request native OS permission.'
      : 'Deseja autorizar a exclusão física de $count fotos? Esta ação liberará $storage do armazenamento do aparelho e solicitará a confirmação nativa do sistema operacional.';
  String get cancel => isEnglish ? 'Cancel' : 'Cancelar';
  String get yesDelete => isEnglish ? 'Yes, Delete' : 'Sim, Excluir';
  String get deleteSuccess => isEnglish ? 'Photos deleted successfully!' : 'Fotos excluídas com sucesso!';
  String get deleteFailed => isEnglish ? 'Deletion cancelled or failed.' : 'Falha ou cancelamento na exclusão pelo sistema.';

  // Sessão Concluída
  String get sessionComplete => isEnglish ? 'Session Complete!' : 'Sessão Concluída!';
  String sessionSummary(int count, String storage) => isEnglish
      ? 'All photos evaluated.\n$count photos marked for deletion ($storage to free).'
      : 'Todas as fotos foram avaliadas.\n$count fotos marcadas para exclusão ($storage de espaço a liberar).';
  String get reviewAndFreeBtn => isEnglish ? 'Review & Free Space' : 'Revisar e Liberar Espaço';
  String get restartTriageBtn => isEnglish ? 'Restart Triage' : 'Reiniciar Triagem';
  String get changeAlbumBtn => isEnglish ? 'Change Album' : 'Trocar de Álbum';

  // Detalhes da Foto
  String get imageDetails => isEnglish ? 'Image Details' : 'Detalhes da Imagem';
  String get date => isEnglish ? 'Date' : 'Data';
  String get atTime => isEnglish ? 'at' : 'às';
  String get dimensions => isEnglish ? 'Dimensions' : 'Dimensões';
}
