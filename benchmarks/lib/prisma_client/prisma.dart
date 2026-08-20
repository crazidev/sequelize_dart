// ignore_for_file: non_constant_identifier_names

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:orm/orm.dart' as _i1;

import 'prisma.dart' as _i2;

class UsersCountOutputType {
  const UsersCountOutputType({this.posts, this.postDetails});

  factory UsersCountOutputType.fromJson(Map json) => UsersCountOutputType(
    posts: json['posts'],
    postDetails: json['post_details'],
  );

  final int? posts;

  final int? postDetails;

  Map<String, dynamic> toJson() => {
    'posts': posts,
    'post_details': postDetails,
  };
}

class NestedIntFilter implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedIntFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<int, _i1.Reference<int>>? equals;

  final _i1.PrismaUnion<Iterable<int>, _i1.Reference<Iterable<int>>>? $in;

  final _i1.PrismaUnion<Iterable<int>, _i1.Reference<Iterable<int>>>? notIn;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lte;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gte;

  final _i1.PrismaUnion<int, _i2.NestedIntFilter>? not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

class IntFilter implements _i1.JsonConvertible<Map<String, dynamic>> {
  const IntFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<int, _i1.Reference<int>>? equals;

  final _i1.PrismaUnion<Iterable<int>, _i1.Reference<Iterable<int>>>? $in;

  final _i1.PrismaUnion<Iterable<int>, _i1.Reference<Iterable<int>>>? notIn;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lte;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gte;

  final _i1.PrismaUnion<int, _i2.NestedIntFilter>? not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

enum QueryMode implements _i1.PrismaEnum {
  $default._('default'),
  insensitive._('insensitive');

  const QueryMode._(this.name);

  @override
  final String name;
}

class NestedStringNullableFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedStringNullableFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.contains,
    this.startsWith,
    this.endsWith,
    this.not,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<_i1.Reference<String>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<String>,
    _i1.PrismaUnion<_i1.Reference<Iterable<String>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<String>,
    _i1.PrismaUnion<_i1.Reference<Iterable<String>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? lt;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? lte;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? gt;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? gte;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? contains;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? startsWith;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? endsWith;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<_i2.NestedStringNullableFilter, _i1.PrismaNull>
  >?
  not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'contains': contains,
    'startsWith': startsWith,
    'endsWith': endsWith,
    'not': not,
  };
}

class StringNullableFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const StringNullableFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.contains,
    this.startsWith,
    this.endsWith,
    this.mode,
    this.not,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<_i1.Reference<String>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<String>,
    _i1.PrismaUnion<_i1.Reference<Iterable<String>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<String>,
    _i1.PrismaUnion<_i1.Reference<Iterable<String>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? lt;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? lte;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? gt;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? gte;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? contains;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? startsWith;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? endsWith;

  final _i2.QueryMode? mode;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<_i2.NestedStringNullableFilter, _i1.PrismaNull>
  >?
  not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'contains': contains,
    'startsWith': startsWith,
    'endsWith': endsWith,
    'mode': mode,
    'not': not,
  };
}

class NestedBigIntNullableFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedBigIntNullableFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<_i1.Reference<BigInt>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<BigInt>,
    _i1.PrismaUnion<_i1.Reference<Iterable<BigInt>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<BigInt>,
    _i1.PrismaUnion<_i1.Reference<Iterable<BigInt>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? lt;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? lte;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? gt;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? gte;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<_i2.NestedBigIntNullableFilter, _i1.PrismaNull>
  >?
  not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

class BigIntNullableFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const BigIntNullableFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<_i1.Reference<BigInt>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<BigInt>,
    _i1.PrismaUnion<_i1.Reference<Iterable<BigInt>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<BigInt>,
    _i1.PrismaUnion<_i1.Reference<Iterable<BigInt>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? lt;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? lte;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? gt;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? gte;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<_i2.NestedBigIntNullableFilter, _i1.PrismaNull>
  >?
  not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

class NestedDateTimeNullableFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedDateTimeNullableFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<_i1.Reference<DateTime>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<DateTime>,
    _i1.PrismaUnion<_i1.Reference<Iterable<DateTime>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<DateTime>,
    _i1.PrismaUnion<_i1.Reference<Iterable<DateTime>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? lt;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? lte;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? gt;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? gte;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<_i2.NestedDateTimeNullableFilter, _i1.PrismaNull>
  >?
  not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

class DateTimeNullableFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const DateTimeNullableFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<_i1.Reference<DateTime>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<DateTime>,
    _i1.PrismaUnion<_i1.Reference<Iterable<DateTime>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<DateTime>,
    _i1.PrismaUnion<_i1.Reference<Iterable<DateTime>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? lt;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? lte;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? gt;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? gte;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<_i2.NestedDateTimeNullableFilter, _i1.PrismaNull>
  >?
  not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

class NestedIntNullableFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedIntNullableFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i1.Reference<int>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<int>,
    _i1.PrismaUnion<_i1.Reference<Iterable<int>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<int>,
    _i1.PrismaUnion<_i1.Reference<Iterable<int>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lte;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gte;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NestedIntNullableFilter, _i1.PrismaNull>
  >?
  not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

class IntNullableFilter implements _i1.JsonConvertible<Map<String, dynamic>> {
  const IntNullableFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i1.Reference<int>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<int>,
    _i1.PrismaUnion<_i1.Reference<Iterable<int>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<int>,
    _i1.PrismaUnion<_i1.Reference<Iterable<int>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lte;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gte;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NestedIntNullableFilter, _i1.PrismaNull>
  >?
  not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

class UsersNullableRelationFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersNullableRelationFilter({this.$is, this.isNot});

  final _i1.PrismaUnion<_i2.UsersWhereInput, _i1.PrismaNull>? $is;

  final _i1.PrismaUnion<_i2.UsersWhereInput, _i1.PrismaNull>? isNot;

  @override
  Map<String, dynamic> toJson() => {'is': $is, 'isNot': isNot};
}

class PostsNullableRelationFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsNullableRelationFilter({this.$is, this.isNot});

  final _i1.PrismaUnion<_i2.PostsWhereInput, _i1.PrismaNull>? $is;

  final _i1.PrismaUnion<_i2.PostsWhereInput, _i1.PrismaNull>? isNot;

  @override
  Map<String, dynamic> toJson() => {'is': $is, 'isNot': isNot};
}

class PostDetailsWhereInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsWhereInput({
    this.AND,
    this.OR,
    this.NOT,
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.post,
    this.user,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereInput,
    Iterable<_i2.PostDetailsWhereInput>
  >?
  AND;

  final Iterable<_i2.PostDetailsWhereInput>? OR;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereInput,
    Iterable<_i2.PostDetailsWhereInput>
  >?
  NOT;

  final _i1.PrismaUnion<_i2.IntFilter, int>? id;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  metadata;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  postId;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  createdAt;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  updatedAt;

  final _i1.PrismaUnion<
    _i2.PostsNullableRelationFilter,
    _i1.PrismaUnion<_i2.PostsWhereInput, _i1.PrismaNull>
  >?
  post;

  final _i1.PrismaUnion<
    _i2.UsersNullableRelationFilter,
    _i1.PrismaUnion<_i2.UsersWhereInput, _i1.PrismaNull>
  >?
  user;

  @override
  Map<String, dynamic> toJson() => {
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post': post,
    'user': user,
  };
}

class PostDetailsNullableRelationFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsNullableRelationFilter({this.$is, this.isNot});

  final _i1.PrismaUnion<_i2.PostDetailsWhereInput, _i1.PrismaNull>? $is;

  final _i1.PrismaUnion<_i2.PostDetailsWhereInput, _i1.PrismaNull>? isNot;

  @override
  Map<String, dynamic> toJson() => {'is': $is, 'isNot': isNot};
}

class PostsWhereInput implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsWhereInput({
    this.AND,
    this.OR,
    this.NOT,
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.user,
    this.postDetails,
  });

  final _i1.PrismaUnion<_i2.PostsWhereInput, Iterable<_i2.PostsWhereInput>>?
  AND;

  final Iterable<_i2.PostsWhereInput>? OR;

  final _i1.PrismaUnion<_i2.PostsWhereInput, Iterable<_i2.PostsWhereInput>>?
  NOT;

  final _i1.PrismaUnion<_i2.IntFilter, int>? id;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  title;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  content;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  views;

  final _i1.PrismaUnion<
    _i2.UsersNullableRelationFilter,
    _i1.PrismaUnion<_i2.UsersWhereInput, _i1.PrismaNull>
  >?
  user;

  final _i1.PrismaUnion<
    _i2.PostDetailsNullableRelationFilter,
    _i1.PrismaUnion<_i2.PostDetailsWhereInput, _i1.PrismaNull>
  >?
  postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    'user': user,
    'post_details': postDetails,
  };
}

class PostsListRelationFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsListRelationFilter({this.every, this.some, this.none});

  final _i2.PostsWhereInput? every;

  final _i2.PostsWhereInput? some;

  final _i2.PostsWhereInput? none;

  @override
  Map<String, dynamic> toJson() => {'every': every, 'some': some, 'none': none};
}

class PostDetailsListRelationFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsListRelationFilter({this.every, this.some, this.none});

  final _i2.PostDetailsWhereInput? every;

  final _i2.PostDetailsWhereInput? some;

  final _i2.PostDetailsWhereInput? none;

  @override
  Map<String, dynamic> toJson() => {'every': every, 'some': some, 'none': none};
}

class UsersWhereInput implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersWhereInput({
    this.AND,
    this.OR,
    this.NOT,
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
    this.postDetails,
  });

  final _i1.PrismaUnion<_i2.UsersWhereInput, Iterable<_i2.UsersWhereInput>>?
  AND;

  final Iterable<_i2.UsersWhereInput>? OR;

  final _i1.PrismaUnion<_i2.UsersWhereInput, Iterable<_i2.UsersWhereInput>>?
  NOT;

  final _i1.PrismaUnion<_i2.IntFilter, int>? id;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  email;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  firstName;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  lastName;

  final _i1.PrismaUnion<
    _i2.BigIntNullableFilter,
    _i1.PrismaUnion<BigInt, _i1.PrismaNull>
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  deletedAt;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  status;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  tags;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  scores;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  metadata;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  createdAt;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  updatedAt;

  final _i2.PostsListRelationFilter? posts;

  final _i2.PostDetailsListRelationFilter? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
    'post_details': postDetails,
  };
}

class UsersWhereUniqueInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersWhereUniqueInput({
    this.id,
    this.AND,
    this.OR,
    this.NOT,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
    this.postDetails,
  });

  final int? id;

  final _i1.PrismaUnion<_i2.UsersWhereInput, Iterable<_i2.UsersWhereInput>>?
  AND;

  final Iterable<_i2.UsersWhereInput>? OR;

  final _i1.PrismaUnion<_i2.UsersWhereInput, Iterable<_i2.UsersWhereInput>>?
  NOT;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  email;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  firstName;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  lastName;

  final _i1.PrismaUnion<
    _i2.BigIntNullableFilter,
    _i1.PrismaUnion<BigInt, _i1.PrismaNull>
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  deletedAt;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  status;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  tags;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  scores;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  metadata;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  createdAt;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  updatedAt;

  final _i2.PostsListRelationFilter? posts;

  final _i2.PostDetailsListRelationFilter? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
    'post_details': postDetails,
  };
}

class PostsUserArgs implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUserArgs({this.where, this.select, this.include});

  final _i2.UsersWhereInput? where;

  final _i2.UsersSelect? select;

  final _i2.UsersInclude? include;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'select': select,
    'include': include,
  };
}

class PostDetailsPostArgs implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsPostArgs({this.where, this.select, this.include});

  final _i2.PostsWhereInput? where;

  final _i2.PostsSelect? select;

  final _i2.PostsInclude? include;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'select': select,
    'include': include,
  };
}

class PostDetailsUserArgs implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUserArgs({this.where, this.select, this.include});

  final _i2.UsersWhereInput? where;

  final _i2.UsersSelect? select;

  final _i2.UsersInclude? include;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'select': select,
    'include': include,
  };
}

class PostDetailsSelect implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsSelect({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.post,
    this.user,
  });

  final bool? id;

  final bool? likes;

  final bool? metadata;

  final bool? postId;

  final bool? userId;

  final bool? createdAt;

  final bool? updatedAt;

  final _i1.PrismaUnion<bool, _i2.PostDetailsPostArgs>? post;

  final _i1.PrismaUnion<bool, _i2.PostDetailsUserArgs>? user;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post': post,
    'user': user,
  };
}

class PostDetailsInclude implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsInclude({this.post, this.user});

  final _i1.PrismaUnion<bool, _i2.PostDetailsPostArgs>? post;

  final _i1.PrismaUnion<bool, _i2.PostDetailsUserArgs>? user;

  @override
  Map<String, dynamic> toJson() => {'post': post, 'user': user};
}

class PostsPostDetailsArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsPostDetailsArgs({this.where, this.select, this.include});

  final _i2.PostDetailsWhereInput? where;

  final _i2.PostDetailsSelect? select;

  final _i2.PostDetailsInclude? include;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'select': select,
    'include': include,
  };
}

class PostsInclude implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsInclude({this.user, this.postDetails});

  final _i1.PrismaUnion<bool, _i2.PostsUserArgs>? user;

  final _i1.PrismaUnion<bool, _i2.PostsPostDetailsArgs>? postDetails;

  @override
  Map<String, dynamic> toJson() => {'user': user, 'post_details': postDetails};
}

enum SortOrder implements _i1.PrismaEnum {
  asc._('asc'),
  desc._('desc');

  const SortOrder._(this.name);

  @override
  final String name;
}

enum NullsOrder implements _i1.PrismaEnum {
  first._('first'),
  last._('last');

  const NullsOrder._(this.name);

  @override
  final String name;
}

class SortOrderInput implements _i1.JsonConvertible<Map<String, dynamic>> {
  const SortOrderInput({required this.sort, this.nulls});

  final _i2.SortOrder sort;

  final _i2.NullsOrder? nulls;

  @override
  Map<String, dynamic> toJson() => {'sort': sort, 'nulls': nulls};
}

class PostsOrderByRelationAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsOrderByRelationAggregateInput({this.$count});

  final _i2.SortOrder? $count;

  @override
  Map<String, dynamic> toJson() => {'_count': $count};
}

class PostDetailsOrderByRelationAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsOrderByRelationAggregateInput({this.$count});

  final _i2.SortOrder? $count;

  @override
  Map<String, dynamic> toJson() => {'_count': $count};
}

class UsersOrderByWithRelationInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersOrderByWithRelationInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
    this.postDetails,
  });

  final _i2.SortOrder? id;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? email;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? firstName;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? lastName;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? phoneNumber;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? deletedAt;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? status;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? tags;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? scores;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? metadata;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? createdAt;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? updatedAt;

  final _i2.PostsOrderByRelationAggregateInput? posts;

  final _i2.PostDetailsOrderByRelationAggregateInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
    'post_details': postDetails,
  };
}

class PostDetailsOrderByWithRelationInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsOrderByWithRelationInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.post,
    this.user,
  });

  final _i2.SortOrder? id;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? likes;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? metadata;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? postId;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? userId;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? createdAt;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? updatedAt;

  final _i2.PostsOrderByWithRelationInput? post;

  final _i2.UsersOrderByWithRelationInput? user;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post': post,
    'user': user,
  };
}

class PostsOrderByWithRelationInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsOrderByWithRelationInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.user,
    this.postDetails,
  });

  final _i2.SortOrder? id;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? title;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? content;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? userId;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? views;

  final _i2.UsersOrderByWithRelationInput? user;

  final _i2.PostDetailsOrderByWithRelationInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    'user': user,
    'post_details': postDetails,
  };
}

class PostsWhereUniqueInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsWhereUniqueInput({
    this.id,
    this.AND,
    this.OR,
    this.NOT,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.user,
    this.postDetails,
  });

  final int? id;

  final _i1.PrismaUnion<_i2.PostsWhereInput, Iterable<_i2.PostsWhereInput>>?
  AND;

  final Iterable<_i2.PostsWhereInput>? OR;

  final _i1.PrismaUnion<_i2.PostsWhereInput, Iterable<_i2.PostsWhereInput>>?
  NOT;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  title;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  content;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  views;

  final _i1.PrismaUnion<
    _i2.UsersNullableRelationFilter,
    _i1.PrismaUnion<_i2.UsersWhereInput, _i1.PrismaNull>
  >?
  user;

  final _i1.PrismaUnion<
    _i2.PostDetailsNullableRelationFilter,
    _i1.PrismaUnion<_i2.PostDetailsWhereInput, _i1.PrismaNull>
  >?
  postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    'user': user,
    'post_details': postDetails,
  };
}

enum PostsScalar<T> implements _i1.PrismaEnum, _i1.Reference<T> {
  id<int>('id', 'Posts'),
  title<String>('title', 'Posts'),
  content<String>('content', 'Posts'),
  userId<int>('user_id', 'Posts'),
  views<int>('views', 'Posts');

  const PostsScalar(this.name, this.model);

  @override
  final String name;

  @override
  final String model;
}

class UsersPostsArgs implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersPostsArgs({
    this.where,
    this.orderBy,
    this.cursor,
    this.take,
    this.skip,
    this.distinct,
    this.select,
    this.include,
  });

  final _i2.PostsWhereInput? where;

  final _i1.PrismaUnion<
    Iterable<_i2.PostsOrderByWithRelationInput>,
    _i2.PostsOrderByWithRelationInput
  >?
  orderBy;

  final _i2.PostsWhereUniqueInput? cursor;

  final int? take;

  final int? skip;

  final _i1.PrismaUnion<_i2.PostsScalar, Iterable<_i2.PostsScalar>>? distinct;

  final _i2.PostsSelect? select;

  final _i2.PostsInclude? include;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'orderBy': orderBy,
    'cursor': cursor,
    'take': take,
    'skip': skip,
    'distinct': distinct,
    'select': select,
    'include': include,
  };
}

class PostDetailsWhereUniqueInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsWhereUniqueInput({
    this.id,
    this.postId,
    this.AND,
    this.OR,
    this.NOT,
    this.likes,
    this.metadata,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.post,
    this.user,
  });

  final int? id;

  final int? postId;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereInput,
    Iterable<_i2.PostDetailsWhereInput>
  >?
  AND;

  final Iterable<_i2.PostDetailsWhereInput>? OR;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereInput,
    Iterable<_i2.PostDetailsWhereInput>
  >?
  NOT;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  metadata;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  createdAt;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  updatedAt;

  final _i1.PrismaUnion<
    _i2.PostsNullableRelationFilter,
    _i1.PrismaUnion<_i2.PostsWhereInput, _i1.PrismaNull>
  >?
  post;

  final _i1.PrismaUnion<
    _i2.UsersNullableRelationFilter,
    _i1.PrismaUnion<_i2.UsersWhereInput, _i1.PrismaNull>
  >?
  user;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'likes': likes,
    'metadata': metadata,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post': post,
    'user': user,
  };
}

enum PostDetailsScalar<T> implements _i1.PrismaEnum, _i1.Reference<T> {
  id<int>('id', 'PostDetails'),
  likes<int>('likes', 'PostDetails'),
  metadata<String>('metadata', 'PostDetails'),
  postId<int>('post_id', 'PostDetails'),
  userId<int>('user_id', 'PostDetails'),
  createdAt<DateTime>('created_at', 'PostDetails'),
  updatedAt<DateTime>('updated_at', 'PostDetails');

  const PostDetailsScalar(this.name, this.model);

  @override
  final String name;

  @override
  final String model;
}

class UsersPostDetailsArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersPostDetailsArgs({
    this.where,
    this.orderBy,
    this.cursor,
    this.take,
    this.skip,
    this.distinct,
    this.select,
    this.include,
  });

  final _i2.PostDetailsWhereInput? where;

  final _i1.PrismaUnion<
    Iterable<_i2.PostDetailsOrderByWithRelationInput>,
    _i2.PostDetailsOrderByWithRelationInput
  >?
  orderBy;

  final _i2.PostDetailsWhereUniqueInput? cursor;

  final int? take;

  final int? skip;

  final _i1.PrismaUnion<_i2.PostDetailsScalar, Iterable<_i2.PostDetailsScalar>>?
  distinct;

  final _i2.PostDetailsSelect? select;

  final _i2.PostDetailsInclude? include;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'orderBy': orderBy,
    'cursor': cursor,
    'take': take,
    'skip': skip,
    'distinct': distinct,
    'select': select,
    'include': include,
  };
}

class UsersCountOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCountOutputTypeSelect({this.posts, this.postDetails});

  final bool? posts;

  final bool? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'posts': posts,
    'post_details': postDetails,
  };
}

class UsersCountArgs implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCountArgs({this.select});

  final _i2.UsersCountOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class UsersInclude implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersInclude({this.posts, this.postDetails, this.$count});

  final _i1.PrismaUnion<bool, _i2.UsersPostsArgs>? posts;

  final _i1.PrismaUnion<bool, _i2.UsersPostDetailsArgs>? postDetails;

  final _i1.PrismaUnion<bool, _i2.UsersCountArgs>? $count;

  @override
  Map<String, dynamic> toJson() => {
    'posts': posts,
    'post_details': postDetails,
    '_count': $count,
  };
}

class PostsSelect implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsSelect({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.user,
    this.postDetails,
  });

  final bool? id;

  final bool? title;

  final bool? content;

  final bool? userId;

  final bool? views;

  final _i1.PrismaUnion<bool, _i2.PostsUserArgs>? user;

  final _i1.PrismaUnion<bool, _i2.PostsPostDetailsArgs>? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    'user': user,
    'post_details': postDetails,
  };
}

class UsersSelect implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersSelect({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
    this.postDetails,
    this.$count,
  });

  final bool? id;

  final bool? email;

  final bool? firstName;

  final bool? lastName;

  final bool? phoneNumber;

  final bool? deletedAt;

  final bool? status;

  final bool? tags;

  final bool? scores;

  final bool? metadata;

  final bool? createdAt;

  final bool? updatedAt;

  final _i1.PrismaUnion<bool, _i2.UsersPostsArgs>? posts;

  final _i1.PrismaUnion<bool, _i2.UsersPostDetailsArgs>? postDetails;

  final _i1.PrismaUnion<bool, _i2.UsersCountArgs>? $count;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
    'post_details': postDetails,
    '_count': $count,
  };
}

enum UsersScalar<T> implements _i1.PrismaEnum, _i1.Reference<T> {
  id<int>('id', 'Users'),
  email<String>('email', 'Users'),
  firstName<String>('first_name', 'Users'),
  lastName<String>('last_name', 'Users'),
  phoneNumber<BigInt>('phone_number', 'Users'),
  deletedAt<DateTime>('deleted_at', 'Users'),
  status<String>('status', 'Users'),
  tags<String>('tags', 'Users'),
  scores<String>('scores', 'Users'),
  metadata<String>('metadata', 'Users'),
  createdAt<DateTime>('created_at', 'Users'),
  updatedAt<DateTime>('updated_at', 'Users');

  const UsersScalar(this.name, this.model);

  @override
  final String name;

  @override
  final String model;
}

class UsersCreateWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCreateWithoutPostDetailsInput({
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
  });

  final _i1.PrismaUnion<String, _i1.PrismaNull>? email;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? firstName;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? lastName;

  final _i1.PrismaUnion<BigInt, _i1.PrismaNull>? phoneNumber;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? deletedAt;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? status;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? tags;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? scores;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  final _i2.PostsCreateNestedManyWithoutUserInput? posts;

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
  };
}

class PostDetailsUncheckedCreateWithoutPostInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedCreateWithoutPostInput({
    this.id,
    this.likes,
    this.metadata,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? likes;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? userId;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsCreateOrConnectWithoutPostInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateOrConnectWithoutPostInput({
    required this.where,
    required this.create,
  });

  final _i2.PostDetailsWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutPostInput,
    _i2.PostDetailsUncheckedCreateWithoutPostInput
  >
  create;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'create': create};
}

class PostDetailsUncheckedCreateNestedOneWithoutPostInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedCreateNestedOneWithoutPostInput({
    this.create,
    this.connectOrCreate,
    this.connect,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutPostInput,
    _i2.PostDetailsUncheckedCreateWithoutPostInput
  >?
  create;

  final _i2.PostDetailsCreateOrConnectWithoutPostInput? connectOrCreate;

  final _i2.PostDetailsWhereUniqueInput? connect;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'connect': connect,
  };
}

class PostsUncheckedCreateWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedCreateWithoutUserInput({
    this.id,
    this.title,
    this.content,
    this.views,
    this.postDetails,
  });

  final int? id;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? title;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? content;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? views;

  final _i2.PostDetailsUncheckedCreateNestedOneWithoutPostInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'views': views,
    'post_details': postDetails,
  };
}

class PostsCreateOrConnectWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateOrConnectWithoutUserInput({
    required this.where,
    required this.create,
  });

  final _i2.PostsWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutUserInput,
    _i2.PostsUncheckedCreateWithoutUserInput
  >
  create;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'create': create};
}

class PostsCreateManyUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateManyUserInput({
    this.id,
    this.title,
    this.content,
    this.views,
  });

  final int? id;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? title;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? content;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'views': views,
  };
}

class PostsCreateManyUserInputEnvelope
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateManyUserInputEnvelope({
    required this.data,
    this.skipDuplicates,
  });

  final _i1.PrismaUnion<
    _i2.PostsCreateManyUserInput,
    Iterable<_i2.PostsCreateManyUserInput>
  >
  data;

  final bool? skipDuplicates;

  @override
  Map<String, dynamic> toJson() => {
    'data': data,
    'skipDuplicates': skipDuplicates,
  };
}

class PostsUncheckedCreateNestedManyWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedCreateNestedManyWithoutUserInput({
    this.create,
    this.connectOrCreate,
    this.createMany,
    this.connect,
  });

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutUserInput,
    _i1.PrismaUnion<
      Iterable<_i2.PostsCreateWithoutUserInput>,
      _i1.PrismaUnion<
        _i2.PostsUncheckedCreateWithoutUserInput,
        Iterable<_i2.PostsUncheckedCreateWithoutUserInput>
      >
    >
  >?
  create;

  final _i1.PrismaUnion<
    _i2.PostsCreateOrConnectWithoutUserInput,
    Iterable<_i2.PostsCreateOrConnectWithoutUserInput>
  >?
  connectOrCreate;

  final _i2.PostsCreateManyUserInputEnvelope? createMany;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  connect;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'createMany': createMany,
    'connect': connect,
  };
}

class UsersUncheckedCreateWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUncheckedCreateWithoutPostDetailsInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
  });

  final int? id;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? email;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? firstName;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? lastName;

  final _i1.PrismaUnion<BigInt, _i1.PrismaNull>? phoneNumber;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? deletedAt;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? status;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? tags;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? scores;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  final _i2.PostsUncheckedCreateNestedManyWithoutUserInput? posts;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
  };
}

class UsersCreateOrConnectWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCreateOrConnectWithoutPostDetailsInput({
    required this.where,
    required this.create,
  });

  final _i2.UsersWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.UsersCreateWithoutPostDetailsInput,
    _i2.UsersUncheckedCreateWithoutPostDetailsInput
  >
  create;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'create': create};
}

class UsersCreateNestedOneWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCreateNestedOneWithoutPostDetailsInput({
    this.create,
    this.connectOrCreate,
    this.connect,
  });

  final _i1.PrismaUnion<
    _i2.UsersCreateWithoutPostDetailsInput,
    _i2.UsersUncheckedCreateWithoutPostDetailsInput
  >?
  create;

  final _i2.UsersCreateOrConnectWithoutPostDetailsInput? connectOrCreate;

  final _i2.UsersWhereUniqueInput? connect;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'connect': connect,
  };
}

class PostDetailsCreateWithoutPostInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateWithoutPostInput({
    this.likes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  final _i1.PrismaUnion<int, _i1.PrismaNull>? likes;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  final _i2.UsersCreateNestedOneWithoutPostDetailsInput? user;

  @override
  Map<String, dynamic> toJson() => {
    'likes': likes,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'user': user,
  };
}

class PostDetailsCreateNestedOneWithoutPostInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateNestedOneWithoutPostInput({
    this.create,
    this.connectOrCreate,
    this.connect,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutPostInput,
    _i2.PostDetailsUncheckedCreateWithoutPostInput
  >?
  create;

  final _i2.PostDetailsCreateOrConnectWithoutPostInput? connectOrCreate;

  final _i2.PostDetailsWhereUniqueInput? connect;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'connect': connect,
  };
}

class PostsCreateWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateWithoutUserInput({
    this.title,
    this.content,
    this.views,
    this.postDetails,
  });

  final _i1.PrismaUnion<String, _i1.PrismaNull>? title;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? content;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? views;

  final _i2.PostDetailsCreateNestedOneWithoutPostInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'views': views,
    'post_details': postDetails,
  };
}

class PostsCreateNestedManyWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateNestedManyWithoutUserInput({
    this.create,
    this.connectOrCreate,
    this.createMany,
    this.connect,
  });

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutUserInput,
    _i1.PrismaUnion<
      Iterable<_i2.PostsCreateWithoutUserInput>,
      _i1.PrismaUnion<
        _i2.PostsUncheckedCreateWithoutUserInput,
        Iterable<_i2.PostsUncheckedCreateWithoutUserInput>
      >
    >
  >?
  create;

  final _i1.PrismaUnion<
    _i2.PostsCreateOrConnectWithoutUserInput,
    Iterable<_i2.PostsCreateOrConnectWithoutUserInput>
  >?
  connectOrCreate;

  final _i2.PostsCreateManyUserInputEnvelope? createMany;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  connect;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'createMany': createMany,
    'connect': connect,
  };
}

class UsersCreateWithoutPostsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCreateWithoutPostsInput({
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.postDetails,
  });

  final _i1.PrismaUnion<String, _i1.PrismaNull>? email;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? firstName;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? lastName;

  final _i1.PrismaUnion<BigInt, _i1.PrismaNull>? phoneNumber;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? deletedAt;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? status;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? tags;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? scores;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  final _i2.PostDetailsCreateNestedManyWithoutUserInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post_details': postDetails,
  };
}

class PostDetailsUncheckedCreateWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedCreateWithoutUserInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? likes;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? postId;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsCreateOrConnectWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateOrConnectWithoutUserInput({
    required this.where,
    required this.create,
  });

  final _i2.PostDetailsWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutUserInput,
    _i2.PostDetailsUncheckedCreateWithoutUserInput
  >
  create;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'create': create};
}

class PostDetailsCreateManyUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateManyUserInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? likes;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? postId;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsCreateManyUserInputEnvelope
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateManyUserInputEnvelope({
    required this.data,
    this.skipDuplicates,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateManyUserInput,
    Iterable<_i2.PostDetailsCreateManyUserInput>
  >
  data;

  final bool? skipDuplicates;

  @override
  Map<String, dynamic> toJson() => {
    'data': data,
    'skipDuplicates': skipDuplicates,
  };
}

class PostDetailsUncheckedCreateNestedManyWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedCreateNestedManyWithoutUserInput({
    this.create,
    this.connectOrCreate,
    this.createMany,
    this.connect,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutUserInput,
    _i1.PrismaUnion<
      Iterable<_i2.PostDetailsCreateWithoutUserInput>,
      _i1.PrismaUnion<
        _i2.PostDetailsUncheckedCreateWithoutUserInput,
        Iterable<_i2.PostDetailsUncheckedCreateWithoutUserInput>
      >
    >
  >?
  create;

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateOrConnectWithoutUserInput,
    Iterable<_i2.PostDetailsCreateOrConnectWithoutUserInput>
  >?
  connectOrCreate;

  final _i2.PostDetailsCreateManyUserInputEnvelope? createMany;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  connect;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'createMany': createMany,
    'connect': connect,
  };
}

class UsersUncheckedCreateWithoutPostsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUncheckedCreateWithoutPostsInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.postDetails,
  });

  final int? id;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? email;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? firstName;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? lastName;

  final _i1.PrismaUnion<BigInt, _i1.PrismaNull>? phoneNumber;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? deletedAt;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? status;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? tags;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? scores;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  final _i2.PostDetailsUncheckedCreateNestedManyWithoutUserInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post_details': postDetails,
  };
}

class UsersCreateOrConnectWithoutPostsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCreateOrConnectWithoutPostsInput({
    required this.where,
    required this.create,
  });

  final _i2.UsersWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.UsersCreateWithoutPostsInput,
    _i2.UsersUncheckedCreateWithoutPostsInput
  >
  create;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'create': create};
}

class UsersCreateNestedOneWithoutPostsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCreateNestedOneWithoutPostsInput({
    this.create,
    this.connectOrCreate,
    this.connect,
  });

  final _i1.PrismaUnion<
    _i2.UsersCreateWithoutPostsInput,
    _i2.UsersUncheckedCreateWithoutPostsInput
  >?
  create;

  final _i2.UsersCreateOrConnectWithoutPostsInput? connectOrCreate;

  final _i2.UsersWhereUniqueInput? connect;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'connect': connect,
  };
}

class PostsCreateWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateWithoutPostDetailsInput({
    this.title,
    this.content,
    this.views,
    this.user,
  });

  final _i1.PrismaUnion<String, _i1.PrismaNull>? title;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? content;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? views;

  final _i2.UsersCreateNestedOneWithoutPostsInput? user;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'views': views,
    'user': user,
  };
}

class PostsUncheckedCreateWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedCreateWithoutPostDetailsInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final int? id;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? title;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? content;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? userId;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsCreateOrConnectWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateOrConnectWithoutPostDetailsInput({
    required this.where,
    required this.create,
  });

  final _i2.PostsWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutPostDetailsInput,
    _i2.PostsUncheckedCreateWithoutPostDetailsInput
  >
  create;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'create': create};
}

class PostsCreateNestedOneWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateNestedOneWithoutPostDetailsInput({
    this.create,
    this.connectOrCreate,
    this.connect,
  });

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutPostDetailsInput,
    _i2.PostsUncheckedCreateWithoutPostDetailsInput
  >?
  create;

  final _i2.PostsCreateOrConnectWithoutPostDetailsInput? connectOrCreate;

  final _i2.PostsWhereUniqueInput? connect;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'connect': connect,
  };
}

class PostDetailsCreateWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateWithoutUserInput({
    this.likes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.post,
  });

  final _i1.PrismaUnion<int, _i1.PrismaNull>? likes;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  final _i2.PostsCreateNestedOneWithoutPostDetailsInput? post;

  @override
  Map<String, dynamic> toJson() => {
    'likes': likes,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post': post,
  };
}

class PostDetailsCreateNestedManyWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateNestedManyWithoutUserInput({
    this.create,
    this.connectOrCreate,
    this.createMany,
    this.connect,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutUserInput,
    _i1.PrismaUnion<
      Iterable<_i2.PostDetailsCreateWithoutUserInput>,
      _i1.PrismaUnion<
        _i2.PostDetailsUncheckedCreateWithoutUserInput,
        Iterable<_i2.PostDetailsUncheckedCreateWithoutUserInput>
      >
    >
  >?
  create;

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateOrConnectWithoutUserInput,
    Iterable<_i2.PostDetailsCreateOrConnectWithoutUserInput>
  >?
  connectOrCreate;

  final _i2.PostDetailsCreateManyUserInputEnvelope? createMany;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  connect;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'createMany': createMany,
    'connect': connect,
  };
}

class UsersCreateInput implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCreateInput({
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
    this.postDetails,
  });

  final _i1.PrismaUnion<String, _i1.PrismaNull>? email;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? firstName;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? lastName;

  final _i1.PrismaUnion<BigInt, _i1.PrismaNull>? phoneNumber;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? deletedAt;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? status;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? tags;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? scores;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  final _i2.PostsCreateNestedManyWithoutUserInput? posts;

  final _i2.PostDetailsCreateNestedManyWithoutUserInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
    'post_details': postDetails,
  };
}

class UsersUncheckedCreateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUncheckedCreateInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
    this.postDetails,
  });

  final int? id;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? email;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? firstName;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? lastName;

  final _i1.PrismaUnion<BigInt, _i1.PrismaNull>? phoneNumber;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? deletedAt;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? status;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? tags;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? scores;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  final _i2.PostsUncheckedCreateNestedManyWithoutUserInput? posts;

  final _i2.PostDetailsUncheckedCreateNestedManyWithoutUserInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
    'post_details': postDetails,
  };
}

class AffectedRowsOutput {
  const AffectedRowsOutput({this.count});

  factory AffectedRowsOutput.fromJson(Map json) =>
      AffectedRowsOutput(count: json['count']);

  final int? count;

  Map<String, dynamic> toJson() => {'count': count};
}

class UsersCreateManyInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCreateManyInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? email;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? firstName;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? lastName;

  final _i1.PrismaUnion<BigInt, _i1.PrismaNull>? phoneNumber;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? deletedAt;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? status;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? tags;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? scores;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class CreateManyUsersAndReturnOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const CreateManyUsersAndReturnOutputTypeSelect({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final bool? id;

  final bool? email;

  final bool? firstName;

  final bool? lastName;

  final bool? phoneNumber;

  final bool? deletedAt;

  final bool? status;

  final bool? tags;

  final bool? scores;

  final bool? metadata;

  final bool? createdAt;

  final bool? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class NullableStringFieldUpdateOperationsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NullableStringFieldUpdateOperationsInput({this.set});

  final _i1.PrismaUnion<String, _i1.PrismaNull>? set;

  @override
  Map<String, dynamic> toJson() => {'set': set};
}

class NullableBigIntFieldUpdateOperationsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NullableBigIntFieldUpdateOperationsInput({
    this.set,
    this.increment,
    this.decrement,
    this.multiply,
    this.divide,
  });

  final _i1.PrismaUnion<BigInt, _i1.PrismaNull>? set;

  final BigInt? increment;

  final BigInt? decrement;

  final BigInt? multiply;

  final BigInt? divide;

  @override
  Map<String, dynamic> toJson() => {
    'set': set,
    'increment': increment,
    'decrement': decrement,
    'multiply': multiply,
    'divide': divide,
  };
}

class NullableDateTimeFieldUpdateOperationsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NullableDateTimeFieldUpdateOperationsInput({this.set});

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? set;

  @override
  Map<String, dynamic> toJson() => {'set': set};
}

class NullableIntFieldUpdateOperationsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NullableIntFieldUpdateOperationsInput({
    this.set,
    this.increment,
    this.decrement,
    this.multiply,
    this.divide,
  });

  final _i1.PrismaUnion<int, _i1.PrismaNull>? set;

  final int? increment;

  final int? decrement;

  final int? multiply;

  final int? divide;

  @override
  Map<String, dynamic> toJson() => {
    'set': set,
    'increment': increment,
    'decrement': decrement,
    'multiply': multiply,
    'divide': divide,
  };
}

class UsersUpdateWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpdateWithoutPostDetailsInput({
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  email;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  firstName;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  lastName;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NullableBigIntFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  deletedAt;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  status;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  tags;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  scores;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  final _i2.PostsUpdateManyWithoutUserNestedInput? posts;

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
  };
}

class IntFieldUpdateOperationsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const IntFieldUpdateOperationsInput({
    this.set,
    this.increment,
    this.decrement,
    this.multiply,
    this.divide,
  });

  final int? set;

  final int? increment;

  final int? decrement;

  final int? multiply;

  final int? divide;

  @override
  Map<String, dynamic> toJson() => {
    'set': set,
    'increment': increment,
    'decrement': decrement,
    'multiply': multiply,
    'divide': divide,
  };
}

class PostDetailsUncheckedUpdateWithoutPostInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedUpdateWithoutPostInput({
    this.id,
    this.likes,
    this.metadata,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsUpdateToOneWithWhereWithoutPostInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpdateToOneWithWhereWithoutPostInput({
    this.where,
    required this.data,
  });

  final _i2.PostDetailsWhereInput? where;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateWithoutPostInput,
    _i2.PostDetailsUncheckedUpdateWithoutPostInput
  >
  data;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'data': data};
}

class PostDetailsUncheckedUpdateOneWithoutPostNestedInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedUpdateOneWithoutPostNestedInput({
    this.create,
    this.connectOrCreate,
    this.upsert,
    this.disconnect,
    this.delete,
    this.connect,
    this.update,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutPostInput,
    _i2.PostDetailsUncheckedCreateWithoutPostInput
  >?
  create;

  final _i2.PostDetailsCreateOrConnectWithoutPostInput? connectOrCreate;

  final _i2.PostDetailsUpsertWithoutPostInput? upsert;

  final _i1.PrismaUnion<bool, _i2.PostDetailsWhereInput>? disconnect;

  final _i1.PrismaUnion<bool, _i2.PostDetailsWhereInput>? delete;

  final _i2.PostDetailsWhereUniqueInput? connect;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateToOneWithWhereWithoutPostInput,
    _i1.PrismaUnion<
      _i2.PostDetailsUpdateWithoutPostInput,
      _i2.PostDetailsUncheckedUpdateWithoutPostInput
    >
  >?
  update;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'upsert': upsert,
    'disconnect': disconnect,
    'delete': delete,
    'connect': connect,
    'update': update,
  };
}

class PostsUncheckedUpdateWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedUpdateWithoutUserInput({
    this.id,
    this.title,
    this.content,
    this.views,
    this.postDetails,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  title;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  content;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  views;

  final _i2.PostDetailsUncheckedUpdateOneWithoutPostNestedInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'views': views,
    'post_details': postDetails,
  };
}

class PostsUpdateWithWhereUniqueWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpdateWithWhereUniqueWithoutUserInput({
    required this.where,
    required this.data,
  });

  final _i2.PostsWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.PostsUpdateWithoutUserInput,
    _i2.PostsUncheckedUpdateWithoutUserInput
  >
  data;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'data': data};
}

class PostsScalarWhereInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsScalarWhereInput({
    this.AND,
    this.OR,
    this.NOT,
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final _i1.PrismaUnion<
    _i2.PostsScalarWhereInput,
    Iterable<_i2.PostsScalarWhereInput>
  >?
  AND;

  final Iterable<_i2.PostsScalarWhereInput>? OR;

  final _i1.PrismaUnion<
    _i2.PostsScalarWhereInput,
    Iterable<_i2.PostsScalarWhereInput>
  >?
  NOT;

  final _i1.PrismaUnion<_i2.IntFilter, int>? id;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  title;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  content;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  views;

  @override
  Map<String, dynamic> toJson() => {
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsUpdateManyMutationInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpdateManyMutationInput({this.title, this.content, this.views});

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  title;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  content;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  views;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'views': views,
  };
}

class PostsUncheckedUpdateManyWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedUpdateManyWithoutUserInput({
    this.id,
    this.title,
    this.content,
    this.views,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  title;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  content;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'views': views,
  };
}

class PostsUpdateManyWithWhereWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpdateManyWithWhereWithoutUserInput({
    required this.where,
    required this.data,
  });

  final _i2.PostsScalarWhereInput where;

  final _i1.PrismaUnion<
    _i2.PostsUpdateManyMutationInput,
    _i2.PostsUncheckedUpdateManyWithoutUserInput
  >
  data;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'data': data};
}

class PostsUncheckedUpdateManyWithoutUserNestedInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedUpdateManyWithoutUserNestedInput({
    this.create,
    this.connectOrCreate,
    this.upsert,
    this.createMany,
    this.set,
    this.disconnect,
    this.delete,
    this.connect,
    this.update,
    this.updateMany,
    this.deleteMany,
  });

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutUserInput,
    _i1.PrismaUnion<
      Iterable<_i2.PostsCreateWithoutUserInput>,
      _i1.PrismaUnion<
        _i2.PostsUncheckedCreateWithoutUserInput,
        Iterable<_i2.PostsUncheckedCreateWithoutUserInput>
      >
    >
  >?
  create;

  final _i1.PrismaUnion<
    _i2.PostsCreateOrConnectWithoutUserInput,
    Iterable<_i2.PostsCreateOrConnectWithoutUserInput>
  >?
  connectOrCreate;

  final _i1.PrismaUnion<
    _i2.PostsUpsertWithWhereUniqueWithoutUserInput,
    Iterable<_i2.PostsUpsertWithWhereUniqueWithoutUserInput>
  >?
  upsert;

  final _i2.PostsCreateManyUserInputEnvelope? createMany;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  set;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  disconnect;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  delete;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  connect;

  final _i1.PrismaUnion<
    _i2.PostsUpdateWithWhereUniqueWithoutUserInput,
    Iterable<_i2.PostsUpdateWithWhereUniqueWithoutUserInput>
  >?
  update;

  final _i1.PrismaUnion<
    _i2.PostsUpdateManyWithWhereWithoutUserInput,
    Iterable<_i2.PostsUpdateManyWithWhereWithoutUserInput>
  >?
  updateMany;

  final _i1.PrismaUnion<
    _i2.PostsScalarWhereInput,
    Iterable<_i2.PostsScalarWhereInput>
  >?
  deleteMany;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'upsert': upsert,
    'createMany': createMany,
    'set': set,
    'disconnect': disconnect,
    'delete': delete,
    'connect': connect,
    'update': update,
    'updateMany': updateMany,
    'deleteMany': deleteMany,
  };
}

class UsersUncheckedUpdateWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUncheckedUpdateWithoutPostDetailsInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  email;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  firstName;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  lastName;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NullableBigIntFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  deletedAt;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  status;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  tags;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  scores;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  final _i2.PostsUncheckedUpdateManyWithoutUserNestedInput? posts;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
  };
}

class UsersUpsertWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpsertWithoutPostDetailsInput({
    required this.update,
    required this.create,
    this.where,
  });

  final _i1.PrismaUnion<
    _i2.UsersUpdateWithoutPostDetailsInput,
    _i2.UsersUncheckedUpdateWithoutPostDetailsInput
  >
  update;

  final _i1.PrismaUnion<
    _i2.UsersCreateWithoutPostDetailsInput,
    _i2.UsersUncheckedCreateWithoutPostDetailsInput
  >
  create;

  final _i2.UsersWhereInput? where;

  @override
  Map<String, dynamic> toJson() => {
    'update': update,
    'create': create,
    'where': where,
  };
}

class UsersUpdateToOneWithWhereWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpdateToOneWithWhereWithoutPostDetailsInput({
    this.where,
    required this.data,
  });

  final _i2.UsersWhereInput? where;

  final _i1.PrismaUnion<
    _i2.UsersUpdateWithoutPostDetailsInput,
    _i2.UsersUncheckedUpdateWithoutPostDetailsInput
  >
  data;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'data': data};
}

class UsersUpdateOneWithoutPostDetailsNestedInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpdateOneWithoutPostDetailsNestedInput({
    this.create,
    this.connectOrCreate,
    this.upsert,
    this.disconnect,
    this.delete,
    this.connect,
    this.update,
  });

  final _i1.PrismaUnion<
    _i2.UsersCreateWithoutPostDetailsInput,
    _i2.UsersUncheckedCreateWithoutPostDetailsInput
  >?
  create;

  final _i2.UsersCreateOrConnectWithoutPostDetailsInput? connectOrCreate;

  final _i2.UsersUpsertWithoutPostDetailsInput? upsert;

  final _i1.PrismaUnion<bool, _i2.UsersWhereInput>? disconnect;

  final _i1.PrismaUnion<bool, _i2.UsersWhereInput>? delete;

  final _i2.UsersWhereUniqueInput? connect;

  final _i1.PrismaUnion<
    _i2.UsersUpdateToOneWithWhereWithoutPostDetailsInput,
    _i1.PrismaUnion<
      _i2.UsersUpdateWithoutPostDetailsInput,
      _i2.UsersUncheckedUpdateWithoutPostDetailsInput
    >
  >?
  update;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'upsert': upsert,
    'disconnect': disconnect,
    'delete': delete,
    'connect': connect,
    'update': update,
  };
}

class PostDetailsUpdateWithoutPostInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpdateWithoutPostInput({
    this.likes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  final _i2.UsersUpdateOneWithoutPostDetailsNestedInput? user;

  @override
  Map<String, dynamic> toJson() => {
    'likes': likes,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'user': user,
  };
}

class PostDetailsUpsertWithoutPostInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpsertWithoutPostInput({
    required this.update,
    required this.create,
    this.where,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateWithoutPostInput,
    _i2.PostDetailsUncheckedUpdateWithoutPostInput
  >
  update;

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutPostInput,
    _i2.PostDetailsUncheckedCreateWithoutPostInput
  >
  create;

  final _i2.PostDetailsWhereInput? where;

  @override
  Map<String, dynamic> toJson() => {
    'update': update,
    'create': create,
    'where': where,
  };
}

class PostDetailsUpdateOneWithoutPostNestedInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpdateOneWithoutPostNestedInput({
    this.create,
    this.connectOrCreate,
    this.upsert,
    this.disconnect,
    this.delete,
    this.connect,
    this.update,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutPostInput,
    _i2.PostDetailsUncheckedCreateWithoutPostInput
  >?
  create;

  final _i2.PostDetailsCreateOrConnectWithoutPostInput? connectOrCreate;

  final _i2.PostDetailsUpsertWithoutPostInput? upsert;

  final _i1.PrismaUnion<bool, _i2.PostDetailsWhereInput>? disconnect;

  final _i1.PrismaUnion<bool, _i2.PostDetailsWhereInput>? delete;

  final _i2.PostDetailsWhereUniqueInput? connect;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateToOneWithWhereWithoutPostInput,
    _i1.PrismaUnion<
      _i2.PostDetailsUpdateWithoutPostInput,
      _i2.PostDetailsUncheckedUpdateWithoutPostInput
    >
  >?
  update;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'upsert': upsert,
    'disconnect': disconnect,
    'delete': delete,
    'connect': connect,
    'update': update,
  };
}

class PostsUpdateWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpdateWithoutUserInput({
    this.title,
    this.content,
    this.views,
    this.postDetails,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  title;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  content;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  views;

  final _i2.PostDetailsUpdateOneWithoutPostNestedInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'views': views,
    'post_details': postDetails,
  };
}

class PostsUpsertWithWhereUniqueWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpsertWithWhereUniqueWithoutUserInput({
    required this.where,
    required this.update,
    required this.create,
  });

  final _i2.PostsWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.PostsUpdateWithoutUserInput,
    _i2.PostsUncheckedUpdateWithoutUserInput
  >
  update;

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutUserInput,
    _i2.PostsUncheckedCreateWithoutUserInput
  >
  create;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'update': update,
    'create': create,
  };
}

class PostsUpdateManyWithoutUserNestedInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpdateManyWithoutUserNestedInput({
    this.create,
    this.connectOrCreate,
    this.upsert,
    this.createMany,
    this.set,
    this.disconnect,
    this.delete,
    this.connect,
    this.update,
    this.updateMany,
    this.deleteMany,
  });

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutUserInput,
    _i1.PrismaUnion<
      Iterable<_i2.PostsCreateWithoutUserInput>,
      _i1.PrismaUnion<
        _i2.PostsUncheckedCreateWithoutUserInput,
        Iterable<_i2.PostsUncheckedCreateWithoutUserInput>
      >
    >
  >?
  create;

  final _i1.PrismaUnion<
    _i2.PostsCreateOrConnectWithoutUserInput,
    Iterable<_i2.PostsCreateOrConnectWithoutUserInput>
  >?
  connectOrCreate;

  final _i1.PrismaUnion<
    _i2.PostsUpsertWithWhereUniqueWithoutUserInput,
    Iterable<_i2.PostsUpsertWithWhereUniqueWithoutUserInput>
  >?
  upsert;

  final _i2.PostsCreateManyUserInputEnvelope? createMany;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  set;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  disconnect;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  delete;

  final _i1.PrismaUnion<
    _i2.PostsWhereUniqueInput,
    Iterable<_i2.PostsWhereUniqueInput>
  >?
  connect;

  final _i1.PrismaUnion<
    _i2.PostsUpdateWithWhereUniqueWithoutUserInput,
    Iterable<_i2.PostsUpdateWithWhereUniqueWithoutUserInput>
  >?
  update;

  final _i1.PrismaUnion<
    _i2.PostsUpdateManyWithWhereWithoutUserInput,
    Iterable<_i2.PostsUpdateManyWithWhereWithoutUserInput>
  >?
  updateMany;

  final _i1.PrismaUnion<
    _i2.PostsScalarWhereInput,
    Iterable<_i2.PostsScalarWhereInput>
  >?
  deleteMany;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'upsert': upsert,
    'createMany': createMany,
    'set': set,
    'disconnect': disconnect,
    'delete': delete,
    'connect': connect,
    'update': update,
    'updateMany': updateMany,
    'deleteMany': deleteMany,
  };
}

class UsersUpdateWithoutPostsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpdateWithoutPostsInput({
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.postDetails,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  email;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  firstName;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  lastName;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NullableBigIntFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  deletedAt;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  status;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  tags;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  scores;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  final _i2.PostDetailsUpdateManyWithoutUserNestedInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post_details': postDetails,
  };
}

class PostDetailsUncheckedUpdateWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedUpdateWithoutUserInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  postId;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsUpdateWithWhereUniqueWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpdateWithWhereUniqueWithoutUserInput({
    required this.where,
    required this.data,
  });

  final _i2.PostDetailsWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateWithoutUserInput,
    _i2.PostDetailsUncheckedUpdateWithoutUserInput
  >
  data;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'data': data};
}

class PostDetailsScalarWhereInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsScalarWhereInput({
    this.AND,
    this.OR,
    this.NOT,
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsScalarWhereInput,
    Iterable<_i2.PostDetailsScalarWhereInput>
  >?
  AND;

  final Iterable<_i2.PostDetailsScalarWhereInput>? OR;

  final _i1.PrismaUnion<
    _i2.PostDetailsScalarWhereInput,
    Iterable<_i2.PostDetailsScalarWhereInput>
  >?
  NOT;

  final _i1.PrismaUnion<_i2.IntFilter, int>? id;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    _i2.StringNullableFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  metadata;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  postId;

  final _i1.PrismaUnion<
    _i2.IntNullableFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  createdAt;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsUpdateManyMutationInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpdateManyMutationInput({
    this.likes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'likes': likes,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsUncheckedUpdateManyWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedUpdateManyWithoutUserInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  postId;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsUpdateManyWithWhereWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpdateManyWithWhereWithoutUserInput({
    required this.where,
    required this.data,
  });

  final _i2.PostDetailsScalarWhereInput where;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateManyMutationInput,
    _i2.PostDetailsUncheckedUpdateManyWithoutUserInput
  >
  data;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'data': data};
}

class PostDetailsUncheckedUpdateManyWithoutUserNestedInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedUpdateManyWithoutUserNestedInput({
    this.create,
    this.connectOrCreate,
    this.upsert,
    this.createMany,
    this.set,
    this.disconnect,
    this.delete,
    this.connect,
    this.update,
    this.updateMany,
    this.deleteMany,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutUserInput,
    _i1.PrismaUnion<
      Iterable<_i2.PostDetailsCreateWithoutUserInput>,
      _i1.PrismaUnion<
        _i2.PostDetailsUncheckedCreateWithoutUserInput,
        Iterable<_i2.PostDetailsUncheckedCreateWithoutUserInput>
      >
    >
  >?
  create;

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateOrConnectWithoutUserInput,
    Iterable<_i2.PostDetailsCreateOrConnectWithoutUserInput>
  >?
  connectOrCreate;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpsertWithWhereUniqueWithoutUserInput,
    Iterable<_i2.PostDetailsUpsertWithWhereUniqueWithoutUserInput>
  >?
  upsert;

  final _i2.PostDetailsCreateManyUserInputEnvelope? createMany;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  set;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  disconnect;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  delete;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  connect;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateWithWhereUniqueWithoutUserInput,
    Iterable<_i2.PostDetailsUpdateWithWhereUniqueWithoutUserInput>
  >?
  update;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateManyWithWhereWithoutUserInput,
    Iterable<_i2.PostDetailsUpdateManyWithWhereWithoutUserInput>
  >?
  updateMany;

  final _i1.PrismaUnion<
    _i2.PostDetailsScalarWhereInput,
    Iterable<_i2.PostDetailsScalarWhereInput>
  >?
  deleteMany;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'upsert': upsert,
    'createMany': createMany,
    'set': set,
    'disconnect': disconnect,
    'delete': delete,
    'connect': connect,
    'update': update,
    'updateMany': updateMany,
    'deleteMany': deleteMany,
  };
}

class UsersUncheckedUpdateWithoutPostsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUncheckedUpdateWithoutPostsInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.postDetails,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  email;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  firstName;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  lastName;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NullableBigIntFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  deletedAt;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  status;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  tags;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  scores;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  final _i2.PostDetailsUncheckedUpdateManyWithoutUserNestedInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post_details': postDetails,
  };
}

class UsersUpsertWithoutPostsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpsertWithoutPostsInput({
    required this.update,
    required this.create,
    this.where,
  });

  final _i1.PrismaUnion<
    _i2.UsersUpdateWithoutPostsInput,
    _i2.UsersUncheckedUpdateWithoutPostsInput
  >
  update;

  final _i1.PrismaUnion<
    _i2.UsersCreateWithoutPostsInput,
    _i2.UsersUncheckedCreateWithoutPostsInput
  >
  create;

  final _i2.UsersWhereInput? where;

  @override
  Map<String, dynamic> toJson() => {
    'update': update,
    'create': create,
    'where': where,
  };
}

class UsersUpdateToOneWithWhereWithoutPostsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpdateToOneWithWhereWithoutPostsInput({
    this.where,
    required this.data,
  });

  final _i2.UsersWhereInput? where;

  final _i1.PrismaUnion<
    _i2.UsersUpdateWithoutPostsInput,
    _i2.UsersUncheckedUpdateWithoutPostsInput
  >
  data;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'data': data};
}

class UsersUpdateOneWithoutPostsNestedInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpdateOneWithoutPostsNestedInput({
    this.create,
    this.connectOrCreate,
    this.upsert,
    this.disconnect,
    this.delete,
    this.connect,
    this.update,
  });

  final _i1.PrismaUnion<
    _i2.UsersCreateWithoutPostsInput,
    _i2.UsersUncheckedCreateWithoutPostsInput
  >?
  create;

  final _i2.UsersCreateOrConnectWithoutPostsInput? connectOrCreate;

  final _i2.UsersUpsertWithoutPostsInput? upsert;

  final _i1.PrismaUnion<bool, _i2.UsersWhereInput>? disconnect;

  final _i1.PrismaUnion<bool, _i2.UsersWhereInput>? delete;

  final _i2.UsersWhereUniqueInput? connect;

  final _i1.PrismaUnion<
    _i2.UsersUpdateToOneWithWhereWithoutPostsInput,
    _i1.PrismaUnion<
      _i2.UsersUpdateWithoutPostsInput,
      _i2.UsersUncheckedUpdateWithoutPostsInput
    >
  >?
  update;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'upsert': upsert,
    'disconnect': disconnect,
    'delete': delete,
    'connect': connect,
    'update': update,
  };
}

class PostsUpdateWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpdateWithoutPostDetailsInput({
    this.title,
    this.content,
    this.views,
    this.user,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  title;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  content;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  views;

  final _i2.UsersUpdateOneWithoutPostsNestedInput? user;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'views': views,
    'user': user,
  };
}

class PostsUncheckedUpdateWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedUpdateWithoutPostDetailsInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  title;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  content;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsUpsertWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpsertWithoutPostDetailsInput({
    required this.update,
    required this.create,
    this.where,
  });

  final _i1.PrismaUnion<
    _i2.PostsUpdateWithoutPostDetailsInput,
    _i2.PostsUncheckedUpdateWithoutPostDetailsInput
  >
  update;

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutPostDetailsInput,
    _i2.PostsUncheckedCreateWithoutPostDetailsInput
  >
  create;

  final _i2.PostsWhereInput? where;

  @override
  Map<String, dynamic> toJson() => {
    'update': update,
    'create': create,
    'where': where,
  };
}

class PostsUpdateToOneWithWhereWithoutPostDetailsInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpdateToOneWithWhereWithoutPostDetailsInput({
    this.where,
    required this.data,
  });

  final _i2.PostsWhereInput? where;

  final _i1.PrismaUnion<
    _i2.PostsUpdateWithoutPostDetailsInput,
    _i2.PostsUncheckedUpdateWithoutPostDetailsInput
  >
  data;

  @override
  Map<String, dynamic> toJson() => {'where': where, 'data': data};
}

class PostsUpdateOneWithoutPostDetailsNestedInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpdateOneWithoutPostDetailsNestedInput({
    this.create,
    this.connectOrCreate,
    this.upsert,
    this.disconnect,
    this.delete,
    this.connect,
    this.update,
  });

  final _i1.PrismaUnion<
    _i2.PostsCreateWithoutPostDetailsInput,
    _i2.PostsUncheckedCreateWithoutPostDetailsInput
  >?
  create;

  final _i2.PostsCreateOrConnectWithoutPostDetailsInput? connectOrCreate;

  final _i2.PostsUpsertWithoutPostDetailsInput? upsert;

  final _i1.PrismaUnion<bool, _i2.PostsWhereInput>? disconnect;

  final _i1.PrismaUnion<bool, _i2.PostsWhereInput>? delete;

  final _i2.PostsWhereUniqueInput? connect;

  final _i1.PrismaUnion<
    _i2.PostsUpdateToOneWithWhereWithoutPostDetailsInput,
    _i1.PrismaUnion<
      _i2.PostsUpdateWithoutPostDetailsInput,
      _i2.PostsUncheckedUpdateWithoutPostDetailsInput
    >
  >?
  update;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'upsert': upsert,
    'disconnect': disconnect,
    'delete': delete,
    'connect': connect,
    'update': update,
  };
}

class PostDetailsUpdateWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpdateWithoutUserInput({
    this.likes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.post,
  });

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  final _i2.PostsUpdateOneWithoutPostDetailsNestedInput? post;

  @override
  Map<String, dynamic> toJson() => {
    'likes': likes,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post': post,
  };
}

class PostDetailsUpsertWithWhereUniqueWithoutUserInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpsertWithWhereUniqueWithoutUserInput({
    required this.where,
    required this.update,
    required this.create,
  });

  final _i2.PostDetailsWhereUniqueInput where;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateWithoutUserInput,
    _i2.PostDetailsUncheckedUpdateWithoutUserInput
  >
  update;

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutUserInput,
    _i2.PostDetailsUncheckedCreateWithoutUserInput
  >
  create;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'update': update,
    'create': create,
  };
}

class PostDetailsUpdateManyWithoutUserNestedInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpdateManyWithoutUserNestedInput({
    this.create,
    this.connectOrCreate,
    this.upsert,
    this.createMany,
    this.set,
    this.disconnect,
    this.delete,
    this.connect,
    this.update,
    this.updateMany,
    this.deleteMany,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateWithoutUserInput,
    _i1.PrismaUnion<
      Iterable<_i2.PostDetailsCreateWithoutUserInput>,
      _i1.PrismaUnion<
        _i2.PostDetailsUncheckedCreateWithoutUserInput,
        Iterable<_i2.PostDetailsUncheckedCreateWithoutUserInput>
      >
    >
  >?
  create;

  final _i1.PrismaUnion<
    _i2.PostDetailsCreateOrConnectWithoutUserInput,
    Iterable<_i2.PostDetailsCreateOrConnectWithoutUserInput>
  >?
  connectOrCreate;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpsertWithWhereUniqueWithoutUserInput,
    Iterable<_i2.PostDetailsUpsertWithWhereUniqueWithoutUserInput>
  >?
  upsert;

  final _i2.PostDetailsCreateManyUserInputEnvelope? createMany;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  set;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  disconnect;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  delete;

  final _i1.PrismaUnion<
    _i2.PostDetailsWhereUniqueInput,
    Iterable<_i2.PostDetailsWhereUniqueInput>
  >?
  connect;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateWithWhereUniqueWithoutUserInput,
    Iterable<_i2.PostDetailsUpdateWithWhereUniqueWithoutUserInput>
  >?
  update;

  final _i1.PrismaUnion<
    _i2.PostDetailsUpdateManyWithWhereWithoutUserInput,
    Iterable<_i2.PostDetailsUpdateManyWithWhereWithoutUserInput>
  >?
  updateMany;

  final _i1.PrismaUnion<
    _i2.PostDetailsScalarWhereInput,
    Iterable<_i2.PostDetailsScalarWhereInput>
  >?
  deleteMany;

  @override
  Map<String, dynamic> toJson() => {
    'create': create,
    'connectOrCreate': connectOrCreate,
    'upsert': upsert,
    'createMany': createMany,
    'set': set,
    'disconnect': disconnect,
    'delete': delete,
    'connect': connect,
    'update': update,
    'updateMany': updateMany,
    'deleteMany': deleteMany,
  };
}

class UsersUpdateInput implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpdateInput({
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
    this.postDetails,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  email;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  firstName;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  lastName;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NullableBigIntFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  deletedAt;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  status;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  tags;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  scores;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  final _i2.PostsUpdateManyWithoutUserNestedInput? posts;

  final _i2.PostDetailsUpdateManyWithoutUserNestedInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
    'post_details': postDetails,
  };
}

class UsersUncheckedUpdateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUncheckedUpdateInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.posts,
    this.postDetails,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  email;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  firstName;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  lastName;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NullableBigIntFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  deletedAt;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  status;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  tags;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  scores;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  final _i2.PostsUncheckedUpdateManyWithoutUserNestedInput? posts;

  final _i2.PostDetailsUncheckedUpdateManyWithoutUserNestedInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'posts': posts,
    'post_details': postDetails,
  };
}

class UsersUpdateManyMutationInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUpdateManyMutationInput({
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  email;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  firstName;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  lastName;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NullableBigIntFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  deletedAt;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  status;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  tags;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  scores;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class UsersUncheckedUpdateManyInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersUncheckedUpdateManyInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  email;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  firstName;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  lastName;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NullableBigIntFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  deletedAt;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  status;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  tags;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  scores;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class UsersCountAggregateOutputType {
  const UsersCountAggregateOutputType({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.$all,
  });

  factory UsersCountAggregateOutputType.fromJson(Map json) =>
      UsersCountAggregateOutputType(
        id: json['id'],
        email: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        phoneNumber: json['phone_number'],
        deletedAt: json['deleted_at'],
        status: json['status'],
        tags: json['tags'],
        scores: json['scores'],
        metadata: json['metadata'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        $all: json['_all'],
      );

  final int? id;

  final int? email;

  final int? firstName;

  final int? lastName;

  final int? phoneNumber;

  final int? deletedAt;

  final int? status;

  final int? tags;

  final int? scores;

  final int? metadata;

  final int? createdAt;

  final int? updatedAt;

  final int? $all;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    '_all': $all,
  };
}

class UsersAvgAggregateOutputType {
  const UsersAvgAggregateOutputType({this.id, this.phoneNumber});

  factory UsersAvgAggregateOutputType.fromJson(Map json) =>
      UsersAvgAggregateOutputType(
        id: json['id'],
        phoneNumber: json['phone_number'],
      );

  final double? id;

  final double? phoneNumber;

  Map<String, dynamic> toJson() => {'id': id, 'phone_number': phoneNumber};
}

class UsersSumAggregateOutputType {
  const UsersSumAggregateOutputType({this.id, this.phoneNumber});

  factory UsersSumAggregateOutputType.fromJson(Map json) =>
      UsersSumAggregateOutputType(
        id: json['id'],
        phoneNumber: json['phone_number'],
      );

  final int? id;

  final BigInt? phoneNumber;

  Map<String, dynamic> toJson() => {'id': id, 'phone_number': phoneNumber};
}

class UsersMinAggregateOutputType {
  const UsersMinAggregateOutputType({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory UsersMinAggregateOutputType.fromJson(Map json) =>
      UsersMinAggregateOutputType(
        id: json['id'],
        email: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        phoneNumber: json['phone_number'],
        deletedAt: switch (json['deleted_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['deleted_at'],
        },
        status: json['status'],
        tags: json['tags'],
        scores: json['scores'],
        metadata: json['metadata'],
        createdAt: switch (json['created_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['created_at'],
        },
        updatedAt: switch (json['updated_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['updated_at'],
        },
      );

  final int? id;

  final String? email;

  final String? firstName;

  final String? lastName;

  final BigInt? phoneNumber;

  final DateTime? deletedAt;

  final String? status;

  final String? tags;

  final String? scores;

  final String? metadata;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt?.toIso8601String(),
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class UsersMaxAggregateOutputType {
  const UsersMaxAggregateOutputType({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory UsersMaxAggregateOutputType.fromJson(Map json) =>
      UsersMaxAggregateOutputType(
        id: json['id'],
        email: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        phoneNumber: json['phone_number'],
        deletedAt: switch (json['deleted_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['deleted_at'],
        },
        status: json['status'],
        tags: json['tags'],
        scores: json['scores'],
        metadata: json['metadata'],
        createdAt: switch (json['created_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['created_at'],
        },
        updatedAt: switch (json['updated_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['updated_at'],
        },
      );

  final int? id;

  final String? email;

  final String? firstName;

  final String? lastName;

  final BigInt? phoneNumber;

  final DateTime? deletedAt;

  final String? status;

  final String? tags;

  final String? scores;

  final String? metadata;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt?.toIso8601String(),
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class UsersGroupByOutputType {
  const UsersGroupByOutputType({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  factory UsersGroupByOutputType.fromJson(Map json) => UsersGroupByOutputType(
    id: json['id'],
    email: json['email'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    phoneNumber: json['phone_number'],
    deletedAt: switch (json['deleted_at']) {
      DateTime value => value,
      String value => DateTime.parse(value),
      _ => json['deleted_at'],
    },
    status: json['status'],
    tags: json['tags'],
    scores: json['scores'],
    metadata: json['metadata'],
    createdAt: switch (json['created_at']) {
      DateTime value => value,
      String value => DateTime.parse(value),
      _ => json['created_at'],
    },
    updatedAt: switch (json['updated_at']) {
      DateTime value => value,
      String value => DateTime.parse(value),
      _ => json['updated_at'],
    },
    $count: json['_count'] is Map
        ? _i2.UsersCountAggregateOutputType.fromJson(json['_count'])
        : null,
    $avg: json['_avg'] is Map
        ? _i2.UsersAvgAggregateOutputType.fromJson(json['_avg'])
        : null,
    $sum: json['_sum'] is Map
        ? _i2.UsersSumAggregateOutputType.fromJson(json['_sum'])
        : null,
    $min: json['_min'] is Map
        ? _i2.UsersMinAggregateOutputType.fromJson(json['_min'])
        : null,
    $max: json['_max'] is Map
        ? _i2.UsersMaxAggregateOutputType.fromJson(json['_max'])
        : null,
  );

  final int? id;

  final String? email;

  final String? firstName;

  final String? lastName;

  final BigInt? phoneNumber;

  final DateTime? deletedAt;

  final String? status;

  final String? tags;

  final String? scores;

  final String? metadata;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final _i2.UsersCountAggregateOutputType? $count;

  final _i2.UsersAvgAggregateOutputType? $avg;

  final _i2.UsersSumAggregateOutputType? $sum;

  final _i2.UsersMinAggregateOutputType? $min;

  final _i2.UsersMaxAggregateOutputType? $max;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt?.toIso8601String(),
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    '_count': $count?.toJson(),
    '_avg': $avg?.toJson(),
    '_sum': $sum?.toJson(),
    '_min': $min?.toJson(),
    '_max': $max?.toJson(),
  };
}

class UsersCountOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCountOrderByAggregateInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? email;

  final _i2.SortOrder? firstName;

  final _i2.SortOrder? lastName;

  final _i2.SortOrder? phoneNumber;

  final _i2.SortOrder? deletedAt;

  final _i2.SortOrder? status;

  final _i2.SortOrder? tags;

  final _i2.SortOrder? scores;

  final _i2.SortOrder? metadata;

  final _i2.SortOrder? createdAt;

  final _i2.SortOrder? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class UsersAvgOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersAvgOrderByAggregateInput({this.id, this.phoneNumber});

  final _i2.SortOrder? id;

  final _i2.SortOrder? phoneNumber;

  @override
  Map<String, dynamic> toJson() => {'id': id, 'phone_number': phoneNumber};
}

class UsersMaxOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersMaxOrderByAggregateInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? email;

  final _i2.SortOrder? firstName;

  final _i2.SortOrder? lastName;

  final _i2.SortOrder? phoneNumber;

  final _i2.SortOrder? deletedAt;

  final _i2.SortOrder? status;

  final _i2.SortOrder? tags;

  final _i2.SortOrder? scores;

  final _i2.SortOrder? metadata;

  final _i2.SortOrder? createdAt;

  final _i2.SortOrder? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class UsersMinOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersMinOrderByAggregateInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? email;

  final _i2.SortOrder? firstName;

  final _i2.SortOrder? lastName;

  final _i2.SortOrder? phoneNumber;

  final _i2.SortOrder? deletedAt;

  final _i2.SortOrder? status;

  final _i2.SortOrder? tags;

  final _i2.SortOrder? scores;

  final _i2.SortOrder? metadata;

  final _i2.SortOrder? createdAt;

  final _i2.SortOrder? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class UsersSumOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersSumOrderByAggregateInput({this.id, this.phoneNumber});

  final _i2.SortOrder? id;

  final _i2.SortOrder? phoneNumber;

  @override
  Map<String, dynamic> toJson() => {'id': id, 'phone_number': phoneNumber};
}

class UsersOrderByWithAggregationInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersOrderByWithAggregationInput({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.$count,
    this.$avg,
    this.$max,
    this.$min,
    this.$sum,
  });

  final _i2.SortOrder? id;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? email;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? firstName;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? lastName;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? phoneNumber;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? deletedAt;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? status;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? tags;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? scores;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? metadata;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? createdAt;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? updatedAt;

  final _i2.UsersCountOrderByAggregateInput? $count;

  final _i2.UsersAvgOrderByAggregateInput? $avg;

  final _i2.UsersMaxOrderByAggregateInput? $max;

  final _i2.UsersMinOrderByAggregateInput? $min;

  final _i2.UsersSumOrderByAggregateInput? $sum;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    '_count': $count,
    '_avg': $avg,
    '_max': $max,
    '_min': $min,
    '_sum': $sum,
  };
}

class NestedFloatFilter implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedFloatFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<double, _i1.Reference<double>>? equals;

  final _i1.PrismaUnion<Iterable<double>, _i1.Reference<Iterable<double>>>? $in;

  final _i1.PrismaUnion<Iterable<double>, _i1.Reference<Iterable<double>>>?
  notIn;

  final _i1.PrismaUnion<double, _i1.Reference<double>>? lt;

  final _i1.PrismaUnion<double, _i1.Reference<double>>? lte;

  final _i1.PrismaUnion<double, _i1.Reference<double>>? gt;

  final _i1.PrismaUnion<double, _i1.Reference<double>>? gte;

  final _i1.PrismaUnion<double, _i2.NestedFloatFilter>? not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

class NestedIntWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedIntWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<int, _i1.Reference<int>>? equals;

  final _i1.PrismaUnion<Iterable<int>, _i1.Reference<Iterable<int>>>? $in;

  final _i1.PrismaUnion<Iterable<int>, _i1.Reference<Iterable<int>>>? notIn;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lte;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gte;

  final _i1.PrismaUnion<int, _i2.NestedIntWithAggregatesFilter>? not;

  final _i2.NestedIntFilter? $count;

  final _i2.NestedFloatFilter? $avg;

  final _i2.NestedIntFilter? $sum;

  final _i2.NestedIntFilter? $min;

  final _i2.NestedIntFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class IntWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const IntWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<int, _i1.Reference<int>>? equals;

  final _i1.PrismaUnion<Iterable<int>, _i1.Reference<Iterable<int>>>? $in;

  final _i1.PrismaUnion<Iterable<int>, _i1.Reference<Iterable<int>>>? notIn;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lte;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gte;

  final _i1.PrismaUnion<int, _i2.NestedIntWithAggregatesFilter>? not;

  final _i2.NestedIntFilter? $count;

  final _i2.NestedFloatFilter? $avg;

  final _i2.NestedIntFilter? $sum;

  final _i2.NestedIntFilter? $min;

  final _i2.NestedIntFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class NestedStringNullableWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedStringNullableWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.contains,
    this.startsWith,
    this.endsWith,
    this.not,
    this.$count,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<_i1.Reference<String>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<String>,
    _i1.PrismaUnion<_i1.Reference<Iterable<String>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<String>,
    _i1.PrismaUnion<_i1.Reference<Iterable<String>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? lt;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? lte;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? gt;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? gte;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? contains;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? startsWith;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? endsWith;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NestedStringNullableWithAggregatesFilter,
      _i1.PrismaNull
    >
  >?
  not;

  final _i2.NestedIntNullableFilter? $count;

  final _i2.NestedStringNullableFilter? $min;

  final _i2.NestedStringNullableFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'contains': contains,
    'startsWith': startsWith,
    'endsWith': endsWith,
    'not': not,
    '_count': $count,
    '_min': $min,
    '_max': $max,
  };
}

class StringNullableWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const StringNullableWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.contains,
    this.startsWith,
    this.endsWith,
    this.mode,
    this.not,
    this.$count,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<_i1.Reference<String>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<String>,
    _i1.PrismaUnion<_i1.Reference<Iterable<String>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<String>,
    _i1.PrismaUnion<_i1.Reference<Iterable<String>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? lt;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? lte;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? gt;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? gte;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? contains;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? startsWith;

  final _i1.PrismaUnion<String, _i1.Reference<String>>? endsWith;

  final _i2.QueryMode? mode;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NestedStringNullableWithAggregatesFilter,
      _i1.PrismaNull
    >
  >?
  not;

  final _i2.NestedIntNullableFilter? $count;

  final _i2.NestedStringNullableFilter? $min;

  final _i2.NestedStringNullableFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'contains': contains,
    'startsWith': startsWith,
    'endsWith': endsWith,
    'mode': mode,
    'not': not,
    '_count': $count,
    '_min': $min,
    '_max': $max,
  };
}

class NestedFloatNullableFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedFloatNullableFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
  });

  final _i1.PrismaUnion<
    double,
    _i1.PrismaUnion<_i1.Reference<double>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<double>,
    _i1.PrismaUnion<_i1.Reference<Iterable<double>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<double>,
    _i1.PrismaUnion<_i1.Reference<Iterable<double>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<double, _i1.Reference<double>>? lt;

  final _i1.PrismaUnion<double, _i1.Reference<double>>? lte;

  final _i1.PrismaUnion<double, _i1.Reference<double>>? gt;

  final _i1.PrismaUnion<double, _i1.Reference<double>>? gte;

  final _i1.PrismaUnion<
    double,
    _i1.PrismaUnion<_i2.NestedFloatNullableFilter, _i1.PrismaNull>
  >?
  not;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
  };
}

class NestedBigIntNullableWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedBigIntNullableWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<_i1.Reference<BigInt>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<BigInt>,
    _i1.PrismaUnion<_i1.Reference<Iterable<BigInt>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<BigInt>,
    _i1.PrismaUnion<_i1.Reference<Iterable<BigInt>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? lt;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? lte;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? gt;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? gte;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NestedBigIntNullableWithAggregatesFilter,
      _i1.PrismaNull
    >
  >?
  not;

  final _i2.NestedIntNullableFilter? $count;

  final _i2.NestedFloatNullableFilter? $avg;

  final _i2.NestedBigIntNullableFilter? $sum;

  final _i2.NestedBigIntNullableFilter? $min;

  final _i2.NestedBigIntNullableFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class BigIntNullableWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const BigIntNullableWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<_i1.Reference<BigInt>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<BigInt>,
    _i1.PrismaUnion<_i1.Reference<Iterable<BigInt>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<BigInt>,
    _i1.PrismaUnion<_i1.Reference<Iterable<BigInt>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? lt;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? lte;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? gt;

  final _i1.PrismaUnion<BigInt, _i1.Reference<BigInt>>? gte;

  final _i1.PrismaUnion<
    BigInt,
    _i1.PrismaUnion<
      _i2.NestedBigIntNullableWithAggregatesFilter,
      _i1.PrismaNull
    >
  >?
  not;

  final _i2.NestedIntNullableFilter? $count;

  final _i2.NestedFloatNullableFilter? $avg;

  final _i2.NestedBigIntNullableFilter? $sum;

  final _i2.NestedBigIntNullableFilter? $min;

  final _i2.NestedBigIntNullableFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class NestedDateTimeNullableWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedDateTimeNullableWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
    this.$count,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<_i1.Reference<DateTime>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<DateTime>,
    _i1.PrismaUnion<_i1.Reference<Iterable<DateTime>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<DateTime>,
    _i1.PrismaUnion<_i1.Reference<Iterable<DateTime>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? lt;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? lte;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? gt;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? gte;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NestedDateTimeNullableWithAggregatesFilter,
      _i1.PrismaNull
    >
  >?
  not;

  final _i2.NestedIntNullableFilter? $count;

  final _i2.NestedDateTimeNullableFilter? $min;

  final _i2.NestedDateTimeNullableFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
    '_count': $count,
    '_min': $min,
    '_max': $max,
  };
}

class DateTimeNullableWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const DateTimeNullableWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
    this.$count,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<_i1.Reference<DateTime>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<DateTime>,
    _i1.PrismaUnion<_i1.Reference<Iterable<DateTime>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<DateTime>,
    _i1.PrismaUnion<_i1.Reference<Iterable<DateTime>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? lt;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? lte;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? gt;

  final _i1.PrismaUnion<DateTime, _i1.Reference<DateTime>>? gte;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NestedDateTimeNullableWithAggregatesFilter,
      _i1.PrismaNull
    >
  >?
  not;

  final _i2.NestedIntNullableFilter? $count;

  final _i2.NestedDateTimeNullableFilter? $min;

  final _i2.NestedDateTimeNullableFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
    '_count': $count,
    '_min': $min,
    '_max': $max,
  };
}

class UsersScalarWhereWithAggregatesInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersScalarWhereWithAggregatesInput({
    this.AND,
    this.OR,
    this.NOT,
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<
    _i2.UsersScalarWhereWithAggregatesInput,
    Iterable<_i2.UsersScalarWhereWithAggregatesInput>
  >?
  AND;

  final Iterable<_i2.UsersScalarWhereWithAggregatesInput>? OR;

  final _i1.PrismaUnion<
    _i2.UsersScalarWhereWithAggregatesInput,
    Iterable<_i2.UsersScalarWhereWithAggregatesInput>
  >?
  NOT;

  final _i1.PrismaUnion<_i2.IntWithAggregatesFilter, int>? id;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  email;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  firstName;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  lastName;

  final _i1.PrismaUnion<
    _i2.BigIntNullableWithAggregatesFilter,
    _i1.PrismaUnion<BigInt, _i1.PrismaNull>
  >?
  phoneNumber;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableWithAggregatesFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  deletedAt;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  status;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  tags;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  scores;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  metadata;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableWithAggregatesFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  createdAt;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableWithAggregatesFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class UsersCountAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersCountAggregateOutputTypeSelect({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.$all,
  });

  final bool? id;

  final bool? email;

  final bool? firstName;

  final bool? lastName;

  final bool? phoneNumber;

  final bool? deletedAt;

  final bool? status;

  final bool? tags;

  final bool? scores;

  final bool? metadata;

  final bool? createdAt;

  final bool? updatedAt;

  final bool? $all;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    '_all': $all,
  };
}

class UsersGroupByOutputTypeCountArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersGroupByOutputTypeCountArgs({this.select});

  final _i2.UsersCountAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class UsersAvgAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersAvgAggregateOutputTypeSelect({this.id, this.phoneNumber});

  final bool? id;

  final bool? phoneNumber;

  @override
  Map<String, dynamic> toJson() => {'id': id, 'phone_number': phoneNumber};
}

class UsersGroupByOutputTypeAvgArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersGroupByOutputTypeAvgArgs({this.select});

  final _i2.UsersAvgAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class UsersSumAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersSumAggregateOutputTypeSelect({this.id, this.phoneNumber});

  final bool? id;

  final bool? phoneNumber;

  @override
  Map<String, dynamic> toJson() => {'id': id, 'phone_number': phoneNumber};
}

class UsersGroupByOutputTypeSumArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersGroupByOutputTypeSumArgs({this.select});

  final _i2.UsersSumAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class UsersMinAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersMinAggregateOutputTypeSelect({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final bool? id;

  final bool? email;

  final bool? firstName;

  final bool? lastName;

  final bool? phoneNumber;

  final bool? deletedAt;

  final bool? status;

  final bool? tags;

  final bool? scores;

  final bool? metadata;

  final bool? createdAt;

  final bool? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class UsersGroupByOutputTypeMinArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersGroupByOutputTypeMinArgs({this.select});

  final _i2.UsersMinAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class UsersMaxAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersMaxAggregateOutputTypeSelect({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final bool? id;

  final bool? email;

  final bool? firstName;

  final bool? lastName;

  final bool? phoneNumber;

  final bool? deletedAt;

  final bool? status;

  final bool? tags;

  final bool? scores;

  final bool? metadata;

  final bool? createdAt;

  final bool? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class UsersGroupByOutputTypeMaxArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersGroupByOutputTypeMaxArgs({this.select});

  final _i2.UsersMaxAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class UsersGroupByOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const UsersGroupByOutputTypeSelect({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.deletedAt,
    this.status,
    this.tags,
    this.scores,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final bool? id;

  final bool? email;

  final bool? firstName;

  final bool? lastName;

  final bool? phoneNumber;

  final bool? deletedAt;

  final bool? status;

  final bool? tags;

  final bool? scores;

  final bool? metadata;

  final bool? createdAt;

  final bool? updatedAt;

  final _i1.PrismaUnion<bool, _i2.UsersGroupByOutputTypeCountArgs>? $count;

  final _i1.PrismaUnion<bool, _i2.UsersGroupByOutputTypeAvgArgs>? $avg;

  final _i1.PrismaUnion<bool, _i2.UsersGroupByOutputTypeSumArgs>? $sum;

  final _i1.PrismaUnion<bool, _i2.UsersGroupByOutputTypeMinArgs>? $min;

  final _i1.PrismaUnion<bool, _i2.UsersGroupByOutputTypeMaxArgs>? $max;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'deleted_at': deletedAt,
    'status': status,
    'tags': tags,
    'scores': scores,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class AggregateUsers {
  const AggregateUsers({
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  factory AggregateUsers.fromJson(Map json) => AggregateUsers(
    $count: json['_count'] is Map
        ? _i2.UsersCountAggregateOutputType.fromJson(json['_count'])
        : null,
    $avg: json['_avg'] is Map
        ? _i2.UsersAvgAggregateOutputType.fromJson(json['_avg'])
        : null,
    $sum: json['_sum'] is Map
        ? _i2.UsersSumAggregateOutputType.fromJson(json['_sum'])
        : null,
    $min: json['_min'] is Map
        ? _i2.UsersMinAggregateOutputType.fromJson(json['_min'])
        : null,
    $max: json['_max'] is Map
        ? _i2.UsersMaxAggregateOutputType.fromJson(json['_max'])
        : null,
  );

  final _i2.UsersCountAggregateOutputType? $count;

  final _i2.UsersAvgAggregateOutputType? $avg;

  final _i2.UsersSumAggregateOutputType? $sum;

  final _i2.UsersMinAggregateOutputType? $min;

  final _i2.UsersMaxAggregateOutputType? $max;

  Map<String, dynamic> toJson() => {
    '_count': $count?.toJson(),
    '_avg': $avg?.toJson(),
    '_sum': $sum?.toJson(),
    '_min': $min?.toJson(),
    '_max': $max?.toJson(),
  };
}

class AggregateUsersCountArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregateUsersCountArgs({this.select});

  final _i2.UsersCountAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregateUsersAvgArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregateUsersAvgArgs({this.select});

  final _i2.UsersAvgAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregateUsersSumArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregateUsersSumArgs({this.select});

  final _i2.UsersSumAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregateUsersMinArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregateUsersMinArgs({this.select});

  final _i2.UsersMinAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregateUsersMaxArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregateUsersMaxArgs({this.select});

  final _i2.UsersMaxAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregateUsersSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregateUsersSelect({
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<bool, _i2.AggregateUsersCountArgs>? $count;

  final _i1.PrismaUnion<bool, _i2.AggregateUsersAvgArgs>? $avg;

  final _i1.PrismaUnion<bool, _i2.AggregateUsersSumArgs>? $sum;

  final _i1.PrismaUnion<bool, _i2.AggregateUsersMinArgs>? $min;

  final _i1.PrismaUnion<bool, _i2.AggregateUsersMaxArgs>? $max;

  @override
  Map<String, dynamic> toJson() => {
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class PostsCreateInput implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateInput({
    this.title,
    this.content,
    this.views,
    this.user,
    this.postDetails,
  });

  final _i1.PrismaUnion<String, _i1.PrismaNull>? title;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? content;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? views;

  final _i2.UsersCreateNestedOneWithoutPostsInput? user;

  final _i2.PostDetailsCreateNestedOneWithoutPostInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'views': views,
    'user': user,
    'post_details': postDetails,
  };
}

class PostsUncheckedCreateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedCreateInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.postDetails,
  });

  final int? id;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? title;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? content;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? userId;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? views;

  final _i2.PostDetailsUncheckedCreateNestedOneWithoutPostInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    'post_details': postDetails,
  };
}

class PostsCreateManyInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCreateManyInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final int? id;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? title;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? content;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? userId;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class CreateManyPostsAndReturnOutputTypeUserArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const CreateManyPostsAndReturnOutputTypeUserArgs({
    this.where,
    this.select,
    this.include,
  });

  final _i2.UsersWhereInput? where;

  final _i2.UsersSelect? select;

  final _i2.UsersInclude? include;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'select': select,
    'include': include,
  };
}

class CreateManyPostsAndReturnOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const CreateManyPostsAndReturnOutputTypeSelect({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.user,
  });

  final bool? id;

  final bool? title;

  final bool? content;

  final bool? userId;

  final bool? views;

  final _i1.PrismaUnion<bool, _i2.CreateManyPostsAndReturnOutputTypeUserArgs>?
  user;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    'user': user,
  };
}

class CreateManyPostsAndReturnOutputTypeInclude
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const CreateManyPostsAndReturnOutputTypeInclude({this.user});

  final _i1.PrismaUnion<bool, _i2.CreateManyPostsAndReturnOutputTypeUserArgs>?
  user;

  @override
  Map<String, dynamic> toJson() => {'user': user};
}

class PostsUpdateInput implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUpdateInput({
    this.title,
    this.content,
    this.views,
    this.user,
    this.postDetails,
  });

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  title;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  content;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  views;

  final _i2.UsersUpdateOneWithoutPostsNestedInput? user;

  final _i2.PostDetailsUpdateOneWithoutPostNestedInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'views': views,
    'user': user,
    'post_details': postDetails,
  };
}

class PostsUncheckedUpdateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedUpdateInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.postDetails,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  title;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  content;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  views;

  final _i2.PostDetailsUncheckedUpdateOneWithoutPostNestedInput? postDetails;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    'post_details': postDetails,
  };
}

class PostsUncheckedUpdateManyInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsUncheckedUpdateManyInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  title;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  content;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsCountAggregateOutputType {
  const PostsCountAggregateOutputType({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.$all,
  });

  factory PostsCountAggregateOutputType.fromJson(Map json) =>
      PostsCountAggregateOutputType(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        userId: json['user_id'],
        views: json['views'],
        $all: json['_all'],
      );

  final int? id;

  final int? title;

  final int? content;

  final int? userId;

