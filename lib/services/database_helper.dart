// lib/services/database_helper.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import '../books_screen.dart';
import '../members_screen.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Cross-platform database factory
  DatabaseFactory get _factory {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit(); // Required for desktop
      return databaseFactoryFfi;
    }
    return databaseFactory; // Mobile (Android/iOS)
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('library.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await _getDatabasePath(fileName);
    return await _factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future<String> _getDatabasePath(String dbName) async {
    final databasesPath = await _factory.getDatabasesPath();
    return join(databasesPath, dbName);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        image TEXT NOT NULL,
        description TEXT NOT NULL,
        rating REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER,
        user TEXT NOT NULL,
        text TEXT NOT NULL,
        liked INTEGER DEFAULT 1,
        FOREIGN KEY (bookId) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        image TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
  }

  // Insert Book
  Future<Book> insertBook(Book book) async {
    final db = await instance.database;
    final id = await db.insert('books', {
      'title': book.title,
      'author': book.author,
      'image': book.image,
      'description': book.description,
      'rating': book.rating,
    });
    return book.copyWithId(id);
  }

  // Get All Books
  Future<List<Book>> getBooks() async {
    final db = await instance.database;
    final result = await db.query('books');
    List<Book> books = [];
    for (var map in result) {
      final bookId = map['id'] as int;
      final commentsResult = await db.query('comments', where: 'bookId = ?', whereArgs: [bookId]);
      final comments = commentsResult.map((c) => Comment(
        user: c['user'] as String,
        text: c['text'] as String,
        liked: (c['liked'] as int) == 1,
      )).toList();
      books.add(Book(
        id: bookId,
        title: map['title'] as String,
        author: map['author'] as String,
        image: map['image'] as String,
        description: map['description'] as String,
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        comments: comments,
      ));
    }
    return books;
  }

  Future<void> updateBook(Book book) async {
    final db = await instance.database;
    await db.update('books', {'rating': book.rating}, where: 'id = ?', whereArgs: [book.id]);
    await db.delete('comments', where: 'bookId = ?', whereArgs: [book.id]);
    for (var comment in book.comments) {
      await db.insert('comments', {
        'bookId': book.id,
        'user': comment.user,
        'text': comment.text,
        'liked': comment.liked ? 1 : 0,
      });
    }
  }

  Future<void> deleteBook(int id) async {
    final db = await instance.database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  // Members
  Future<Member> insertMember(Member member) async {
    final db = await instance.database;
    final id = await db.insert('members', {
      'name': member.name,
      'email': member.email,
      'image': member.image,
      'description': member.description,
    });
    return member.copyWithId(id);
  }

  Future<List<Member>> getMembers() async {
    final db = await instance.database;
    final result = await db.query('members');
    return result.map((map) => Member(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      image: map['image'] as String,
      description: map['description'] as String,
    )).toList();
  }

  Future<void> deleteMember(int id) async {
    final db = await instance.database;
    await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }
}