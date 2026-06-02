import 'package:core_domain/core_domain.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/shared/domain/entities/auth_user.dart';

const testUser = AuthUser(id: 'user-1', username: 'alice');

const testFailure = UnknownFailure('Something went wrong');

final testBookmark = Bookmark(
  id: '1',
  title: 'Flutter',
  url: 'https://flutter.dev',
  description: 'Flutter website',
  tags: ['dev'],
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

final testBookmark2 = Bookmark(
  id: '2',
  title: 'Dart',
  url: 'https://dart.dev',
  description: 'Dart website',
  tags: ['lang'],
  createdAt: DateTime(2025, 1, 2),
  updatedAt: DateTime(2025, 1, 2),
);
