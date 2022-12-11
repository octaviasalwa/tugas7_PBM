import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items( 
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        buku TEXT, 
        keterangan TEXT, 
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
      ) 
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'flutter.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Membuat item baru
  static Future<int> createItem(String buku, String? keterangan) async {
    final db = await SQLHelper.db();

    final data = {'buku': buku, 'keterangan': keterangan};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Membaca item
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Mengupdate data
  static Future<int> updateItem(int id, String buku, String? keterangan) async {
    final db = await SQLHelper.db();

    final data = {
      'buku': buku,
      'keterangan': keterangan,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Menghapus data
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Tidak dapat menghapus: $err");
    }
  }
}
