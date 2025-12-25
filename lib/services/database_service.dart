import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/user.dart';
import '../models/delivery_challan.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('delivery_challan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Initialize FFI for desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(
      appDocumentsDir.path,
      'delivery_challan',
      filePath,
    );

    // Create directory if it doesn't exist
    final Directory dbDir = Directory(dirname(dbPath));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        role TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    // Delivery Challans table
    await db.execute('''
      CREATE TABLE delivery_challans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_to TEXT NOT NULL,
        date TEXT NOT NULL,
        invoiceNo TEXT NOT NULL,
        refName TEXT NOT NULL,
        cellNo TEXT NOT NULL,
        dcNo TEXT NOT NULL,
        grade TEXT NOT NULL,
        purchaseOrderNo TEXT NOT NULL,
        items TEXT NOT NULL,
        driverName TEXT NOT NULL,
        driverCellNo TEXT NOT NULL,
        amount TEXT NOT NULL,
        tmGateOutKms TEXT NOT NULL,
        siteInTime TEXT NOT NULL,
        sgst TEXT NOT NULL,
        tmGateInKms TEXT NOT NULL,
        siteOutTime TEXT NOT NULL,
        cgst TEXT NOT NULL,
        grandTotal TEXT NOT NULL,
        createdBy TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        pdfPath1 TEXT,
        pdfPath2 TEXT,
        pdfPath3 TEXT
      )
    ''');

    // Create default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123', // In production, use proper hashing
      'fullName': 'Administrator',
      'role': 'admin',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // User CRUD operations
  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND isActive = 1',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  // Delivery Challan CRUD operations
  Future<DeliveryChallan> createChallan(DeliveryChallan challan) async {
    final db = await instance.database;
    final id = await db.insert('delivery_challans', challan.toMap());
    return challan.copyWith(id: id);
  }

  Future<DeliveryChallan?> getChallan(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'delivery_challans',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DeliveryChallan.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DeliveryChallan>> getAllChallans() async {
    final db = await instance.database;
    final result = await db.query(
      'delivery_challans',
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => DeliveryChallan.fromMap(map)).toList();
  }

  Future<int> updateChallan(DeliveryChallan challan) async {
    final db = await instance.database;
    return await db.update(
      'delivery_challans',
      challan.toMap(),
      where: 'id = ?',
      whereArgs: [challan.id],
    );
  }

  Future<int> deleteChallan(int id) async {
    final db = await instance.database;
    return await db.delete(
      'delivery_challans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}

extension UserCopyWith on User {
  User copyWith({
    int? id,
    String? username,
    String? password,
    String? fullName,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
