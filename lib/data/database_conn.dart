/// 数据库连接——按平台分离
/// Web → database_conn_web.dart (using drift/web.dart)
/// Native → database_conn_native.dart (using drift/native.dart + dart:io)
export 'database_conn_web.dart' if (dart.library.io) 'database_conn_native.dart';