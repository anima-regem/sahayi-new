import 'package:hive_flutter/adapters.dart';
part 'data_model.g.dart';

@HiveType(typeId: 1)
class SubjectsModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  SubjectsModel({required this.id, required this.name});
}
