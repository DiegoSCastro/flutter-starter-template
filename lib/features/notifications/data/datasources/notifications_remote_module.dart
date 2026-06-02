import 'package:core_network/core_network.dart';
import 'package:injectable/injectable.dart';

import 'notifications_remote_data_source.dart';

@module
abstract class NotificationsRemoteModule {
  @lazySingleton
  NotificationsRemoteDataSource provideNotificationsRemoteDataSource(Dio dio) =>
      NotificationsRemoteDataSource(dio);
}
