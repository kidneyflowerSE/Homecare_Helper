class CostFactor {
  String id;
  String title;
  String description;
  String applyTo;
  String status;
  bool deleted;
  List<Coefficient> coefficientList;

  CostFactor({
    required this.id,
    required this.title,
    required this.description,
    required this.applyTo,
    required this.status,
    required this.deleted,
    required this.coefficientList,
  });

  factory CostFactor.fromJson(Map<String, dynamic> map) {
    return CostFactor(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      applyTo: map['applyTo'] ?? '',
      status: map['status'] ?? '',
      deleted: map['deleted'] ?? false,
      coefficientList: (map['coefficientList'] as List<dynamic>)
          .map((e) => Coefficient.fromJson(e))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CostFactor &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          applyTo == other.applyTo &&
          status == other.status &&
          deleted == other.deleted &&
          coefficientList == other.coefficientList;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      applyTo.hashCode ^
      status.hashCode ^
      deleted.hashCode ^
      coefficientList.hashCode;

  @override
  String toString() {
    return 'CostFactor{id: $id, title: $title, description: $description, applyTo: $applyTo, status: $status, deleted: $deleted, coefficientList: $coefficientList}';
  }
}

class Coefficient {
  String id;
  String title;
  String description;
  double value;
  bool deleted;
  String status;

  Coefficient({
    required this.id,
    required this.title,
    required this.description,
    required this.value,
    required this.deleted,
    required this.status,
  });

  factory Coefficient.fromJson(Map<String, dynamic> map) {
    return Coefficient(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      value: (map['value'] as num?)?.toDouble() ?? 0.0, // Xử lý nếu null
      deleted: map['deleted'] ?? false,
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "description": description,
      "value": value,
      "deleted": deleted,
      "status": status,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coefficient &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          value == other.value &&
          deleted == other.deleted &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      value.hashCode ^
      deleted.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'Coefficient{id: $id, title: $title, description: $description, value: $value, deleted: $deleted, status: $status}';
  }
}
