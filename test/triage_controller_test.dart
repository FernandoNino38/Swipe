import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_triage/core/services/media_service.dart';
import 'package:photo_triage/core/services/triage_history_service.dart';
import 'package:photo_triage/domain/controllers/triage_controller.dart';
import 'package:photo_triage/domain/models/album_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TriageController Core Loop & Business Logic Tests', () {
    late TriageController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      TriageHistoryService.resetForTesting();
      controller = TriageController();
      await controller.initialize();
    });

    test('Initial state contains items and clean queues', () {
      expect(controller.items.isNotEmpty, isTrue);
      expect(controller.currentIndex, equals(0));
      expect(controller.softDeleteCount, equals(0));
      expect(controller.keptCount, equals(0));
      expect(controller.canUndo, isFalse);
    });

    test('Swipe Right moves item to kept list and advances deck', () async {
      final initialItem = controller.currentItem;
      expect(initialItem, isNotNull);

      await controller.swipeRight();

      expect(controller.currentIndex, equals(1));
      expect(controller.keptCount, equals(1));
      expect(controller.softDeleteCount, equals(0));
      expect(controller.canUndo, isTrue);
    });

    test('Swipe Left performs soft-delete and accumulates reclaimable storage', () async {
      final initialItem = controller.currentItem!;
      final expectedBytes = initialItem.fileSizeBytes;

      await controller.swipeLeft();

      expect(controller.currentIndex, equals(1));
      expect(controller.softDeleteCount, equals(1));
      expect(controller.softDeleteQueue.first.id, equals(initialItem.id));
      expect(controller.totalReclaimableBytes, equals(expectedBytes));
      expect(controller.canUndo, isTrue);
    });

    test('Undo immediately restores soft-deleted item to top of deck', () async {
      final initialItem = controller.currentItem!;

      await controller.swipeLeft();
      expect(controller.currentIndex, equals(1));
      expect(controller.softDeleteCount, equals(1));

      // Executa o Desfazer (Undo)
      await controller.undo();

      expect(controller.currentIndex, equals(0));
      expect(controller.currentItem!.id, equals(initialItem.id));
      expect(controller.softDeleteCount, equals(0));
      expect(controller.canUndo, isFalse);
    });

    test('Quick Album action categorizes photo and records action', () async {
      final initialItem = controller.currentItem!;
      final album = AlbumItem.defaultAlbums.first;

      await controller.moveToAlbum(album);

      expect(controller.currentIndex, equals(1));
      expect(controller.canUndo, isTrue);

      // Reverter ação de pasta
      await controller.undo();
      expect(controller.currentIndex, equals(0));
      expect(controller.currentItem!.id, equals(initialItem.id));
    });

    test('Restore directly from Soft-Delete queue', () async {
      final initialItem = controller.currentItem!;
      await controller.swipeLeft();
      expect(controller.softDeleteCount, equals(1));

      controller.restoreFromSoftDelete(initialItem);
      expect(controller.softDeleteCount, equals(0));
    });

    test('Favorite current photo adds to favorites and advances deck, undo reverts it', () async {
      final initialItem = controller.currentItem!;
      expect(controller.favoritesCount, equals(0));

      await controller.favoriteCurrentPhoto();
      expect(controller.currentIndex, equals(1));
      expect(controller.favoritesCount, equals(1));
      expect(controller.canUndo, isTrue);

      await controller.undo();
      expect(controller.currentIndex, equals(0));
      expect(controller.currentItem!.id, equals(initialItem.id));
      expect(controller.favoritesCount, equals(0));
    });

    test('Locale switcher toggles between Portuguese and English', () {
      expect(controller.customLocale, isNull);

      controller.toggleLocale();
      expect(controller.customLocale?.languageCode, equals('en'));

      controller.toggleLocale();
      expect(controller.customLocale?.languageCode, equals('pt'));
    });

    test('Batch limit can be updated and reloads items', () async {
      expect(controller.batchLimit, equals(100));

      await controller.setBatchLimit(30);
      expect(controller.batchLimit, equals(30));
      expect(controller.items.isNotEmpty, isTrue);

      await controller.setBatchLimit(0); // 0 = all
      expect(controller.batchLimit, equals(0));
    });

    test('PhotoSortOrder can be changed and reloads items', () async {
      expect(controller.sortOrder, equals(PhotoSortOrder.newest));

      await controller.setSortOrder(PhotoSortOrder.largest);
      expect(controller.sortOrder, equals(PhotoSortOrder.largest));
      expect(controller.items.isNotEmpty, isTrue);

      await controller.setSortOrder(PhotoSortOrder.oldest);
      expect(controller.sortOrder, equals(PhotoSortOrder.oldest));
    });

    test('ThemeMode can be toggled and set explicitly', () {
      expect(controller.themeMode, equals(ThemeMode.system));

      controller.toggleThemeMode();
      expect(controller.themeMode, equals(ThemeMode.light));

      controller.toggleThemeMode();
      expect(controller.themeMode, equals(ThemeMode.dark));

      controller.toggleThemeMode();
      expect(controller.themeMode, equals(ThemeMode.system));

      controller.setThemeMode(ThemeMode.dark);
      expect(controller.themeMode, equals(ThemeMode.dark));
    });

    test('Favorites gallery allows un-favoriting items', () async {
      final item = controller.currentItem!;
      await controller.favoriteCurrentPhoto();

      expect(controller.favoritesCount, equals(1));
      expect(controller.favoriteItems.length, equals(1));
      expect(controller.favoriteItems.first.id, equals(item.id));

      controller.removeFromFavorites(item);
      expect(controller.favoritesCount, equals(0));
      expect(controller.favoriteItems.isEmpty, isTrue);
    });

    test('Swiping right persists kept photo and re-initialize skips already kept photos', () async {
      final firstItemId = controller.currentItem!.id;
      await controller.swipeRight();
      expect(controller.persistentKeptCount, equals(1));

      // Simulando reabertura do aplicativo
      final newSessionController = TriageController();
      await newSessionController.initialize();

      // A foto mantida não deve ser mais carregada na nova sessão
      expect(newSessionController.items.any((i) => i.id == firstItemId), isFalse);

      // Desabilitando a opção de ocultar fotos mantidas traz ela de volta
      await newSessionController.toggleHideKeptPhotos();
      expect(newSessionController.items.any((i) => i.id == firstItemId), isTrue);
    });

    test('Undo removes kept photo from persistent history', () async {
      final firstItemId = controller.currentItem!.id;
      await controller.swipeRight();
      expect(controller.persistentKeptCount, equals(1));

      await controller.undo();
      expect(controller.persistentKeptCount, equals(0));

      final newSessionController = TriageController();
      await newSessionController.initialize();
      expect(newSessionController.items.any((i) => i.id == firstItemId), isTrue);
    });
  });
}
