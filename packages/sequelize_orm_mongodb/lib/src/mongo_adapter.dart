abstract class MongoDatabaseAdapter {
  Future<void> connect();

  Future<void> close();

  bool get isConnected;

  MongoCollectionAdapter collection(String name);

  Future<bool> collectionExists(String name);

  Future<void> createCollectionWithValidation({
    required String name,
    Map<String, dynamic>? validator,
    String? validationLevel,
    String? validationAction,
  });

  Future<void> modifyCollectionValidation({
    required String name,
    Map<String, dynamic>? validator,
    String? validationLevel,
    String? validationAction,
  });

  Future<void> dropCollectionIfExists(String name);

  Future<void> ensureUniqueIndex({
    required String collectionName,
    required List<String> fields,
  });

  Future<int> nextSequenceValue({
    required String sequenceName,
  });
}

abstract class MongoCollectionAdapter {
  Future<List<Map<String, dynamic>>> find({
    Map<String, dynamic>? where,
    Map<String, int>? sort,
    int? limit,
    int? skip,
    Map<String, dynamic>? projection,
  });

  Future<Map<String, dynamic>?> findOne({
    Map<String, dynamic>? where,
    Map<String, int>? sort,
    Map<String, dynamic>? projection,
  });

  Future<Map<String, dynamic>> insertOne(Map<String, dynamic> document);

  Future<List<Map<String, dynamic>>> insertMany(
    List<Map<String, dynamic>> documents,
  );

  Future<int> updateMany({
    required Map<String, dynamic> where,
    required Map<String, dynamic> update,
  });

  Future<int> updateOne({
    required Map<String, dynamic> where,
    required Map<String, dynamic> update,
  });

  Future<int> deleteMany({
    required Map<String, dynamic> where,
  });

  Future<int> deleteOne({
    required Map<String, dynamic> where,
  });

  Future<int> count(Map<String, dynamic> where);

  Future<List<Map<String, dynamic>>> aggregate(
    List<Map<String, dynamic>> pipeline,
  );

  Future<Map<String, dynamic>> replaceOne({
    required Map<String, dynamic> where,
    required Map<String, dynamic> replacement,
    bool upsert = false,
  });
}
