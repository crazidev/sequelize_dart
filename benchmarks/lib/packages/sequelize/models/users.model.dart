import 'package:sequelize_orm/sequelize_orm.dart';
import 'post.model.dart';

part 'users.model.g.dart';

@Table(
  underscored: true,
  deletedAt: TimestampOption.custom('deleted_at'),
)
abstract class Users {
  @PrimaryKey()
  @AutoIncrement()
  @NotNull()
  DataType id = DataType.INTEGER;

  @Validate.IsEmail('Email is not valid')
  @NotNull()
  DataType email = DataType.STRING;

  @ColumnName('first_name')
  @Validate.Min(4)
  @NotNull()
  DataType firstName = DataType.STRING;

  @ColumnName('last_name')
  DataType lastName = DataType.STRING;

  @ColumnName('phone_number')
  DataType phoneNumber = DataType.BIGINT;

  @ColumnName('deleted_at')
  DataType deletedAt = DataType.DATE;

  @EnumPrefix('is', 'not')
  DataType status = DataType.ENUM(['active', 'inactive', 'pending']);

  // JSON columns with custom Dart types
  DataType tags = DataType.JSON(type: List<String>);
  DataType scores = DataType.JSON(type: List<int>);
  DataType metadata = DataType.JSON;

  @HasOne(Post, foreignKey: 'userId', as: 'post')
  Post? post;

  @HasMany(Post, foreignKey: 'userId', as: 'posts')
  List<Post>? posts;

  static UsersModel get model => UsersModel();
}

class Address {
  final String city;
  final String country;

  Address({required this.city, required this.country});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: json['city'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
    };
  }
}

class Metadata {
  final String role;
  final bool isAdmin;
  final String level;
  final Address address;
  final int age;

  Metadata({
    required this.role,
    required this.isAdmin,
    required this.level,
    required this.address,
    required this.age,
  });
}
