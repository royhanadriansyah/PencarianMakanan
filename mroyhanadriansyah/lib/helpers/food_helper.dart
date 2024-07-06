import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mroyhanadriansyah/models/food.dart';

class FoodHelper {
  static Database? _db;
  static final FoodHelper instance = FoodHelper._constructor();
  FoodHelper._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  final String _foodTableName = 'foods';
  final String _foodNameColumn = 'name';
  final String _foodCategoryColumn = 'category';
  final String _foodCountryColumn = 'country';
  final String _foodImageColumn = 'image';

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'foods.db');
    final database = await openDatabase(
      databasePath,
      version: 3,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_foodTableName (
            id INTEGER PRIMARY KEY,
            $_foodNameColumn TEXT NULL,
            $_foodCategoryColumn TEXT NULL,
            $_foodCountryColumn TEXT NULL,
            $_foodImageColumn TEXT NULL
          )
        ''');
      },
    );

    return database;
  }

  void insertData(String? name, String? category, String? country, String? image) async {
    final db = await database;
    await db.insert(_foodTableName, {
      _foodNameColumn: name,
      _foodCategoryColumn: category,
      _foodCountryColumn: country,
      _foodImageColumn: image
    });
  }

  void deleteData(int id) async {
    final db = await database;
    await db.delete(_foodTableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Food>> getAll() async {
    final db = await database;
    final data = await db.query(_foodTableName, orderBy: 'id DESC');

    List<Food> listData = data
      .map((e) => Food(
          id: e['id'] as int,
          name: e['name'] as String,
          category: e['category'] as String,
          country: e['country'] as String,
          image: e['image'] as String,
        ))
      .toList();

    return listData;
  }
}