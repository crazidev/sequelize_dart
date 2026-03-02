import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';

class FakeMongoDatabaseAdapter implements MongoDatabaseAdapter {
  final Map<String, FakeMongoCollectionAdapter> _collections = {};
  final Set<String> existingCollections = <String>{};
  bool _isConnected = false;
  Map<String, dynamic>? lastCreateCollectionCommand;
  Map<String, dynamic>? lastModifyCollectionCommand;
  String? lastDropCollectionName;
  List<Map<String, dynamic>> ensureUniqueIndexCalls = [];
  final Map<String, int> _sequenceValues = <String, int>{};
  final List<String> nextSequenceValueCalls = <String>[];

  @override
  Future<void> close() async {
    _isConnected = false;
  }

  @override
  MongoCollectionAdapter collection(String name) {
    existingCollections.add(name);
    return _collections.putIfAbsent(name, FakeMongoCollectionAdapter.new);
  }

  @override
  Future<void> connect() async {
    _isConnected = true;
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Future<bool> collectionExists(String name) async {
    return existingCollections.contains(name);
  }

  @override
  Future<void> createCollectionWithValidation({
    required String name,
    Map<String, dynamic>? validator,
    String? validationLevel,
    String? validationAction,
  }) async {
    existingCollections.add(name);
    lastCreateCollectionCommand = {
      'name': name,
      if (validator != null) 'validator': Map<String, dynamic>.from(validator),
      if (validationLevel != null) 'validationLevel': validationLevel,
      if (validationAction != null) 'validationAction': validationAction,
    };
  }

  @override
  Future<void> modifyCollectionValidation({
    required String name,
    Map<String, dynamic>? validator,
    String? validationLevel,
    String? validationAction,
  }) async {
    lastModifyCollectionCommand = {
      'name': name,
      if (validator != null) 'validator': Map<String, dynamic>.from(validator),
      if (validationLevel != null) 'validationLevel': validationLevel,
      if (validationAction != null) 'validationAction': validationAction,
    };
  }

  @override
  Future<void> dropCollectionIfExists(String name) async {
    existingCollections.remove(name);
    _collections.remove(name);
    lastDropCollectionName = name;
  }

  @override
  Future<void> ensureUniqueIndex({
    required String collectionName,
    required List<String> fields,
  }) async {
    ensureUniqueIndexCalls.add({
      'collectionName': collectionName,
      'fields': List<String>.from(fields),
    });
  }

  @override
  Future<int> nextSequenceValue({
    required String sequenceName,
  }) async {
    nextSequenceValueCalls.add(sequenceName);
    final current = _sequenceValues[sequenceName] ?? 0;
    final next = current + 1;
    _sequenceValues[sequenceName] = next;
    return next;
  }

  FakeMongoCollectionAdapter collectionAsFake(String name) {
    return collection(name) as FakeMongoCollectionAdapter;
  }
}

class FakeMongoCollectionAdapter implements MongoCollectionAdapter {
  Map<String, dynamic>? lastFindWhere;
  Map<String, int>? lastFindSort;
  int? lastFindLimit;
  int? lastFindSkip;
  Map<String, dynamic>? lastFindProjection;

  Map<String, dynamic>? lastFindOneWhere;
  Map<String, int>? lastFindOneSort;
  Map<String, dynamic>? lastFindOneProjection;

  List<Map<String, dynamic>>? lastAggregatePipeline;

  Map<String, dynamic>? lastUpdateManyWhere;
  Map<String, dynamic>? lastUpdateManyUpdate;

  Map<String, dynamic>? lastUpdateOneWhere;
  Map<String, dynamic>? lastUpdateOneUpdate;

  Map<String, dynamic>? lastDeleteManyWhere;
  Map<String, dynamic>? lastDeleteOneWhere;

  Map<String, dynamic>? lastInsertOneDocument;
  List<Map<String, dynamic>>? lastInsertManyDocuments;

  Map<String, dynamic>? lastReplaceOneWhere;
  Map<String, dynamic>? lastReplaceOneReplacement;
  bool? lastReplaceOneUpsert;

  int countResult = 0;
  int updateManyResult = 0;
  int updateOneResult = 0;
  int deleteManyResult = 0;
  int deleteOneResult = 0;

