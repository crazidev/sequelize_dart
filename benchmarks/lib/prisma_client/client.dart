// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:orm/dmmf.dart' as _i4;
import 'package:orm/engines/binary.dart' as _i5;
import 'package:orm/orm.dart' as _i1;

import 'model.dart' as _i2;
import 'prisma.dart' as _i3;

class UsersDelegate {
  const UsersDelegate._(this._client);

  final PrismaClient _client;

  _i1.ActionClient<_i2.Users?> findUnique({
    required _i3.UsersWhereUniqueInput where,
    _i3.UsersSelect? select,
    _i3.UsersInclude? include,
  }) {
    final args = {'where': where, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.findUnique,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Users?>(
      action: 'findUniqueUsers',
      result: result,
      factory: (e) => e != null ? _i2.Users.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i2.Users> findUniqueOrThrow({
    required _i3.UsersWhereUniqueInput where,
    _i3.UsersSelect? select,
    _i3.UsersInclude? include,
  }) {
    final args = {'where': where, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.findUniqueOrThrow,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Users>(
      action: 'findUniqueUsersOrThrow',
      result: result,
      factory: (e) => _i2.Users.fromJson(e),
    );
  }

  _i1.ActionClient<_i2.Users?> findFirst({
    _i3.UsersWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.UsersOrderByWithRelationInput>,
      _i3.UsersOrderByWithRelationInput
    >?
    orderBy,
    _i3.UsersWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i1.PrismaUnion<_i3.UsersScalar, Iterable<_i3.UsersScalar>>? distinct,
    _i3.UsersSelect? select,
    _i3.UsersInclude? include,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'distinct': distinct,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.findFirst,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Users?>(
      action: 'findFirstUsers',
      result: result,
      factory: (e) => e != null ? _i2.Users.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i2.Users> findFirstOrThrow({
    _i3.UsersWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.UsersOrderByWithRelationInput>,
      _i3.UsersOrderByWithRelationInput
    >?
    orderBy,
    _i3.UsersWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i1.PrismaUnion<_i3.UsersScalar, Iterable<_i3.UsersScalar>>? distinct,
    _i3.UsersSelect? select,
    _i3.UsersInclude? include,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'distinct': distinct,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.findFirstOrThrow,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Users>(
      action: 'findFirstUsersOrThrow',
      result: result,
      factory: (e) => _i2.Users.fromJson(e),
    );
  }

  _i1.ActionClient<Iterable<_i2.Users>> findMany({
    _i3.UsersWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.UsersOrderByWithRelationInput>,
      _i3.UsersOrderByWithRelationInput
    >?
    orderBy,
    _i3.UsersWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i1.PrismaUnion<_i3.UsersScalar, Iterable<_i3.UsersScalar>>? distinct,
    _i3.UsersSelect? select,
    _i3.UsersInclude? include,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'distinct': distinct,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.findMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<Iterable<_i2.Users>>(
      action: 'findManyUsers',
      result: result,
      factory: (values) =>
          (values as Iterable).map((e) => _i2.Users.fromJson(e)),
    );
  }

  _i1.ActionClient<_i2.Users> create({
    _i1.PrismaUnion<_i3.UsersCreateInput, _i3.UsersUncheckedCreateInput>? data,
    _i3.UsersSelect? select,
    _i3.UsersInclude? include,
  }) {
    final args = {'data': data, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.createOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Users>(
      action: 'createOneUsers',
      result: result,
      factory: (e) => _i2.Users.fromJson(e),
    );
  }

  _i1.ActionClient<_i3.AffectedRowsOutput> createMany({
    required _i1.PrismaUnion<
      _i3.UsersCreateManyInput,
      Iterable<_i3.UsersCreateManyInput>
    >
    data,
    bool? skipDuplicates,
  }) {
    final args = {'data': data, 'skipDuplicates': skipDuplicates};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.createMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AffectedRowsOutput>(
      action: 'createManyUsers',
      result: result,
      factory: (e) => _i3.AffectedRowsOutput.fromJson(e),
    );
  }

  _i1.ActionClient<Iterable<_i2.CreateManyUsersAndReturnOutputType>>
  createManyAndReturn({
    required _i1.PrismaUnion<
      _i3.UsersCreateManyInput,
      Iterable<_i3.UsersCreateManyInput>
    >
    data,
    bool? skipDuplicates,
    _i3.CreateManyUsersAndReturnOutputTypeSelect? select,
  }) {
    final args = {
      'data': data,
      'skipDuplicates': skipDuplicates,
      'select': select,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.createManyAndReturn,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<Iterable<_i2.CreateManyUsersAndReturnOutputType>>(
      action: 'createManyUsersAndReturn',
      result: result,
      factory: (values) => (values as Iterable).map(
        (e) => _i2.CreateManyUsersAndReturnOutputType.fromJson(e),
      ),
    );
  }

  _i1.ActionClient<_i2.Users?> update({
    required _i1.PrismaUnion<
      _i3.UsersUpdateInput,
      _i3.UsersUncheckedUpdateInput
    >
    data,
    required _i3.UsersWhereUniqueInput where,
    _i3.UsersSelect? select,
    _i3.UsersInclude? include,
  }) {
    final args = {
      'data': data,
      'where': where,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.updateOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Users?>(
      action: 'updateOneUsers',
      result: result,
      factory: (e) => e != null ? _i2.Users.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i3.AffectedRowsOutput> updateMany({
    required _i1.PrismaUnion<
      _i3.UsersUpdateManyMutationInput,
      _i3.UsersUncheckedUpdateManyInput
    >
    data,
    _i3.UsersWhereInput? where,
  }) {
    final args = {'data': data, 'where': where};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.updateMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AffectedRowsOutput>(
      action: 'updateManyUsers',
      result: result,
      factory: (e) => _i3.AffectedRowsOutput.fromJson(e),
    );
  }

  _i1.ActionClient<_i2.Users> upsert({
    required _i3.UsersWhereUniqueInput where,
    required _i1.PrismaUnion<
      _i3.UsersCreateInput,
      _i3.UsersUncheckedCreateInput
    >
    create,
    required _i1.PrismaUnion<
      _i3.UsersUpdateInput,
      _i3.UsersUncheckedUpdateInput
    >
    update,
    _i3.UsersSelect? select,
    _i3.UsersInclude? include,
  }) {
    final args = {
      'where': where,
      'create': create,
      'update': update,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.upsertOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Users>(
      action: 'upsertOneUsers',
      result: result,
      factory: (e) => _i2.Users.fromJson(e),
    );
  }

  _i1.ActionClient<_i2.Users?> delete({
    required _i3.UsersWhereUniqueInput where,
    _i3.UsersSelect? select,
    _i3.UsersInclude? include,
  }) {
    final args = {'where': where, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.deleteOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Users?>(
      action: 'deleteOneUsers',
      result: result,
      factory: (e) => e != null ? _i2.Users.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i3.AffectedRowsOutput> deleteMany({
    _i3.UsersWhereInput? where,
  }) {
    final args = {'where': where};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.deleteMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AffectedRowsOutput>(
      action: 'deleteManyUsers',
      result: result,
      factory: (e) => _i3.AffectedRowsOutput.fromJson(e),
    );
  }

  _i1.ActionClient<Iterable<_i3.UsersGroupByOutputType>> groupBy({
    _i3.UsersWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.UsersOrderByWithAggregationInput>,
      _i3.UsersOrderByWithAggregationInput
    >?
    orderBy,
    required _i1.PrismaUnion<Iterable<_i3.UsersScalar>, _i3.UsersScalar> by,
    _i3.UsersScalarWhereWithAggregatesInput? having,
    int? take,
    int? skip,
    _i3.UsersGroupByOutputTypeSelect? select,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'by': _i1.JsonQuery.groupBySerializer(by),
      'having': having,
      'take': take,
      'skip': skip,
      'select': select ?? _i1.JsonQuery.groupBySelectSerializer(by),
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.groupBy,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<Iterable<_i3.UsersGroupByOutputType>>(
      action: 'groupByUsers',
      result: result,
      factory: (values) => (values as Iterable).map(
        (e) => _i3.UsersGroupByOutputType.fromJson(e),
      ),
    );
  }

  _i1.ActionClient<_i3.AggregateUsers> aggregate({
    _i3.UsersWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.UsersOrderByWithRelationInput>,
      _i3.UsersOrderByWithRelationInput
    >?
    orderBy,
    _i3.UsersWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i3.AggregateUsersSelect? select,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'select': select,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Users',
      action: _i1.JsonQueryAction.aggregate,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AggregateUsers>(
      action: 'aggregateUsers',
      result: result,
      factory: (e) => _i3.AggregateUsers.fromJson(e),
    );
  }
}

class PostsDelegate {
  const PostsDelegate._(this._client);

  final PrismaClient _client;

  _i1.ActionClient<_i2.Posts?> findUnique({
    required _i3.PostsWhereUniqueInput where,
    _i3.PostsSelect? select,
    _i3.PostsInclude? include,
  }) {
    final args = {'where': where, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.findUnique,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Posts?>(
      action: 'findUniquePosts',
      result: result,
      factory: (e) => e != null ? _i2.Posts.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i2.Posts> findUniqueOrThrow({
    required _i3.PostsWhereUniqueInput where,
    _i3.PostsSelect? select,
    _i3.PostsInclude? include,
  }) {
    final args = {'where': where, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.findUniqueOrThrow,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Posts>(
      action: 'findUniquePostsOrThrow',
      result: result,
      factory: (e) => _i2.Posts.fromJson(e),
    );
  }

  _i1.ActionClient<_i2.Posts?> findFirst({
    _i3.PostsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostsOrderByWithRelationInput>,
      _i3.PostsOrderByWithRelationInput
    >?
    orderBy,
    _i3.PostsWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i1.PrismaUnion<_i3.PostsScalar, Iterable<_i3.PostsScalar>>? distinct,
    _i3.PostsSelect? select,
    _i3.PostsInclude? include,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'distinct': distinct,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.findFirst,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Posts?>(
      action: 'findFirstPosts',
      result: result,
      factory: (e) => e != null ? _i2.Posts.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i2.Posts> findFirstOrThrow({
    _i3.PostsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostsOrderByWithRelationInput>,
      _i3.PostsOrderByWithRelationInput
    >?
    orderBy,
    _i3.PostsWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i1.PrismaUnion<_i3.PostsScalar, Iterable<_i3.PostsScalar>>? distinct,
    _i3.PostsSelect? select,
    _i3.PostsInclude? include,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'distinct': distinct,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.findFirstOrThrow,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Posts>(
      action: 'findFirstPostsOrThrow',
      result: result,
      factory: (e) => _i2.Posts.fromJson(e),
    );
  }

  _i1.ActionClient<Iterable<_i2.Posts>> findMany({
    _i3.PostsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostsOrderByWithRelationInput>,
      _i3.PostsOrderByWithRelationInput
    >?
    orderBy,
    _i3.PostsWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i1.PrismaUnion<_i3.PostsScalar, Iterable<_i3.PostsScalar>>? distinct,
    _i3.PostsSelect? select,
    _i3.PostsInclude? include,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'distinct': distinct,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.findMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<Iterable<_i2.Posts>>(
      action: 'findManyPosts',
      result: result,
      factory: (values) =>
          (values as Iterable).map((e) => _i2.Posts.fromJson(e)),
    );
  }

  _i1.ActionClient<_i2.Posts> create({
    _i1.PrismaUnion<_i3.PostsCreateInput, _i3.PostsUncheckedCreateInput>? data,
    _i3.PostsSelect? select,
    _i3.PostsInclude? include,
  }) {
    final args = {'data': data, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.createOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Posts>(
      action: 'createOnePosts',
      result: result,
      factory: (e) => _i2.Posts.fromJson(e),
    );
  }

  _i1.ActionClient<_i3.AffectedRowsOutput> createMany({
    required _i1.PrismaUnion<
      _i3.PostsCreateManyInput,
      Iterable<_i3.PostsCreateManyInput>
    >
    data,
    bool? skipDuplicates,
  }) {
    final args = {'data': data, 'skipDuplicates': skipDuplicates};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.createMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AffectedRowsOutput>(
      action: 'createManyPosts',
      result: result,
      factory: (e) => _i3.AffectedRowsOutput.fromJson(e),
    );
  }

  _i1.ActionClient<Iterable<_i2.CreateManyPostsAndReturnOutputType>>
  createManyAndReturn({
    required _i1.PrismaUnion<
      _i3.PostsCreateManyInput,
      Iterable<_i3.PostsCreateManyInput>
    >
    data,
    bool? skipDuplicates,
    _i3.CreateManyPostsAndReturnOutputTypeSelect? select,
    _i3.CreateManyPostsAndReturnOutputTypeInclude? include,
  }) {
    final args = {
      'data': data,
      'skipDuplicates': skipDuplicates,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.createManyAndReturn,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<Iterable<_i2.CreateManyPostsAndReturnOutputType>>(
      action: 'createManyPostsAndReturn',
      result: result,
      factory: (values) => (values as Iterable).map(
        (e) => _i2.CreateManyPostsAndReturnOutputType.fromJson(e),
      ),
    );
  }

  _i1.ActionClient<_i2.Posts?> update({
    required _i1.PrismaUnion<
      _i3.PostsUpdateInput,
      _i3.PostsUncheckedUpdateInput
    >
    data,
    required _i3.PostsWhereUniqueInput where,
    _i3.PostsSelect? select,
    _i3.PostsInclude? include,
  }) {
    final args = {
      'data': data,
      'where': where,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.updateOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Posts?>(
      action: 'updateOnePosts',
      result: result,
      factory: (e) => e != null ? _i2.Posts.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i3.AffectedRowsOutput> updateMany({
    required _i1.PrismaUnion<
      _i3.PostsUpdateManyMutationInput,
      _i3.PostsUncheckedUpdateManyInput
    >
    data,
    _i3.PostsWhereInput? where,
  }) {
    final args = {'data': data, 'where': where};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.updateMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AffectedRowsOutput>(
      action: 'updateManyPosts',
      result: result,
      factory: (e) => _i3.AffectedRowsOutput.fromJson(e),
    );
  }

  _i1.ActionClient<_i2.Posts> upsert({
    required _i3.PostsWhereUniqueInput where,
    required _i1.PrismaUnion<
      _i3.PostsCreateInput,
      _i3.PostsUncheckedCreateInput
    >
    create,
    required _i1.PrismaUnion<
      _i3.PostsUpdateInput,
      _i3.PostsUncheckedUpdateInput
    >
    update,
    _i3.PostsSelect? select,
    _i3.PostsInclude? include,
  }) {
    final args = {
      'where': where,
      'create': create,
      'update': update,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.upsertOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Posts>(
      action: 'upsertOnePosts',
      result: result,
      factory: (e) => _i2.Posts.fromJson(e),
    );
  }

  _i1.ActionClient<_i2.Posts?> delete({
    required _i3.PostsWhereUniqueInput where,
    _i3.PostsSelect? select,
    _i3.PostsInclude? include,
  }) {
    final args = {'where': where, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.deleteOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.Posts?>(
      action: 'deleteOnePosts',
      result: result,
      factory: (e) => e != null ? _i2.Posts.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i3.AffectedRowsOutput> deleteMany({
    _i3.PostsWhereInput? where,
  }) {
    final args = {'where': where};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.deleteMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AffectedRowsOutput>(
      action: 'deleteManyPosts',
      result: result,
      factory: (e) => _i3.AffectedRowsOutput.fromJson(e),
    );
  }

  _i1.ActionClient<Iterable<_i3.PostsGroupByOutputType>> groupBy({
    _i3.PostsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostsOrderByWithAggregationInput>,
      _i3.PostsOrderByWithAggregationInput
    >?
    orderBy,
    required _i1.PrismaUnion<Iterable<_i3.PostsScalar>, _i3.PostsScalar> by,
    _i3.PostsScalarWhereWithAggregatesInput? having,
    int? take,
    int? skip,
    _i3.PostsGroupByOutputTypeSelect? select,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'by': _i1.JsonQuery.groupBySerializer(by),
      'having': having,
      'take': take,
      'skip': skip,
      'select': select ?? _i1.JsonQuery.groupBySelectSerializer(by),
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.groupBy,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<Iterable<_i3.PostsGroupByOutputType>>(
      action: 'groupByPosts',
      result: result,
      factory: (values) => (values as Iterable).map(
        (e) => _i3.PostsGroupByOutputType.fromJson(e),
      ),
    );
  }

  _i1.ActionClient<_i3.AggregatePosts> aggregate({
    _i3.PostsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostsOrderByWithRelationInput>,
      _i3.PostsOrderByWithRelationInput
    >?
    orderBy,
    _i3.PostsWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i3.AggregatePostsSelect? select,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'select': select,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'Posts',
      action: _i1.JsonQueryAction.aggregate,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AggregatePosts>(
      action: 'aggregatePosts',
      result: result,
      factory: (e) => _i3.AggregatePosts.fromJson(e),
    );
  }
}

class PostDetailsDelegate {
  const PostDetailsDelegate._(this._client);

  final PrismaClient _client;

  _i1.ActionClient<_i2.PostDetails?> findUnique({
    required _i3.PostDetailsWhereUniqueInput where,
    _i3.PostDetailsSelect? select,
    _i3.PostDetailsInclude? include,
  }) {
    final args = {'where': where, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.findUnique,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.PostDetails?>(
      action: 'findUniquePostDetails',
      result: result,
      factory: (e) => e != null ? _i2.PostDetails.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i2.PostDetails> findUniqueOrThrow({
    required _i3.PostDetailsWhereUniqueInput where,
    _i3.PostDetailsSelect? select,
    _i3.PostDetailsInclude? include,
  }) {
    final args = {'where': where, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.findUniqueOrThrow,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.PostDetails>(
      action: 'findUniquePostDetailsOrThrow',
      result: result,
      factory: (e) => _i2.PostDetails.fromJson(e),
    );
  }

  _i1.ActionClient<_i2.PostDetails?> findFirst({
    _i3.PostDetailsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostDetailsOrderByWithRelationInput>,
      _i3.PostDetailsOrderByWithRelationInput
    >?
    orderBy,
    _i3.PostDetailsWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i1.PrismaUnion<_i3.PostDetailsScalar, Iterable<_i3.PostDetailsScalar>>?
    distinct,
    _i3.PostDetailsSelect? select,
    _i3.PostDetailsInclude? include,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'distinct': distinct,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.findFirst,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.PostDetails?>(
      action: 'findFirstPostDetails',
      result: result,
      factory: (e) => e != null ? _i2.PostDetails.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i2.PostDetails> findFirstOrThrow({
    _i3.PostDetailsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostDetailsOrderByWithRelationInput>,
      _i3.PostDetailsOrderByWithRelationInput
    >?
    orderBy,
    _i3.PostDetailsWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i1.PrismaUnion<_i3.PostDetailsScalar, Iterable<_i3.PostDetailsScalar>>?
    distinct,
    _i3.PostDetailsSelect? select,
    _i3.PostDetailsInclude? include,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'distinct': distinct,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.findFirstOrThrow,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.PostDetails>(
      action: 'findFirstPostDetailsOrThrow',
      result: result,
      factory: (e) => _i2.PostDetails.fromJson(e),
    );
  }

  _i1.ActionClient<Iterable<_i2.PostDetails>> findMany({
    _i3.PostDetailsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostDetailsOrderByWithRelationInput>,
      _i3.PostDetailsOrderByWithRelationInput
    >?
    orderBy,
    _i3.PostDetailsWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i1.PrismaUnion<_i3.PostDetailsScalar, Iterable<_i3.PostDetailsScalar>>?
    distinct,
    _i3.PostDetailsSelect? select,
    _i3.PostDetailsInclude? include,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'distinct': distinct,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.findMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<Iterable<_i2.PostDetails>>(
      action: 'findManyPostDetails',
      result: result,
      factory: (values) =>
          (values as Iterable).map((e) => _i2.PostDetails.fromJson(e)),
    );
  }

  _i1.ActionClient<_i2.PostDetails> create({
    _i1.PrismaUnion<
      _i3.PostDetailsCreateInput,
      _i3.PostDetailsUncheckedCreateInput
    >?
    data,
    _i3.PostDetailsSelect? select,
    _i3.PostDetailsInclude? include,
  }) {
    final args = {'data': data, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.createOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.PostDetails>(
      action: 'createOnePostDetails',
      result: result,
      factory: (e) => _i2.PostDetails.fromJson(e),
    );
  }

  _i1.ActionClient<_i3.AffectedRowsOutput> createMany({
    required _i1.PrismaUnion<
      _i3.PostDetailsCreateManyInput,
      Iterable<_i3.PostDetailsCreateManyInput>
    >
    data,
    bool? skipDuplicates,
  }) {
    final args = {'data': data, 'skipDuplicates': skipDuplicates};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.createMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AffectedRowsOutput>(
      action: 'createManyPostDetails',
      result: result,
      factory: (e) => _i3.AffectedRowsOutput.fromJson(e),
    );
  }

  _i1.ActionClient<Iterable<_i2.CreateManyPostDetailsAndReturnOutputType>>
  createManyAndReturn({
    required _i1.PrismaUnion<
      _i3.PostDetailsCreateManyInput,
      Iterable<_i3.PostDetailsCreateManyInput>
    >
    data,
    bool? skipDuplicates,
    _i3.CreateManyPostDetailsAndReturnOutputTypeSelect? select,
    _i3.CreateManyPostDetailsAndReturnOutputTypeInclude? include,
  }) {
    final args = {
      'data': data,
      'skipDuplicates': skipDuplicates,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.createManyAndReturn,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<
      Iterable<_i2.CreateManyPostDetailsAndReturnOutputType>
    >(
      action: 'createManyPostDetailsAndReturn',
      result: result,
      factory: (values) => (values as Iterable).map(
        (e) => _i2.CreateManyPostDetailsAndReturnOutputType.fromJson(e),
      ),
    );
  }

  _i1.ActionClient<_i2.PostDetails?> update({
    required _i1.PrismaUnion<
      _i3.PostDetailsUpdateInput,
      _i3.PostDetailsUncheckedUpdateInput
    >
    data,
    required _i3.PostDetailsWhereUniqueInput where,
    _i3.PostDetailsSelect? select,
    _i3.PostDetailsInclude? include,
  }) {
    final args = {
      'data': data,
      'where': where,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.updateOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.PostDetails?>(
      action: 'updateOnePostDetails',
      result: result,
      factory: (e) => e != null ? _i2.PostDetails.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i3.AffectedRowsOutput> updateMany({
    required _i1.PrismaUnion<
      _i3.PostDetailsUpdateManyMutationInput,
      _i3.PostDetailsUncheckedUpdateManyInput
    >
    data,
    _i3.PostDetailsWhereInput? where,
  }) {
    final args = {'data': data, 'where': where};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.updateMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AffectedRowsOutput>(
      action: 'updateManyPostDetails',
      result: result,
      factory: (e) => _i3.AffectedRowsOutput.fromJson(e),
    );
  }

  _i1.ActionClient<_i2.PostDetails> upsert({
    required _i3.PostDetailsWhereUniqueInput where,
    required _i1.PrismaUnion<
      _i3.PostDetailsCreateInput,
      _i3.PostDetailsUncheckedCreateInput
    >
    create,
    required _i1.PrismaUnion<
      _i3.PostDetailsUpdateInput,
      _i3.PostDetailsUncheckedUpdateInput
    >
    update,
    _i3.PostDetailsSelect? select,
    _i3.PostDetailsInclude? include,
  }) {
    final args = {
      'where': where,
      'create': create,
      'update': update,
      'select': select,
      'include': include,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.upsertOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.PostDetails>(
      action: 'upsertOnePostDetails',
      result: result,
      factory: (e) => _i2.PostDetails.fromJson(e),
    );
  }

  _i1.ActionClient<_i2.PostDetails?> delete({
    required _i3.PostDetailsWhereUniqueInput where,
    _i3.PostDetailsSelect? select,
    _i3.PostDetailsInclude? include,
  }) {
    final args = {'where': where, 'select': select, 'include': include};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.deleteOne,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i2.PostDetails?>(
      action: 'deleteOnePostDetails',
      result: result,
      factory: (e) => e != null ? _i2.PostDetails.fromJson(e) : null,
    );
  }

  _i1.ActionClient<_i3.AffectedRowsOutput> deleteMany({
    _i3.PostDetailsWhereInput? where,
  }) {
    final args = {'where': where};
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.deleteMany,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AffectedRowsOutput>(
      action: 'deleteManyPostDetails',
      result: result,
      factory: (e) => _i3.AffectedRowsOutput.fromJson(e),
    );
  }

  _i1.ActionClient<Iterable<_i3.PostDetailsGroupByOutputType>> groupBy({
    _i3.PostDetailsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostDetailsOrderByWithAggregationInput>,
      _i3.PostDetailsOrderByWithAggregationInput
    >?
    orderBy,
    required _i1.PrismaUnion<
      Iterable<_i3.PostDetailsScalar>,
      _i3.PostDetailsScalar
    >
    by,
    _i3.PostDetailsScalarWhereWithAggregatesInput? having,
    int? take,
    int? skip,
    _i3.PostDetailsGroupByOutputTypeSelect? select,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'by': _i1.JsonQuery.groupBySerializer(by),
      'having': having,
      'take': take,
      'skip': skip,
      'select': select ?? _i1.JsonQuery.groupBySelectSerializer(by),
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.groupBy,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<Iterable<_i3.PostDetailsGroupByOutputType>>(
      action: 'groupByPostDetails',
      result: result,
      factory: (values) => (values as Iterable).map(
        (e) => _i3.PostDetailsGroupByOutputType.fromJson(e),
      ),
    );
  }

  _i1.ActionClient<_i3.AggregatePostDetails> aggregate({
    _i3.PostDetailsWhereInput? where,
    _i1.PrismaUnion<
      Iterable<_i3.PostDetailsOrderByWithRelationInput>,
      _i3.PostDetailsOrderByWithRelationInput
    >?
    orderBy,
    _i3.PostDetailsWhereUniqueInput? cursor,
    int? take,
    int? skip,
    _i3.AggregatePostDetailsSelect? select,
  }) {
    final args = {
      'where': where,
      'orderBy': orderBy,
      'cursor': cursor,
      'take': take,
      'skip': skip,
      'select': select,
    };
    final query = _i1.serializeJsonQuery(
      args: args,
      modelName: 'PostDetails',
      action: _i1.JsonQueryAction.aggregate,
      datamodel: PrismaClient.datamodel,
    );
    final result = _client.$engine.request(
      query,
      headers: _client.$transaction.headers,
      transaction: _client.$transaction.transaction,
    );
    return _i1.ActionClient<_i3.AggregatePostDetails>(
      action: 'aggregatePostDetails',
      result: result,
      factory: (e) => _i3.AggregatePostDetails.fromJson(e),
    );
  }
}

class PrismaClient extends _i1.BasePrismaClient<PrismaClient> {
  PrismaClient({
    super.datasourceUrl,
    super.datasources,
    super.errorFormat,
    super.log,
    _i1.Engine? engine,
  }) : _engine = engine;

  static final datamodel = _i4.DataModel.fromJson({
    'enums': [],
    'models': [
      {
        'name': 'Users',
        'dbName': 'users',
        'fields': [
          {
            'name': 'id',
            'kind': 'scalar',
            'isList': false,
            'isRequired': true,
            'isUnique': false,
            'isId': true,
            'isReadOnly': false,
            'hasDefaultValue': true,
            'type': 'Int',
            'default': {'name': 'autoincrement', 'args': []},
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'email',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'first_name',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'last_name',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'phone_number',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'BigInt',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'deleted_at',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'DateTime',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'status',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'tags',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'scores',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'metadata',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'created_at',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': true,
            'type': 'DateTime',
            'default': {'name': 'now', 'args': []},
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'updated_at',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'DateTime',
            'isGenerated': false,
            'isUpdatedAt': true,
          },
          {
            'name': 'posts',
            'kind': 'object',
            'isList': true,
            'isRequired': true,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'Posts',
            'relationName': 'PostsToUsers',
            'relationFromFields': [],
            'relationToFields': [],
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'post_details',
            'kind': 'object',
            'isList': true,
            'isRequired': true,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'PostDetails',
            'relationName': 'PostDetailsToUsers',
            'relationFromFields': [],
            'relationToFields': [],
            'isGenerated': false,
            'isUpdatedAt': false,
          },
        ],
        'primaryKey': null,
        'uniqueFields': [],
        'uniqueIndexes': [],
        'isGenerated': false,
      },
      {
        'name': 'Posts',
        'dbName': 'posts',
        'fields': [
          {
            'name': 'id',
            'kind': 'scalar',
            'isList': false,
            'isRequired': true,
            'isUnique': false,
            'isId': true,
            'isReadOnly': false,
            'hasDefaultValue': true,
            'type': 'Int',
            'default': {'name': 'autoincrement', 'args': []},
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'title',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'content',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'user_id',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': true,
            'hasDefaultValue': false,
            'type': 'Int',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'views',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': true,
            'type': 'Int',
            'default': 0,
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'user',
            'kind': 'object',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'Users',
            'relationName': 'PostsToUsers',
            'relationFromFields': ['user_id'],
            'relationToFields': ['id'],
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'post_details',
            'kind': 'object',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'PostDetails',
            'relationName': 'PostDetailsToPosts',
            'relationFromFields': [],
            'relationToFields': [],
            'isGenerated': false,
            'isUpdatedAt': false,
          },
        ],
        'primaryKey': null,
        'uniqueFields': [],
        'uniqueIndexes': [],
        'isGenerated': false,
      },
      {
        'name': 'PostDetails',
        'dbName': 'post_details',
        'fields': [
          {
            'name': 'id',
            'kind': 'scalar',
            'isList': false,
            'isRequired': true,
            'isUnique': false,
            'isId': true,
            'isReadOnly': false,
            'hasDefaultValue': true,
            'type': 'Int',
            'default': {'name': 'autoincrement', 'args': []},
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'likes',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'Int',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'metadata',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'String',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'post_id',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': true,
            'isId': false,
            'isReadOnly': true,
            'hasDefaultValue': false,
            'type': 'Int',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'user_id',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': true,
            'hasDefaultValue': false,
            'type': 'Int',
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'created_at',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': true,
            'type': 'DateTime',
            'default': {'name': 'now', 'args': []},
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'updated_at',
            'kind': 'scalar',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'DateTime',
            'isGenerated': false,
            'isUpdatedAt': true,
          },
          {
            'name': 'post',
            'kind': 'object',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'Posts',
            'relationName': 'PostDetailsToPosts',
            'relationFromFields': ['post_id'],
            'relationToFields': ['id'],
            'isGenerated': false,
            'isUpdatedAt': false,
          },
          {
            'name': 'user',
            'kind': 'object',
            'isList': false,
            'isRequired': false,
            'isUnique': false,
            'isId': false,
            'isReadOnly': false,
            'hasDefaultValue': false,
            'type': 'Users',
            'relationName': 'PostDetailsToUsers',
            'relationFromFields': ['user_id'],
            'relationToFields': ['id'],
            'isGenerated': false,
            'isUpdatedAt': false,
          },
        ],
        'primaryKey': null,
        'uniqueFields': [],
        'uniqueIndexes': [],
        'isGenerated': false,
      },
    ],
    'types': [],
    'indexes': [
      {
        'model': 'Users',
        'type': 'id',
        'isDefinedOnField': true,
        'fields': [
          {'name': 'id'},
        ],
      },
      {
        'model': 'Posts',
        'type': 'id',
        'isDefinedOnField': true,
        'fields': [
          {'name': 'id'},
        ],
      },
      {
        'model': 'PostDetails',
        'type': 'id',
        'isDefinedOnField': true,
        'fields': [
          {'name': 'id'},
        ],
      },
      {
        'model': 'PostDetails',
        'type': 'unique',
        'isDefinedOnField': true,
        'fields': [
          {'name': 'post_id'},
        ],
      },
    ],
  });

  _i1.Engine? _engine;

  _i1.TransactionClient<PrismaClient>? _transaction;

  @override
  get $transaction {
    if (_transaction != null) return _transaction!;
    PrismaClient factory(_i1.TransactionClient<PrismaClient> transaction) {
      final client = PrismaClient(
        engine: $engine,
        datasources: $options.datasources,
        datasourceUrl: $options.datasourceUrl,
        errorFormat: $options.errorFormat,
        log: $options.logEmitter.definition,
      );
      client.$options.logEmitter = $options.logEmitter;
      client._transaction = transaction;

      return client;
    }

    return _transaction = _i1.TransactionClient<PrismaClient>($engine, factory);
  }

  @override
  get $engine => _engine ??= _i5.BinaryEngine(
    schema:
        'generator client {\n  provider = "prisma-client-dart"\n  output   = "../lib/prisma_client"\n}\n\ndatasource db {\n  provider = "postgresql"\n  url      = "postgresql://postgres:postgres@localhost:5432/postgres?schema=public"\n}\n\nmodel Users {\n  id           Int       @id @default(autoincrement())\n  email        String?\n  first_name   String?\n  last_name    String?\n  phone_number BigInt?\n  deleted_at   DateTime?\n  status       String?\n  tags         String?\n  scores       String?\n  metadata     String?\n  created_at   DateTime? @default(now())\n  updated_at   DateTime? @updatedAt\n\n  posts        Posts[]\n  post_details PostDetails[]\n\n  @@map("users")\n}\n\nmodel Posts {\n  id      Int     @id @default(autoincrement())\n  title   String?\n  content String?\n  user_id Int?\n  views   Int?    @default(0)\n\n  user         Users?       @relation(fields: [user_id], references: [id])\n  post_details PostDetails?\n\n  @@map("posts")\n}\n\nmodel PostDetails {\n  id         Int       @id @default(autoincrement())\n  likes      Int?\n  metadata   String?\n  post_id    Int?      @unique\n  user_id    Int?\n  created_at DateTime? @default(now())\n  updated_at DateTime? @updatedAt\n\n  post Posts? @relation(fields: [post_id], references: [id])\n  user Users? @relation(fields: [user_id], references: [id])\n\n  @@map("post_details")\n}\n',
    datasources: const {
      'db': _i1.Datasource(
        _i1.DatasourceType.url,
        'postgresql://postgres:postgres@localhost:5432/postgres?schema=public',
      ),
    },
    options: $options,
  );

  @override
  get $datamodel => datamodel;

  UsersDelegate get users => UsersDelegate._(this);

  PostsDelegate get posts => PostsDelegate._(this);

  PostDetailsDelegate get postDetails => PostDetailsDelegate._(this);
}