  final int? views;

  final int? $all;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    '_all': $all,
  };
}

class PostsAvgAggregateOutputType {
  const PostsAvgAggregateOutputType({this.id, this.userId, this.views});

  factory PostsAvgAggregateOutputType.fromJson(Map json) =>
      PostsAvgAggregateOutputType(
        id: json['id'],
        userId: json['user_id'],
        views: json['views'],
      );

  final double? id;

  final double? userId;

  final double? views;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'views': views,
  };
}

class PostsSumAggregateOutputType {
  const PostsSumAggregateOutputType({this.id, this.userId, this.views});

  factory PostsSumAggregateOutputType.fromJson(Map json) =>
      PostsSumAggregateOutputType(
        id: json['id'],
        userId: json['user_id'],
        views: json['views'],
      );

  final int? id;

  final int? userId;

  final int? views;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'views': views,
  };
}

class PostsMinAggregateOutputType {
  const PostsMinAggregateOutputType({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  factory PostsMinAggregateOutputType.fromJson(Map json) =>
      PostsMinAggregateOutputType(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        userId: json['user_id'],
        views: json['views'],
      );

  final int? id;

  final String? title;

  final String? content;

  final int? userId;

  final int? views;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsMaxAggregateOutputType {
  const PostsMaxAggregateOutputType({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  factory PostsMaxAggregateOutputType.fromJson(Map json) =>
      PostsMaxAggregateOutputType(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        userId: json['user_id'],
        views: json['views'],
      );

  final int? id;

  final String? title;

  final String? content;

  final int? userId;

  final int? views;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsGroupByOutputType {
  const PostsGroupByOutputType({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  factory PostsGroupByOutputType.fromJson(Map json) => PostsGroupByOutputType(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    userId: json['user_id'],
    views: json['views'],
    $count: json['_count'] is Map
        ? _i2.PostsCountAggregateOutputType.fromJson(json['_count'])
        : null,
    $avg: json['_avg'] is Map
        ? _i2.PostsAvgAggregateOutputType.fromJson(json['_avg'])
        : null,
    $sum: json['_sum'] is Map
        ? _i2.PostsSumAggregateOutputType.fromJson(json['_sum'])
        : null,
    $min: json['_min'] is Map
        ? _i2.PostsMinAggregateOutputType.fromJson(json['_min'])
        : null,
    $max: json['_max'] is Map
        ? _i2.PostsMaxAggregateOutputType.fromJson(json['_max'])
        : null,
  );

  final int? id;

  final String? title;

  final String? content;

  final int? userId;

  final int? views;

  final _i2.PostsCountAggregateOutputType? $count;

  final _i2.PostsAvgAggregateOutputType? $avg;

  final _i2.PostsSumAggregateOutputType? $sum;

  final _i2.PostsMinAggregateOutputType? $min;

  final _i2.PostsMaxAggregateOutputType? $max;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    '_count': $count?.toJson(),
    '_avg': $avg?.toJson(),
    '_sum': $sum?.toJson(),
    '_min': $min?.toJson(),
    '_max': $max?.toJson(),
  };
}

class PostsCountOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCountOrderByAggregateInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? title;

  final _i2.SortOrder? content;

  final _i2.SortOrder? userId;

  final _i2.SortOrder? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsAvgOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsAvgOrderByAggregateInput({this.id, this.userId, this.views});

  final _i2.SortOrder? id;

  final _i2.SortOrder? userId;

  final _i2.SortOrder? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'views': views,
  };
}

class PostsMaxOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsMaxOrderByAggregateInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? title;

  final _i2.SortOrder? content;

  final _i2.SortOrder? userId;

  final _i2.SortOrder? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsMinOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsMinOrderByAggregateInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? title;

  final _i2.SortOrder? content;

  final _i2.SortOrder? userId;

  final _i2.SortOrder? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsSumOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsSumOrderByAggregateInput({this.id, this.userId, this.views});

  final _i2.SortOrder? id;

  final _i2.SortOrder? userId;

  final _i2.SortOrder? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'views': views,
  };
}

class PostsOrderByWithAggregationInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsOrderByWithAggregationInput({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.$count,
    this.$avg,
    this.$max,
    this.$min,
    this.$sum,
  });

  final _i2.SortOrder? id;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? title;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? content;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? userId;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? views;

  final _i2.PostsCountOrderByAggregateInput? $count;

  final _i2.PostsAvgOrderByAggregateInput? $avg;

  final _i2.PostsMaxOrderByAggregateInput? $max;

  final _i2.PostsMinOrderByAggregateInput? $min;

  final _i2.PostsSumOrderByAggregateInput? $sum;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    '_count': $count,
    '_avg': $avg,
    '_max': $max,
    '_min': $min,
    '_sum': $sum,
  };
}

class NestedIntNullableWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const NestedIntNullableWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i1.Reference<int>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<int>,
    _i1.PrismaUnion<_i1.Reference<Iterable<int>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<int>,
    _i1.PrismaUnion<_i1.Reference<Iterable<int>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lte;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gte;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NestedIntNullableWithAggregatesFilter, _i1.PrismaNull>
  >?
  not;

  final _i2.NestedIntNullableFilter? $count;

  final _i2.NestedFloatNullableFilter? $avg;

  final _i2.NestedIntNullableFilter? $sum;

  final _i2.NestedIntNullableFilter? $min;

  final _i2.NestedIntNullableFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class IntNullableWithAggregatesFilter
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const IntNullableWithAggregatesFilter({
    this.equals,
    this.$in,
    this.notIn,
    this.lt,
    this.lte,
    this.gt,
    this.gte,
    this.not,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i1.Reference<int>, _i1.PrismaNull>
  >?
  equals;

  final _i1.PrismaUnion<
    Iterable<int>,
    _i1.PrismaUnion<_i1.Reference<Iterable<int>>, _i1.PrismaNull>
  >?
  $in;

  final _i1.PrismaUnion<
    Iterable<int>,
    _i1.PrismaUnion<_i1.Reference<Iterable<int>>, _i1.PrismaNull>
  >?
  notIn;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? lte;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gt;

  final _i1.PrismaUnion<int, _i1.Reference<int>>? gte;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NestedIntNullableWithAggregatesFilter, _i1.PrismaNull>
  >?
  not;

  final _i2.NestedIntNullableFilter? $count;

  final _i2.NestedFloatNullableFilter? $avg;

  final _i2.NestedIntNullableFilter? $sum;

  final _i2.NestedIntNullableFilter? $min;

  final _i2.NestedIntNullableFilter? $max;

  @override
  Map<String, dynamic> toJson() => {
    'equals': equals,
    'in': $in,
    'notIn': notIn,
    'lt': lt,
    'lte': lte,
    'gt': gt,
    'gte': gte,
    'not': not,
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class PostsScalarWhereWithAggregatesInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsScalarWhereWithAggregatesInput({
    this.AND,
    this.OR,
    this.NOT,
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final _i1.PrismaUnion<
    _i2.PostsScalarWhereWithAggregatesInput,
    Iterable<_i2.PostsScalarWhereWithAggregatesInput>
  >?
  AND;

  final Iterable<_i2.PostsScalarWhereWithAggregatesInput>? OR;

  final _i1.PrismaUnion<
    _i2.PostsScalarWhereWithAggregatesInput,
    Iterable<_i2.PostsScalarWhereWithAggregatesInput>
  >?
  NOT;

  final _i1.PrismaUnion<_i2.IntWithAggregatesFilter, int>? id;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  title;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  content;

  final _i1.PrismaUnion<
    _i2.IntNullableWithAggregatesFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    _i2.IntNullableWithAggregatesFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  views;

  @override
  Map<String, dynamic> toJson() => {
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsCountAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsCountAggregateOutputTypeSelect({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.$all,
  });

  final bool? id;

  final bool? title;

  final bool? content;

  final bool? userId;

  final bool? views;

  final bool? $all;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    '_all': $all,
  };
}

class PostsGroupByOutputTypeCountArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsGroupByOutputTypeCountArgs({this.select});

  final _i2.PostsCountAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostsAvgAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsAvgAggregateOutputTypeSelect({this.id, this.userId, this.views});

  final bool? id;

  final bool? userId;

  final bool? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'views': views,
  };
}

class PostsGroupByOutputTypeAvgArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsGroupByOutputTypeAvgArgs({this.select});

  final _i2.PostsAvgAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostsSumAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsSumAggregateOutputTypeSelect({this.id, this.userId, this.views});

  final bool? id;

  final bool? userId;

  final bool? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'views': views,
  };
}

class PostsGroupByOutputTypeSumArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsGroupByOutputTypeSumArgs({this.select});

  final _i2.PostsSumAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostsMinAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsMinAggregateOutputTypeSelect({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final bool? id;

  final bool? title;

  final bool? content;

  final bool? userId;

  final bool? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsGroupByOutputTypeMinArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsGroupByOutputTypeMinArgs({this.select});

  final _i2.PostsMinAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostsMaxAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsMaxAggregateOutputTypeSelect({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
  });

  final bool? id;

  final bool? title;

  final bool? content;

  final bool? userId;

  final bool? views;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
  };
}

class PostsGroupByOutputTypeMaxArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsGroupByOutputTypeMaxArgs({this.select});

  final _i2.PostsMaxAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostsGroupByOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostsGroupByOutputTypeSelect({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final bool? id;

  final bool? title;

  final bool? content;

  final bool? userId;

  final bool? views;

  final _i1.PrismaUnion<bool, _i2.PostsGroupByOutputTypeCountArgs>? $count;

  final _i1.PrismaUnion<bool, _i2.PostsGroupByOutputTypeAvgArgs>? $avg;

  final _i1.PrismaUnion<bool, _i2.PostsGroupByOutputTypeSumArgs>? $sum;

  final _i1.PrismaUnion<bool, _i2.PostsGroupByOutputTypeMinArgs>? $min;

  final _i1.PrismaUnion<bool, _i2.PostsGroupByOutputTypeMaxArgs>? $max;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class AggregatePosts {
  const AggregatePosts({
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  factory AggregatePosts.fromJson(Map json) => AggregatePosts(
    $count: json['_count'] is Map
        ? _i2.PostsCountAggregateOutputType.fromJson(json['_count'])
        : null,
    $avg: json['_avg'] is Map
        ? _i2.PostsAvgAggregateOutputType.fromJson(json['_avg'])
        : null,
    $sum: json['_sum'] is Map
        ? _i2.PostsSumAggregateOutputType.fromJson(json['_sum'])
        : null,
    $min: json['_min'] is Map
        ? _i2.PostsMinAggregateOutputType.fromJson(json['_min'])
        : null,
    $max: json['_max'] is Map
        ? _i2.PostsMaxAggregateOutputType.fromJson(json['_max'])
        : null,
  );

  final _i2.PostsCountAggregateOutputType? $count;

  final _i2.PostsAvgAggregateOutputType? $avg;

  final _i2.PostsSumAggregateOutputType? $sum;

  final _i2.PostsMinAggregateOutputType? $min;

  final _i2.PostsMaxAggregateOutputType? $max;

  Map<String, dynamic> toJson() => {
    '_count': $count?.toJson(),
    '_avg': $avg?.toJson(),
    '_sum': $sum?.toJson(),
    '_min': $min?.toJson(),
    '_max': $max?.toJson(),
  };
}

class AggregatePostsCountArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostsCountArgs({this.select});

  final _i2.PostsCountAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostsAvgArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostsAvgArgs({this.select});

  final _i2.PostsAvgAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostsSumArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostsSumArgs({this.select});

  final _i2.PostsSumAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostsMinArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostsMinArgs({this.select});

  final _i2.PostsMinAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostsMaxArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostsMaxArgs({this.select});

  final _i2.PostsMaxAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostsSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostsSelect({
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<bool, _i2.AggregatePostsCountArgs>? $count;

  final _i1.PrismaUnion<bool, _i2.AggregatePostsAvgArgs>? $avg;

  final _i1.PrismaUnion<bool, _i2.AggregatePostsSumArgs>? $sum;

  final _i1.PrismaUnion<bool, _i2.AggregatePostsMinArgs>? $min;

  final _i1.PrismaUnion<bool, _i2.AggregatePostsMaxArgs>? $max;

  @override
  Map<String, dynamic> toJson() => {
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class PostDetailsCreateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateInput({
    this.likes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.post,
    this.user,
  });

  final _i1.PrismaUnion<int, _i1.PrismaNull>? likes;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  final _i2.PostsCreateNestedOneWithoutPostDetailsInput? post;

  final _i2.UsersCreateNestedOneWithoutPostDetailsInput? user;

  @override
  Map<String, dynamic> toJson() => {
    'likes': likes,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post': post,
    'user': user,
  };
}

class PostDetailsUncheckedCreateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedCreateInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? likes;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? postId;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? userId;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsCreateManyInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCreateManyInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? likes;

  final _i1.PrismaUnion<String, _i1.PrismaNull>? metadata;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? postId;

  final _i1.PrismaUnion<int, _i1.PrismaNull>? userId;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? createdAt;

  final _i1.PrismaUnion<DateTime, _i1.PrismaNull>? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class CreateManyPostDetailsAndReturnOutputTypePostArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const CreateManyPostDetailsAndReturnOutputTypePostArgs({
    this.where,
    this.select,
    this.include,
  });

  final _i2.PostsWhereInput? where;

  final _i2.PostsSelect? select;

  final _i2.PostsInclude? include;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'select': select,
    'include': include,
  };
}

class CreateManyPostDetailsAndReturnOutputTypeUserArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const CreateManyPostDetailsAndReturnOutputTypeUserArgs({
    this.where,
    this.select,
    this.include,
  });

  final _i2.UsersWhereInput? where;

  final _i2.UsersSelect? select;

  final _i2.UsersInclude? include;

  @override
  Map<String, dynamic> toJson() => {
    'where': where,
    'select': select,
    'include': include,
  };
}

class CreateManyPostDetailsAndReturnOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const CreateManyPostDetailsAndReturnOutputTypeSelect({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.post,
    this.user,
  });

  final bool? id;

  final bool? likes;

  final bool? metadata;

  final bool? postId;

  final bool? userId;

  final bool? createdAt;

  final bool? updatedAt;

  final _i1.PrismaUnion<
    bool,
    _i2.CreateManyPostDetailsAndReturnOutputTypePostArgs
  >?
  post;

  final _i1.PrismaUnion<
    bool,
    _i2.CreateManyPostDetailsAndReturnOutputTypeUserArgs
  >?
  user;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post': post,
    'user': user,
  };
}

class CreateManyPostDetailsAndReturnOutputTypeInclude
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const CreateManyPostDetailsAndReturnOutputTypeInclude({this.post, this.user});

  final _i1.PrismaUnion<
    bool,
    _i2.CreateManyPostDetailsAndReturnOutputTypePostArgs
  >?
  post;

  final _i1.PrismaUnion<
    bool,
    _i2.CreateManyPostDetailsAndReturnOutputTypeUserArgs
  >?
  user;

  @override
  Map<String, dynamic> toJson() => {'post': post, 'user': user};
}

class PostDetailsUpdateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUpdateInput({
    this.likes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.post,
    this.user,
  });

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  final _i2.PostsUpdateOneWithoutPostDetailsNestedInput? post;

  final _i2.UsersUpdateOneWithoutPostDetailsNestedInput? user;

  @override
  Map<String, dynamic> toJson() => {
    'likes': likes,
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'post': post,
    'user': user,
  };
}

class PostDetailsUncheckedUpdateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedUpdateInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  postId;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsUncheckedUpdateManyInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsUncheckedUpdateManyInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<int, _i2.IntFieldUpdateOperationsInput>? id;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    String,
    _i1.PrismaUnion<
      _i2.NullableStringFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  metadata;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  postId;

  final _i1.PrismaUnion<
    int,
    _i1.PrismaUnion<_i2.NullableIntFieldUpdateOperationsInput, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  createdAt;

  final _i1.PrismaUnion<
    DateTime,
    _i1.PrismaUnion<
      _i2.NullableDateTimeFieldUpdateOperationsInput,
      _i1.PrismaNull
    >
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsCountAggregateOutputType {
  const PostDetailsCountAggregateOutputType({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.$all,
  });

  factory PostDetailsCountAggregateOutputType.fromJson(Map json) =>
      PostDetailsCountAggregateOutputType(
        id: json['id'],
        likes: json['likes'],
        metadata: json['metadata'],
        postId: json['post_id'],
        userId: json['user_id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        $all: json['_all'],
      );

  final int? id;

  final int? likes;

  final int? metadata;

  final int? postId;

  final int? userId;

  final int? createdAt;

  final int? updatedAt;

  final int? $all;

  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    '_all': $all,
  };
}

class PostDetailsAvgAggregateOutputType {
  const PostDetailsAvgAggregateOutputType({
    this.id,
    this.likes,
    this.postId,
    this.userId,
  });

  factory PostDetailsAvgAggregateOutputType.fromJson(Map json) =>
      PostDetailsAvgAggregateOutputType(
        id: json['id'],
        likes: json['likes'],
        postId: json['post_id'],
        userId: json['user_id'],
      );

  final double? id;

  final double? likes;

  final double? postId;

  final double? userId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'post_id': postId,
    'user_id': userId,
  };
}

class PostDetailsSumAggregateOutputType {
  const PostDetailsSumAggregateOutputType({
    this.id,
    this.likes,
    this.postId,
    this.userId,
  });

  factory PostDetailsSumAggregateOutputType.fromJson(Map json) =>
      PostDetailsSumAggregateOutputType(
        id: json['id'],
        likes: json['likes'],
        postId: json['post_id'],
        userId: json['user_id'],
      );

  final int? id;

  final int? likes;

  final int? postId;

  final int? userId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'post_id': postId,
    'user_id': userId,
  };
}

class PostDetailsMinAggregateOutputType {
  const PostDetailsMinAggregateOutputType({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory PostDetailsMinAggregateOutputType.fromJson(Map json) =>
      PostDetailsMinAggregateOutputType(
        id: json['id'],
        likes: json['likes'],
        metadata: json['metadata'],
        postId: json['post_id'],
        userId: json['user_id'],
        createdAt: switch (json['created_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['created_at'],
        },
        updatedAt: switch (json['updated_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['updated_at'],
        },
      );

  final int? id;

  final int? likes;

  final String? metadata;

  final int? postId;

  final int? userId;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class PostDetailsMaxAggregateOutputType {
  const PostDetailsMaxAggregateOutputType({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory PostDetailsMaxAggregateOutputType.fromJson(Map json) =>
      PostDetailsMaxAggregateOutputType(
        id: json['id'],
        likes: json['likes'],
        metadata: json['metadata'],
        postId: json['post_id'],
        userId: json['user_id'],
        createdAt: switch (json['created_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['created_at'],
        },
        updatedAt: switch (json['updated_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['updated_at'],
        },
      );

  final int? id;

  final int? likes;

  final String? metadata;

  final int? postId;

  final int? userId;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

class PostDetailsGroupByOutputType {
  const PostDetailsGroupByOutputType({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  factory PostDetailsGroupByOutputType.fromJson(Map json) =>
      PostDetailsGroupByOutputType(
        id: json['id'],
        likes: json['likes'],
        metadata: json['metadata'],
        postId: json['post_id'],
        userId: json['user_id'],
        createdAt: switch (json['created_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['created_at'],
        },
        updatedAt: switch (json['updated_at']) {
          DateTime value => value,
          String value => DateTime.parse(value),
          _ => json['updated_at'],
        },
        $count: json['_count'] is Map
            ? _i2.PostDetailsCountAggregateOutputType.fromJson(json['_count'])
            : null,
        $avg: json['_avg'] is Map
            ? _i2.PostDetailsAvgAggregateOutputType.fromJson(json['_avg'])
            : null,
        $sum: json['_sum'] is Map
            ? _i2.PostDetailsSumAggregateOutputType.fromJson(json['_sum'])
            : null,
        $min: json['_min'] is Map
            ? _i2.PostDetailsMinAggregateOutputType.fromJson(json['_min'])
            : null,
        $max: json['_max'] is Map
            ? _i2.PostDetailsMaxAggregateOutputType.fromJson(json['_max'])
            : null,
      );

  final int? id;

  final int? likes;

  final String? metadata;

  final int? postId;

  final int? userId;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final _i2.PostDetailsCountAggregateOutputType? $count;

  final _i2.PostDetailsAvgAggregateOutputType? $avg;

  final _i2.PostDetailsSumAggregateOutputType? $sum;

  final _i2.PostDetailsMinAggregateOutputType? $min;

  final _i2.PostDetailsMaxAggregateOutputType? $max;

  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    '_count': $count?.toJson(),
    '_avg': $avg?.toJson(),
    '_sum': $sum?.toJson(),
    '_min': $min?.toJson(),
    '_max': $max?.toJson(),
  };
}

class PostDetailsCountOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCountOrderByAggregateInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? likes;

  final _i2.SortOrder? metadata;

  final _i2.SortOrder? postId;

  final _i2.SortOrder? userId;

  final _i2.SortOrder? createdAt;

  final _i2.SortOrder? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsAvgOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsAvgOrderByAggregateInput({
    this.id,
    this.likes,
    this.postId,
    this.userId,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? likes;

  final _i2.SortOrder? postId;

  final _i2.SortOrder? userId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'post_id': postId,
    'user_id': userId,
  };
}

class PostDetailsMaxOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsMaxOrderByAggregateInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? likes;

  final _i2.SortOrder? metadata;

  final _i2.SortOrder? postId;

  final _i2.SortOrder? userId;

  final _i2.SortOrder? createdAt;

  final _i2.SortOrder? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsMinOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsMinOrderByAggregateInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? likes;

  final _i2.SortOrder? metadata;

  final _i2.SortOrder? postId;

  final _i2.SortOrder? userId;

  final _i2.SortOrder? createdAt;

  final _i2.SortOrder? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsSumOrderByAggregateInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsSumOrderByAggregateInput({
    this.id,
    this.likes,
    this.postId,
    this.userId,
  });

  final _i2.SortOrder? id;

  final _i2.SortOrder? likes;

  final _i2.SortOrder? postId;

  final _i2.SortOrder? userId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'post_id': postId,
    'user_id': userId,
  };
}

class PostDetailsOrderByWithAggregationInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsOrderByWithAggregationInput({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.$count,
    this.$avg,
    this.$max,
    this.$min,
    this.$sum,
  });

  final _i2.SortOrder? id;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? likes;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? metadata;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? postId;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? userId;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? createdAt;

  final _i1.PrismaUnion<_i2.SortOrder, _i2.SortOrderInput>? updatedAt;

  final _i2.PostDetailsCountOrderByAggregateInput? $count;

  final _i2.PostDetailsAvgOrderByAggregateInput? $avg;

  final _i2.PostDetailsMaxOrderByAggregateInput? $max;

  final _i2.PostDetailsMinOrderByAggregateInput? $min;

  final _i2.PostDetailsSumOrderByAggregateInput? $sum;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    '_count': $count,
    '_avg': $avg,
    '_max': $max,
    '_min': $min,
    '_sum': $sum,
  };
}

class PostDetailsScalarWhereWithAggregatesInput
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsScalarWhereWithAggregatesInput({
    this.AND,
    this.OR,
    this.NOT,
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final _i1.PrismaUnion<
    _i2.PostDetailsScalarWhereWithAggregatesInput,
    Iterable<_i2.PostDetailsScalarWhereWithAggregatesInput>
  >?
  AND;

  final Iterable<_i2.PostDetailsScalarWhereWithAggregatesInput>? OR;

  final _i1.PrismaUnion<
    _i2.PostDetailsScalarWhereWithAggregatesInput,
    Iterable<_i2.PostDetailsScalarWhereWithAggregatesInput>
  >?
  NOT;

  final _i1.PrismaUnion<_i2.IntWithAggregatesFilter, int>? id;

  final _i1.PrismaUnion<
    _i2.IntNullableWithAggregatesFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  likes;

  final _i1.PrismaUnion<
    _i2.StringNullableWithAggregatesFilter,
    _i1.PrismaUnion<String, _i1.PrismaNull>
  >?
  metadata;

  final _i1.PrismaUnion<
    _i2.IntNullableWithAggregatesFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  postId;

  final _i1.PrismaUnion<
    _i2.IntNullableWithAggregatesFilter,
    _i1.PrismaUnion<int, _i1.PrismaNull>
  >?
  userId;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableWithAggregatesFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  createdAt;

  final _i1.PrismaUnion<
    _i2.DateTimeNullableWithAggregatesFilter,
    _i1.PrismaUnion<DateTime, _i1.PrismaNull>
  >?
  updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'AND': AND,
    'OR': OR,
    'NOT': NOT,
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsCountAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsCountAggregateOutputTypeSelect({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.$all,
  });

  final bool? id;

  final bool? likes;

  final bool? metadata;

  final bool? postId;

  final bool? userId;

  final bool? createdAt;

  final bool? updatedAt;

  final bool? $all;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    '_all': $all,
  };
}

class PostDetailsGroupByOutputTypeCountArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsGroupByOutputTypeCountArgs({this.select});

  final _i2.PostDetailsCountAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostDetailsAvgAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsAvgAggregateOutputTypeSelect({
    this.id,
    this.likes,
    this.postId,
    this.userId,
  });

  final bool? id;

  final bool? likes;

  final bool? postId;

  final bool? userId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'post_id': postId,
    'user_id': userId,
  };
}

class PostDetailsGroupByOutputTypeAvgArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsGroupByOutputTypeAvgArgs({this.select});

  final _i2.PostDetailsAvgAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostDetailsSumAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsSumAggregateOutputTypeSelect({
    this.id,
    this.likes,
    this.postId,
    this.userId,
  });

  final bool? id;

  final bool? likes;

  final bool? postId;

  final bool? userId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'post_id': postId,
    'user_id': userId,
  };
}

class PostDetailsGroupByOutputTypeSumArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsGroupByOutputTypeSumArgs({this.select});

  final _i2.PostDetailsSumAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostDetailsMinAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsMinAggregateOutputTypeSelect({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final bool? id;

  final bool? likes;

  final bool? metadata;

  final bool? postId;

  final bool? userId;

  final bool? createdAt;

  final bool? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsGroupByOutputTypeMinArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsGroupByOutputTypeMinArgs({this.select});

  final _i2.PostDetailsMinAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostDetailsMaxAggregateOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsMaxAggregateOutputTypeSelect({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final bool? id;

  final bool? likes;

  final bool? metadata;

  final bool? postId;

  final bool? userId;

  final bool? createdAt;

  final bool? updatedAt;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PostDetailsGroupByOutputTypeMaxArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsGroupByOutputTypeMaxArgs({this.select});

  final _i2.PostDetailsMaxAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class PostDetailsGroupByOutputTypeSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const PostDetailsGroupByOutputTypeSelect({
    this.id,
    this.likes,
    this.metadata,
    this.postId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final bool? id;

  final bool? likes;

  final bool? metadata;

  final bool? postId;

  final bool? userId;

  final bool? createdAt;

  final bool? updatedAt;

  final _i1.PrismaUnion<bool, _i2.PostDetailsGroupByOutputTypeCountArgs>?
  $count;

  final _i1.PrismaUnion<bool, _i2.PostDetailsGroupByOutputTypeAvgArgs>? $avg;

  final _i1.PrismaUnion<bool, _i2.PostDetailsGroupByOutputTypeSumArgs>? $sum;

  final _i1.PrismaUnion<bool, _i2.PostDetailsGroupByOutputTypeMinArgs>? $min;

  final _i1.PrismaUnion<bool, _i2.PostDetailsGroupByOutputTypeMaxArgs>? $max;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}

class AggregatePostDetails {
  const AggregatePostDetails({
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  factory AggregatePostDetails.fromJson(Map json) => AggregatePostDetails(
    $count: json['_count'] is Map
        ? _i2.PostDetailsCountAggregateOutputType.fromJson(json['_count'])
        : null,
    $avg: json['_avg'] is Map
        ? _i2.PostDetailsAvgAggregateOutputType.fromJson(json['_avg'])
        : null,
    $sum: json['_sum'] is Map
        ? _i2.PostDetailsSumAggregateOutputType.fromJson(json['_sum'])
        : null,
    $min: json['_min'] is Map
        ? _i2.PostDetailsMinAggregateOutputType.fromJson(json['_min'])
        : null,
    $max: json['_max'] is Map
        ? _i2.PostDetailsMaxAggregateOutputType.fromJson(json['_max'])
        : null,
  );

  final _i2.PostDetailsCountAggregateOutputType? $count;

  final _i2.PostDetailsAvgAggregateOutputType? $avg;

  final _i2.PostDetailsSumAggregateOutputType? $sum;

  final _i2.PostDetailsMinAggregateOutputType? $min;

  final _i2.PostDetailsMaxAggregateOutputType? $max;

  Map<String, dynamic> toJson() => {
    '_count': $count?.toJson(),
    '_avg': $avg?.toJson(),
    '_sum': $sum?.toJson(),
    '_min': $min?.toJson(),
    '_max': $max?.toJson(),
  };
}

class AggregatePostDetailsCountArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostDetailsCountArgs({this.select});

  final _i2.PostDetailsCountAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostDetailsAvgArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostDetailsAvgArgs({this.select});

  final _i2.PostDetailsAvgAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostDetailsSumArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostDetailsSumArgs({this.select});

  final _i2.PostDetailsSumAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostDetailsMinArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostDetailsMinArgs({this.select});

  final _i2.PostDetailsMinAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostDetailsMaxArgs
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostDetailsMaxArgs({this.select});

  final _i2.PostDetailsMaxAggregateOutputTypeSelect? select;

  @override
  Map<String, dynamic> toJson() => {'select': select};
}

class AggregatePostDetailsSelect
    implements _i1.JsonConvertible<Map<String, dynamic>> {
  const AggregatePostDetailsSelect({
    this.$count,
    this.$avg,
    this.$sum,
    this.$min,
    this.$max,
  });

  final _i1.PrismaUnion<bool, _i2.AggregatePostDetailsCountArgs>? $count;

  final _i1.PrismaUnion<bool, _i2.AggregatePostDetailsAvgArgs>? $avg;

  final _i1.PrismaUnion<bool, _i2.AggregatePostDetailsSumArgs>? $sum;

  final _i1.PrismaUnion<bool, _i2.AggregatePostDetailsMinArgs>? $min;

  final _i1.PrismaUnion<bool, _i2.AggregatePostDetailsMaxArgs>? $max;

  @override
  Map<String, dynamic> toJson() => {
    '_count': $count,
    '_avg': $avg,
    '_sum': $sum,
    '_min': $min,
    '_max': $max,
  };
}