  List<Map<String, dynamic>> findResult = const [];
  Map<String, dynamic>? findOneResult;
  List<Map<String, dynamic>> aggregateResult = const [];
  Map<String, dynamic>? insertOneResult;
  List<Map<String, dynamic>> insertManyResult = const [];
  Map<String, dynamic>? replaceOneResult;

  @override
  Future<List<Map<String, dynamic>>> aggregate(
    List<Map<String, dynamic>> pipeline,
  ) async {
    lastAggregatePipeline =
        pipeline.map((item) => Map<String, dynamic>.from(item)).toList();
    return aggregateResult
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Future<int> count(Map<String, dynamic> where) async {
    lastFindWhere = Map<String, dynamic>.from(where);
    return countResult;
  }

  @override
  Future<int> deleteMany({
    required Map<String, dynamic> where,
  }) async {
    lastDeleteManyWhere = Map<String, dynamic>.from(where);
    return deleteManyResult;
  }

  @override
  Future<int> deleteOne({
    required Map<String, dynamic> where,
  }) async {
    lastDeleteOneWhere = Map<String, dynamic>.from(where);
    return deleteOneResult;
  }

  @override
  Future<List<Map<String, dynamic>>> find({
    Map<String, dynamic>? where,
    Map<String, int>? sort,
    int? limit,
    int? skip,
    Map<String, dynamic>? projection,
  }) async {
    lastFindWhere = where == null ? null : Map<String, dynamic>.from(where);
    lastFindSort = sort == null ? null : Map<String, int>.from(sort);
    lastFindLimit = limit;
    lastFindSkip = skip;
    lastFindProjection =
        projection == null ? null : Map<String, dynamic>.from(projection);
    return findResult.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  @override
  Future<Map<String, dynamic>?> findOne({
    Map<String, dynamic>? where,
    Map<String, int>? sort,
    Map<String, dynamic>? projection,
  }) async {
    lastFindOneWhere = where == null ? null : Map<String, dynamic>.from(where);
    lastFindOneSort = sort == null ? null : Map<String, int>.from(sort);
    lastFindOneProjection =
        projection == null ? null : Map<String, dynamic>.from(projection);
    final result = findOneResult;
    return result == null ? null : Map<String, dynamic>.from(result);
  }

  @override
  Future<List<Map<String, dynamic>>> insertMany(
    List<Map<String, dynamic>> documents,
  ) async {
    lastInsertManyDocuments =
        documents.map((item) => Map<String, dynamic>.from(item)).toList();
    if (insertManyResult.isNotEmpty) {
      return insertManyResult
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return documents.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  @override
  Future<Map<String, dynamic>> insertOne(Map<String, dynamic> document) async {
    lastInsertOneDocument = Map<String, dynamic>.from(document);
    if (insertOneResult != null) {
      return Map<String, dynamic>.from(insertOneResult!);
    }
    return Map<String, dynamic>.from(document);
  }

  @override
  Future<Map<String, dynamic>> replaceOne({
    required Map<String, dynamic> where,
    required Map<String, dynamic> replacement,
    bool upsert = false,
  }) async {
    lastReplaceOneWhere = Map<String, dynamic>.from(where);
    lastReplaceOneReplacement = Map<String, dynamic>.from(replacement);
    lastReplaceOneUpsert = upsert;
    if (replaceOneResult != null) {
      return Map<String, dynamic>.from(replaceOneResult!);
    }
    return Map<String, dynamic>.from(replacement);
  }

  @override
  Future<int> updateMany({
    required Map<String, dynamic> where,
    required Map<String, dynamic> update,
  }) async {
    lastUpdateManyWhere = Map<String, dynamic>.from(where);
    lastUpdateManyUpdate = Map<String, dynamic>.from(update);
    return updateManyResult;
  }

  @override
  Future<int> updateOne({
    required Map<String, dynamic> where,
    required Map<String, dynamic> update,
  }) async {
    lastUpdateOneWhere = Map<String, dynamic>.from(where);
    lastUpdateOneUpdate = Map<String, dynamic>.from(update);
    return updateOneResult;
  }
}
