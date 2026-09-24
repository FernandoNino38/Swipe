import 'package:flutter_test/flutter_test.dart';
import 'package:photo_triage/domain/controllers/triage_controller.dart';
import 'package:photo_triage/domain/models/album_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TriageController Core Loop & Business Logic Tests', () {
    late TriageController controller;

    setUp(() async {
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
  });
}
