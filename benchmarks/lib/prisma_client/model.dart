// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'model.dart' as _i1;
import 'prisma.dart' as _i2;

class PostDetails {
  const PostDetails({
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

  factory PostDetails.fromJson(Map json) => PostDetails(
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
    post: json['post'] is Map ? _i1.Posts.fromJson(json['post']) : null,
    user: json['user'] is Map ? _i1.Users.fromJson(json['user']) : null,
  );

  final int? id;

  final int? likes;

  final String? metadata;

  final int? postId;

  final int? userId;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final _i1.Posts? post;

  final _i1.Users? user;

  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'post': post?.toJson(),
    'user': user?.toJson(),
  };
}

class Posts {
  const Posts({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.user,
    this.postDetails,
  });

  factory Posts.fromJson(Map json) => Posts(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    userId: json['user_id'],
    views: json['views'],
    user: json['user'] is Map ? _i1.Users.fromJson(json['user']) : null,
    postDetails: json['post_details'] is Map
        ? _i1.PostDetails.fromJson(json['post_details'])
        : null,
  );

  final int? id;

  final String? title;

  final String? content;

  final int? userId;

  final int? views;

  final _i1.Users? user;

  final _i1.PostDetails? postDetails;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    'user': user?.toJson(),
    'post_details': postDetails?.toJson(),
  };
}

class Users {
  const Users({
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

  factory Users.fromJson(Map json) => Users(
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
    posts: (json['posts'] as Iterable?)?.map(
      (json) => _i1.Posts.fromJson(json),
    ),
    postDetails: (json['post_details'] as Iterable?)?.map(
      (json) => _i1.PostDetails.fromJson(json),
    ),
    $count: json['_count'] is Map
        ? _i2.UsersCountOutputType.fromJson(json['_count'])
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

  final Iterable<_i1.Posts>? posts;

  final Iterable<_i1.PostDetails>? postDetails;

  final _i2.UsersCountOutputType? $count;

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
    'posts': posts?.map((e) => e.toJson()),
    'post_details': postDetails?.map((e) => e.toJson()),
    '_count': $count?.toJson(),
  };
}

class CreateManyUsersAndReturnOutputType {
  const CreateManyUsersAndReturnOutputType({
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

  factory CreateManyUsersAndReturnOutputType.fromJson(Map json) =>
      CreateManyUsersAndReturnOutputType(
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

class CreateManyPostsAndReturnOutputType {
  const CreateManyPostsAndReturnOutputType({
    this.id,
    this.title,
    this.content,
    this.userId,
    this.views,
    this.user,
  });

  factory CreateManyPostsAndReturnOutputType.fromJson(Map json) =>
      CreateManyPostsAndReturnOutputType(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        userId: json['user_id'],
        views: json['views'],
        user: json['user'] is Map ? _i1.Users.fromJson(json['user']) : null,
      );

  final int? id;

  final String? title;

  final String? content;

  final int? userId;

  final int? views;

  final _i1.Users? user;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'user_id': userId,
    'views': views,
    'user': user?.toJson(),
  };
}

class CreateManyPostDetailsAndReturnOutputType {
  const CreateManyPostDetailsAndReturnOutputType({
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

  factory CreateManyPostDetailsAndReturnOutputType.fromJson(Map json) =>
      CreateManyPostDetailsAndReturnOutputType(
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
        post: json['post'] is Map ? _i1.Posts.fromJson(json['post']) : null,
        user: json['user'] is Map ? _i1.Users.fromJson(json['user']) : null,
      );

  final int? id;

  final int? likes;

  final String? metadata;

  final int? postId;

  final int? userId;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final _i1.Posts? post;

  final _i1.Users? user;

  Map<String, dynamic> toJson() => {
    'id': id,
    'likes': likes,
    'metadata': metadata,
    'post_id': postId,
    'user_id': userId,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'post': post?.toJson(),
    'user': user?.toJson(),
  };
}
