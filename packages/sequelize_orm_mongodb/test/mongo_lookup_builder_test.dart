import 'package:sequelize_orm_mongodb/sequelize_orm_mongodb.dart';
import 'package:test/test.dart';

void main() {
  group('MongoLookupBuilder', () {
    final associations = <String, MongoAssociationDefinition>{
      'users.posts': const MongoAssociationDefinition(
        sourceModel: 'users',
        associationName: 'posts',
        targetCollection: 'posts',
        associationType: MongoAssociationType.hasMany,
        localField: '_id',
        foreignField: 'userId',
      ),
      'posts.comments': const MongoAssociationDefinition(
        sourceModel: 'posts',
        associationName: 'comments',
        targetCollection: 'comments',
        associationType: MongoAssociationType.hasMany,
        localField: '_id',
        foreignField: 'postId',
      ),
    };

    MongoAssociationDefinition? resolver({
      required String sourceModel,
      required String associationName,
    }) {
      return associations['$sourceModel.$associationName'];
    }

    final builder = MongoLookupBuilder(associationResolver: resolver);

    test('builds lookup stages including nested includes and required', () {
      final stages = builder.buildLookupStages(
        sourceModel: 'users',
        includes: [
          {
            'association': 'posts',
            'required': true,
            'where': {
              'published': {r'$eq': true},
            },
            'include': [
              {
                'association': 'comments',
                'limit': 5,
              },
            ],
          },
        ],
      );

      expect(stages, [
        {
          r'$lookup': {
            'from': 'posts',
            'localField': '_id',
            'foreignField': 'userId',
            'as': 'posts',
            'pipeline': [
              {
                r'$match': {
                  'published': {r'$eq': true},
                },
              },
              {
                r'$lookup': {
                  'from': 'comments',
                  'localField': '_id',
                  'foreignField': 'postId',
                  'as': 'comments',
                  'pipeline': [
                    {r'$limit': 5},
                  ],
                },
              },
            ],
          },
        },
        {
          r'$match': {
            'posts.0': {r'$exists': true},
          },
        },
      ]);
    });

    test('throws when include association cannot be resolved', () {
      expect(
        () => builder.buildLookupStages(
          sourceModel: 'users',
          includes: [
            {
              'association': 'unknownRelation',
            },
          ],
        ),
        throwsA(isA<MongoAssociationResolutionException>()),
      );
    });
  });
}
