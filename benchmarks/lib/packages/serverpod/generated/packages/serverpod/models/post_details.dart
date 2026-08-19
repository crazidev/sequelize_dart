/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class PostDetail
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PostDetail._({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory PostDetail({
    int? id,
    int? likes,
    String? metadata,
    int? postId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PostDetailImpl;

  factory PostDetail.fromJson(Map<String, dynamic> jsonSerialization) {
    return PostDetail(
      id: jsonSerialization['id'] as int?,
      likes: jsonSerialization['likes'] as int?,
      metadata: jsonSerialization['metadata'] as String?,
      postId: jsonSerialization['postId'] as int?,
      userId: jsonSerialization['userId'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = PostDetailTable();

  static const db = PostDetailRepository._();

  @override
  int? id;

  int? likes;

  String? metadata;

  int? postId;

  int? userId;

  DateTime? createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PostDetail]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PostDetail copyWith({
    int? id,
    int? likes,
    String? metadata,
    int? postId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PostDetail',
      if (id != null) 'id': id,
      if (likes != null) 'likes': likes,
      if (metadata != null) 'metadata': metadata,
      if (postId != null) 'postId': postId,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PostDetail',
      if (id != null) 'id': id,
      if (likes != null) 'likes': likes,
      if (metadata != null) 'metadata': metadata,
      if (postId != null) 'postId': postId,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static PostDetailInclude include() {
    return PostDetailInclude._();
  }

  static PostDetailIncludeList includeList({
    _i1.WhereExpressionBuilder<PostDetailTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PostDetailTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PostDetailTable>? orderByList,
    PostDetailInclude? include,
  }) {
    return PostDetailIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PostDetail.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PostDetail.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PostDetailImpl extends PostDetail {
  _PostDetailImpl({
    int? id,
    int? likes,
    String? metadata,
    int? postId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         likes: likes,
         metadata: metadata,
         postId: postId,
         userId: userId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PostDetail]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PostDetail copyWith({
    Object? id = _Undefined,
    Object? likes = _Undefined,
    Object? metadata = _Undefined,
    Object? postId = _Undefined,
    Object? userId = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return PostDetail(
      id: id is int? ? id : this.id,
      likes: likes is int? ? likes : this.likes,
      metadata: metadata is String? ? metadata : this.metadata,
      postId: postId is int? ? postId : this.postId,
      userId: userId is int? ? userId : this.userId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class PostDetailUpdateTable extends _i1.UpdateTable<PostDetailTable> {
  PostDetailUpdateTable(super.table);

  _i1.ColumnValue<int, int> likes(int? value) => _i1.ColumnValue(
    table.likes,
    value,
  );

  _i1.ColumnValue<String, String> metadata(String? value) => _i1.ColumnValue(
    table.metadata,
    value,
  );

  _i1.ColumnValue<int, int> postId(int? value) => _i1.ColumnValue(
    table.postId,
    value,
  );

  _i1.ColumnValue<int, int> userId(int? value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class PostDetailTable extends _i1.Table<int?> {
  PostDetailTable({super.tableRelation}) : super(tableName: 'post_details') {
    updateTable = PostDetailUpdateTable(this);
    likes = _i1.ColumnInt(
      'likes',
      this,
    );
    metadata = _i1.ColumnString(
      'metadata',
      this,
    );
    postId = _i1.ColumnInt(
      'post_id',
      this,
      fieldName: 'postId',
    );
    userId = _i1.ColumnInt(
      'user_id',
      this,
      fieldName: 'userId',
    );
    createdAt = _i1.ColumnDateTime(
      'created_at',
      this,
      fieldName: 'createdAt',
    );
    updatedAt = _i1.ColumnDateTime(
      'updated_at',
      this,
      fieldName: 'updatedAt',
    );
  }

  late final PostDetailUpdateTable updateTable;

  late final _i1.ColumnInt likes;

  late final _i1.ColumnString metadata;

  late final _i1.ColumnInt postId;

  late final _i1.ColumnInt userId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    likes,
    metadata,
    postId,
    userId,
    createdAt,
    updatedAt,
  ];
}

class PostDetailInclude extends _i1.IncludeObject {
  PostDetailInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PostDetail.t;
}

class PostDetailIncludeList extends _i1.IncludeList {
  PostDetailIncludeList._({
    _i1.WhereExpressionBuilder<PostDetailTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PostDetail.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PostDetail.t;
}

class PostDetailRepository {
  const PostDetailRepository._();

  /// Returns a list of [PostDetail]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<PostDetail>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PostDetailTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PostDetailTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PostDetailTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PostDetail>(
      where: where?.call(PostDetail.t),
      orderBy: orderBy?.call(PostDetail.t),
      orderByList: orderByList?.call(PostDetail.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PostDetail] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<PostDetail?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PostDetailTable>? where,
    int? offset,
    _i1.OrderByBuilder<PostDetailTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PostDetailTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PostDetail>(
      where: where?.call(PostDetail.t),
      orderBy: orderBy?.call(PostDetail.t),
      orderByList: orderByList?.call(PostDetail.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PostDetail] by its [id] or null if no such row exists.
  Future<PostDetail?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PostDetail>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PostDetail]s in the list and returns the inserted rows.
  ///
  /// The returned [PostDetail]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PostDetail>> insert(
    _i1.DatabaseSession session,
    List<PostDetail> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PostDetail>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PostDetail] and returns the inserted row.
  ///
  /// The returned [PostDetail] will have its `id` field set.
  Future<PostDetail> insertRow(
    _i1.DatabaseSession session,
    PostDetail row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PostDetail>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PostDetail]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PostDetail>> update(
    _i1.DatabaseSession session,
    List<PostDetail> rows, {
    _i1.ColumnSelections<PostDetailTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PostDetail>(
      rows,
      columns: columns?.call(PostDetail.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PostDetail]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PostDetail> updateRow(
    _i1.DatabaseSession session,
    PostDetail row, {
    _i1.ColumnSelections<PostDetailTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PostDetail>(
      row,
      columns: columns?.call(PostDetail.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PostDetail] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PostDetail?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PostDetailUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PostDetail>(
      id,
      columnValues: columnValues(PostDetail.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PostDetail]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PostDetail>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PostDetailUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PostDetailTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PostDetailTable>? orderBy,
    _i1.OrderByListBuilder<PostDetailTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PostDetail>(
      columnValues: columnValues(PostDetail.t.updateTable),
      where: where(PostDetail.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PostDetail.t),
      orderByList: orderByList?.call(PostDetail.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PostDetail]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PostDetail>> delete(
    _i1.DatabaseSession session,
    List<PostDetail> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PostDetail>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PostDetail].
  Future<PostDetail> deleteRow(
    _i1.DatabaseSession session,
    PostDetail row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PostDetail>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PostDetail>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PostDetailTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PostDetail>(
      where: where(PostDetail.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PostDetailTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PostDetail>(
      where: where?.call(PostDetail.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PostDetail] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PostDetailTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PostDetail>(
      where: where(PostDetail.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
