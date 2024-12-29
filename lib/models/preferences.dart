import 'package:hive/hive.dart';

@HiveType(typeId: 1) // Type ID for Preferences model in Hive
class Preferences {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  String sortOrder; // 'date', 'priority'

  Preferences({this.isDarkMode = false, this.sortOrder = 'date'});

  // Convert Preferences to Map for Hive storage
  factory Preferences.fromMap(Map<String, dynamic> map) {
    return Preferences(
      isDarkMode: map['isDarkMode'],
      sortOrder: map['sortOrder'],
    );
  }

  // Convert Preferences to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'sortOrder': sortOrder,
    };
  }
}
