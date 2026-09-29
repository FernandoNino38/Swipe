import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável pela persistência das fotos já triadas (mantidas),
/// garantindo que fotos já revisadas não reapareçam no início da triagem ao reabrir o app.
class TriageHistoryService {
  static const String _keptPhotosKey = 'swipe_kept_photo_ids';
  static const String _hideKeptPhotosKey = 'swipe_hide_kept_photos';

  static SharedPreferences? _prefs;

  static void resetForTesting() {
    _prefs = null;
  }

  static Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Retorna o conjunto de IDs de fotos que já foram mantidas pelo usuário
  static Future<Set<String>> getKeptPhotoIds() async {
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(_keptPhotosKey) ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  /// Salva uma foto como mantida no armazenamento persistente local
  static Future<void> markAsKept(String photoId) async {
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(_keptPhotosKey) ?? [];
      if (!list.contains(photoId)) {
        list.add(photoId);
        await prefs.setStringList(_keptPhotosKey, list);
      }
    } catch (_) {}
  }

  /// Remove uma foto do histórico de mantidas (ex: ao desfazer a ação de manter)
  static Future<void> unmarkAsKept(String photoId) async {
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(_keptPhotosKey) ?? [];
      if (list.remove(photoId)) {
        await prefs.setStringList(_keptPhotosKey, list);
      }
    } catch (_) {}
  }

  /// Limpa todo o histórico de fotos mantidas (para triar tudo novamente)
  static Future<void> clearKeptHistory() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_keptPhotosKey);
    } catch (_) {}
  }

  static const String _imageFitModeKey = 'swipe_image_fit_mode';

  /// Preferência se deve ocultar fotos já mantidas (padrão true)
  static Future<bool> shouldHideKeptPhotos() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_hideKeptPhotosKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Define a preferência de ocultar fotos já mantidas
  static Future<void> setHideKeptPhotos(bool value) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_hideKeptPhotosKey, value);
    } catch (_) {}
  }

  /// Recupera o modo de exibição de imagens: true = Smart Fit (Completa), false = Fill (Preencher)
  static Future<bool> getFitMode() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_imageFitModeKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Salva a preferência de exibição de imagens
  static Future<void> setFitMode(bool isFit) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setBool(_imageFitModeKey, isFit);
    } catch (_) {}
  }
}
