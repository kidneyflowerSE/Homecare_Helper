import 'package:homecare_helper/data/model/cost_factor.dart';

class CoefficientOther {
  final String id;
  final String title;
  final String description;
  final String applyTo;
  final String status;
  final bool deleted;
  final List<Coefficient> coefficientList;

  CoefficientOther({
    required this.id,
    required this.title,
    required this.description,
    required this.applyTo,
    required this.status,
    required this.deleted,
    required this.coefficientList,
  });

  factory CoefficientOther.fromJson(Map<String, dynamic> json) {
    return CoefficientOther(
      id: json["_id"] ?? '',
      title: json["title"] ?? '',
      description: json["description"] ?? '',
      applyTo: json["applyTo"] ?? '',
      status: json["status"] ?? '',
      deleted: json["deleted"] ?? false,
      coefficientList: (json["coefficientList"] as List<dynamic>?)
              ?.map((item) => Coefficient.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "description": description,
      "applyTo": applyTo,
      "status": status,
      "deleted": deleted,
      "coefficientList": coefficientList.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CoefficientOther(id: $id, title: $title, coefficientList: ${coefficientList.length})';
  }
}
