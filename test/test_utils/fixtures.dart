import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';

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
