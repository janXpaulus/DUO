import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class HostConnectionStorageProvider extends ChangeNotifier {
  Future<Database?> openDb() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      '$path/connections_to_host.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          '''CREATE TABLE connections_to_host(
            playerId INTEGER PRIMARY KEY AUTOINCREMENT,
            notifyCharacteristicUuid TEXT,
            writeCharacteristicUuid TEXT
          )''',
        );
      },
    );
  }
}
