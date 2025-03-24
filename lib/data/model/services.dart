class Services {
  String title;
  String id;
  num basicPrice;
  String coefficientId;
  String description;

  Services({
    required this.title,
    required this.id,
    required this.basicPrice,
    required this.coefficientId,
    required this.description,
  });

  factory Services.fromJson(Map<String, dynamic> map) {
    return Services(
      title: map['title'] ?? 'Unknown Title',
      id: map['_id'] ?? 'Unknown ID',
      basicPrice: map['basicPrice'] ?? 0,
      coefficientId: map['coefficient_id'] ?? 'Unknown Coefficient',
      description: map['description'] ?? 'No description available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "_id": id,
      "basicPrice": basicPrice,
      "coefficient_id": coefficientId,
      "description": description,
    };
  }

  @override
  String toString() {
    return 'Services{title: $title, id: $id, basicPrice: $basicPrice, coefficientId: $coefficientId, description: $description}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Services &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          id == other.id &&
          basicPrice == other.basicPrice &&
          coefficientId == other.coefficientId &&
          description == other.description;

  @override
  int get hashCode =>
      title.hashCode ^
      id.hashCode ^
      basicPrice.hashCode ^
      coefficientId.hashCode ^
      description.hashCode;
}
