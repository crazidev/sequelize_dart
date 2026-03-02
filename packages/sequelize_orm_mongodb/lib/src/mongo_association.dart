enum MongoAssociationType {
  hasOne,
  hasMany,
  belongsTo,
}

class MongoAssociationDefinition {
  final String sourceModel;
  final String associationName;
  final String targetCollection;
  final MongoAssociationType associationType;
  final String localField;
  final String foreignField;
  final String as;

  const MongoAssociationDefinition({
    required this.sourceModel,
    required this.associationName,
    required this.targetCollection,
    required this.associationType,
    required this.localField,
    required this.foreignField,
    String? as,
  }) : as = as ?? associationName;
}

typedef MongoAssociationResolver = MongoAssociationDefinition? Function({
  required String sourceModel,
  required String associationName,
});
