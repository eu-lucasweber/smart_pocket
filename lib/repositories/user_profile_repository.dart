import 'package:smart_pocket/database/database_helper.dart';
import 'package:smart_pocket/models/user_profile.dart';

class UserProfileRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<UserProfile?> getUserProfile() async {
    final db = await _databaseHelper.database;

    final result = await db.query('user_profile', limit: 1);

    if (result.isEmpty) return null;

    return UserProfile.fromMap(result.first);
  }

  Future<void> updateCurrency(UserProfile userProfile) async {
    final db = await _databaseHelper.database;

    await db.update(
      'user_profile',
      {'currency': userProfile.currency},
      where: 'id = ?',
      whereArgs: [userProfile.id],
    );
  }
}
