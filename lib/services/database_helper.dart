import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite storage. Every lookup API used by the app has its own table
/// (counters, deities, poojas, stars, gothra, rashi, special stars, payment
/// modes, quick-bill poojas) so it can be shown when there is no network.
/// `pending_bills` queues bills saved offline until they can be synced, and
/// `temple` remembers the last bill's temple header for offline receipts.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      'punnyam.db',
    );

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS counters');
        await db.execute('DROP TABLE IF EXISTS Counter');
        await db.execute('DROP TABLE IF EXISTS Dities');
        await db.execute('DROP TABLE IF EXISTS Poojas');
        await _onCreate(db, newVersion);
      },
    );
  }

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE counters (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE deities (
        id INTEGER PRIMARY KEY,
        name TEXT,
        name_mal TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE poojas (
        deity_id INTEGER,
        deity_pooja_id INTEGER,
        pooja_id INTEGER,
        name TEXT,
        name_mal TEXT,
        rate TEXT,
        row_count INTEGER,
        PRIMARY KEY (deity_id, pooja_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stars (
        id INTEGER PRIMARY KEY,
        name_eng TEXT,
        name_mal TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE gothra (
        id INTEGER PRIMARY KEY,
        name_eng TEXT,
        name_locale TEXT,
        status INTEGER,
        deleted INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE rashi (
        id INTEGER PRIMARY KEY,
        name_eng TEXT,
        name_locale TEXT,
        status INTEGER,
        deleted INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE special_stars (
        row_id INTEGER PRIMARY KEY AUTOINCREMENT,
        other_code TEXT,
        other_detail TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_modes (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE quick_bill_poojas (
        id INTEGER PRIMARY KEY,
        name TEXT,
        rate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE temple (
        id INTEGER PRIMARY KEY,
        name TEXT,
        name_mal TEXT,
        address_line_1 TEXT,
        address_line_2 TEXT,
        phone TEXT,
        email TEXT,
        website TEXT
      )
    ''');
  }

  // ------------------------------------------------------------
  // INSERT / UPDATE COUNTERS
  // ------------------------------------------------------------

  Future<void> insertCounters(List<Map<String, dynamic>> counters) async {
    final db = await database;

    final batch = db.batch();

    for (final counter in counters) {
      batch.insert(
        'counters',
        counter,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // ------------------------------------------------------------
  // GET ALL COUNTERS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getCounters() async {
    final db = await database;

    return await db.query(
      'counters',
      orderBy: 'id ASC',
    );
  }

  // ------------------------------------------------------------
  // DELETE ALL COUNTERS
  // ------------------------------------------------------------

  Future<void> clearCounters() async {
    final db = await database;

    await db.delete('counters');
  }

  // ------------------------------------------------------------
  // DEITIES
  // ------------------------------------------------------------

  Future<void> insertDeities(List<Map<String, dynamic>> deities) async {
    final db = await database;
    final batch = db.batch();
    for (final deity in deities) {
      batch.insert('deities', deity,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getDeities() async {
    final db = await database;
    return await db.query('deities', orderBy: 'id ASC');
  }

  Future<void> clearDeities() async {
    final db = await database;
    await db.delete('deities');
  }

  // ------------------------------------------------------------
  // POOJAS (scoped to a deity)
  // ------------------------------------------------------------

  Future<void> insertPoojas(
      String deityId, List<Map<String, dynamic>> poojas) async {
    final db = await database;
    final batch = db.batch();
    for (final pooja in poojas) {
      batch.insert(
        'poojas',
        {...pooja, 'deity_id': int.tryParse(deityId) ?? 0},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getPoojas(String deityId) async {
    final db = await database;
    return await db.query(
      'poojas',
      where: 'deity_id = ?',
      whereArgs: [int.tryParse(deityId) ?? 0],
      orderBy: 'pooja_id ASC',
    );
  }

  Future<void> clearPoojas(String deityId) async {
    final db = await database;
    await db.delete(
      'poojas',
      where: 'deity_id = ?',
      whereArgs: [int.tryParse(deityId) ?? 0],
    );
  }

  // ------------------------------------------------------------
  // STARS
  // ------------------------------------------------------------

  Future<void> insertStars(List<Map<String, dynamic>> stars) async {
    final db = await database;
    final batch = db.batch();
    for (final star in stars) {
      batch.insert('stars', star,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getStars() async {
    final db = await database;
    return await db.query('stars', orderBy: 'id ASC');
  }

  Future<void> clearStars() async {
    final db = await database;
    await db.delete('stars');
  }

  // ------------------------------------------------------------
  // GOTHRA
  // ------------------------------------------------------------

  Future<void> insertGothra(List<Map<String, dynamic>> gothra) async {
    final db = await database;
    final batch = db.batch();
    for (final item in gothra) {
      batch.insert('gothra', item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getGothra() async {
    final db = await database;
    return await db.query('gothra', orderBy: 'id ASC');
  }

  Future<void> clearGothra() async {
    final db = await database;
    await db.delete('gothra');
  }

  // ------------------------------------------------------------
  // RASHI
  // ------------------------------------------------------------

  Future<void> insertRashi(List<Map<String, dynamic>> rashi) async {
    final db = await database;
    final batch = db.batch();
    for (final item in rashi) {
      batch.insert('rashi', item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getRashi() async {
    final db = await database;
    return await db.query('rashi', orderBy: 'id ASC');
  }

  Future<void> clearRashi() async {
    final db = await database;
    await db.delete('rashi');
  }

  // ------------------------------------------------------------
  // SPECIAL STARS
  // ------------------------------------------------------------

  Future<void> insertSpecialStars(
      List<Map<String, dynamic>> specialStars) async {
    final db = await database;
    final batch = db.batch();
    for (final item in specialStars) {
      batch.insert('special_stars', item);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getSpecialStars() async {
    final db = await database;
    return await db.query('special_stars', orderBy: 'row_id ASC');
  }

  Future<void> clearSpecialStars() async {
    final db = await database;
    await db.delete('special_stars');
  }

  // ------------------------------------------------------------
  // PAYMENT MODES
  // ------------------------------------------------------------

  Future<void> insertPaymentModes(
      List<Map<String, dynamic>> paymentModes) async {
    final db = await database;
    final batch = db.batch();
    for (final mode in paymentModes) {
      batch.insert('payment_modes', mode,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getPaymentModes() async {
    final db = await database;
    return await db.query('payment_modes', orderBy: 'id ASC');
  }

  Future<void> clearPaymentModes() async {
    final db = await database;
    await db.delete('payment_modes');
  }

  // ------------------------------------------------------------
  // QUICK BILL POOJAS
  // ------------------------------------------------------------

  Future<void> insertQuickBillPoojas(
      List<Map<String, dynamic>> quickBillPoojas) async {
    final db = await database;
    final batch = db.batch();
    for (final item in quickBillPoojas) {
      batch.insert('quick_bill_poojas', item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getQuickBillPoojas() async {
    final db = await database;
    return await db.query('quick_bill_poojas', orderBy: 'id ASC');
  }

  Future<void> clearQuickBillPoojas() async {
    final db = await database;
    await db.delete('quick_bill_poojas');
  }

  // ------------------------------------------------------------
  // PENDING BILLS (saved offline, waiting to sync)
  // ------------------------------------------------------------

  Future<int> insertPendingBill(String payload) async {
    final db = await database;
    return db.insert('pending_bills', {
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingBills() async {
    final db = await database;
    return db.query('pending_bills', orderBy: 'id ASC');
  }

  Future<int> pendingBillCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM pending_bills');
    return result.first['count'] as int;
  }

  Future<void> deletePendingBill(int id) async {
    final db = await database;
    await db.delete('pending_bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markPendingBillFailed(int id, String error) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE pending_bills SET attempts = attempts + 1, last_error = ? WHERE id = ?',
      [error, id],
    );
  }

  // ------------------------------------------------------------
  // TEMPLE (header shown on the receipt; needed to print offline)
  // ------------------------------------------------------------

  Future<void> saveTemple(Map<String, dynamic> temple) async {
    final db = await database;
    await db.insert(
      'temple',
      {...temple, 'id': 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getTemple() async {
    final db = await database;
    final rows = await db.query('temple', where: 'id = 1', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }
}
