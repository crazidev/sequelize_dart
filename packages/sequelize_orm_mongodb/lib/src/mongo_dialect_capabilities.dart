class DialectCapabilities {
  final bool supportsLike;
  final bool supportsRegex;
  final bool supportsILike;
  final bool supportsJoin;
  final bool supportsTruncate;
  final bool supportsSync;
  final bool supportsGroup;
  final bool supportsBetween;
  final bool supportsColComparison;
  final bool supportsMatch;
  final bool supportsCollectionGroup;
  final bool supportsSubCollections;
  final int maxWhereInValues;
  final int maxOrClauses;

  const DialectCapabilities({
    required this.supportsLike,
    required this.supportsRegex,
    required this.supportsILike,
    required this.supportsJoin,
    required this.supportsTruncate,
    required this.supportsSync,
    required this.supportsGroup,
    required this.supportsBetween,
    required this.supportsColComparison,
    required this.supportsMatch,
    required this.supportsCollectionGroup,
    required this.supportsSubCollections,
    required this.maxWhereInValues,
    required this.maxOrClauses,
  });
}

class MongoDialectCapabilities {
  const MongoDialectCapabilities._();

  static const mongodb = DialectCapabilities(
    supportsLike: true,
    supportsRegex: true,
    supportsILike: true,
    supportsJoin: true,
    supportsTruncate: true,
    supportsSync: true,
    supportsGroup: true,
    supportsBetween: true,
    supportsColComparison: true,
    supportsMatch: false,
    supportsCollectionGroup: false,
    supportsSubCollections: false,
    maxWhereInValues: -1,
    maxOrClauses: -1,
  );
}
