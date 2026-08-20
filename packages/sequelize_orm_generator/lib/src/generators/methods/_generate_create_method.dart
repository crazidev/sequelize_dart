part of '../../sequelize_model_generator.dart';

void _generateCreateMethod(
  StringBuffer buffer,
  String className,
  String valuesClassName,
  String whereCallbackName,
  String includeCallbackName,
  List<_FieldInfo> fields,
  List<_AssociationInfo> associations,
  GeneratorNamingConfig namingConfig,
) {
  final createClassName = namingConfig.getModelCreateClassName(className);

  // Generate create method that accepts Create class with associations
  buffer.writeln(
    '  Future<$valuesClassName> create($createClassName createData, {Transaction? transaction}) {',
  );
  buffer.writeln(
    '    // Convert Create class to JSON (includes nested associations)',
  );
  buffer.writeln('    final data = createData.toJson();');
  buffer.writeln();
  buffer.writeln('    // Build include list for associations');
  buffer.writeln('    final includeList = <IncludeBuilder>[];');

  for (final assoc in associations) {
    final assocName = assoc.as ?? assoc.fieldName;
    final modelClassName = assoc.modelClassName;
    buffer.writeln('    if (createData.${assoc.fieldName} != null) {');
    buffer.writeln('      includeList.add(');
    buffer.writeln('        IncludeBuilder(');
    buffer.writeln('          association: \'$assocName\',');
    buffer.writeln('          model: $modelClassName.model,');
    buffer.writeln(
      '          // Allow nested create (e.g. create PostDetails with Post, and Post with User)',
    );
    buffer.writeln(
      '          // This tells Sequelize to accept nested association objects inside the payload.',
    );
    buffer.writeln(
      '          include: [IncludeBuilder(all: true, nested: true)],',
    );
    buffer.writeln('        ),');
    buffer.writeln('      );');
    buffer.writeln('    }');
  }

  buffer.writeln();
  buffer.writeln(
    '    // Build query with include option if associations exist',
  );
  buffer.writeln('    final query = Query(');
  buffer.writeln('      include: includeList.isNotEmpty ? includeList : null,');
  buffer.writeln('    );');
  buffer.writeln();

  buffer.writeln('    return QueryEngine().create(');
  buffer.writeln('      modelName: modelName,');
  buffer.writeln('      data: data,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('      transaction: transaction,');
  buffer.writeln('    ).then((result) {');
  buffer.writeln(
    '      final instance = $valuesClassName.fromJson(result.data, operation: \'create\');',
  );
  buffer.writeln('      instance.originalQuery = query;');
  buffer.writeln('      instance.setPreviousDataValues(result.data);');
  buffer.writeln('      return instance;');
  buffer.writeln('    });');
  buffer.writeln('  }');
  buffer.writeln();

  // Generate bulkCreate method that accepts List of Create class with associations
  buffer.writeln(
    '  Future<List<$valuesClassName>> bulkCreate(',
  );
  buffer.writeln(
    '    List<$createClassName> records, {',
  );
  buffer.writeln('    Transaction? transaction,');
  buffer.writeln('    bool? validate,');
  buffer.writeln('    bool? individualHooks,');
  buffer.writeln('    bool? ignoreDuplicates,');
  buffer.writeln('    List<String>? updateOnDuplicate,');
  buffer.writeln('    List<String>? fields,');
  buffer.writeln('    bool? returning,');
  buffer.writeln('  }) {');
  buffer.writeln('    if (records.isEmpty) {');
  buffer.writeln('      return Future.value([]);');
  buffer.writeln('    }');
  buffer.writeln('    final data = records.map((e) => e.toJson()).toList();');
  buffer.writeln();
  buffer.writeln('    // Build include list for associations');
  buffer.writeln('    final includeList = <IncludeBuilder>[];');

  for (final assoc in associations) {
    final assocName = assoc.as ?? assoc.fieldName;
    final modelClassName = assoc.modelClassName;
    buffer.writeln(
      '    if (records.any((r) => r.${assoc.fieldName} != null)) {',
    );
    buffer.writeln('      includeList.add(');
    buffer.writeln('        IncludeBuilder(');
    buffer.writeln('          association: \'$assocName\',');
    buffer.writeln('          model: $modelClassName.model,');
    buffer.writeln(
      '          // Allow nested create (e.g. create PostDetails with Post, and Post with User)',
    );
    buffer.writeln(
      '          // This tells Sequelize to accept nested association objects inside the payload.',
    );
    buffer.writeln(
      '          include: [IncludeBuilder(all: true, nested: true)],',
    );
    buffer.writeln('        ),');
    buffer.writeln('      );');
    buffer.writeln('    }');
  }

  buffer.writeln();
  buffer.writeln(
    '    // Build query with include option if associations exist',
  );
  buffer.writeln('    final query = Query(');
  buffer.writeln('      include: includeList.isNotEmpty ? includeList : null,');
  buffer.writeln('    );');
  buffer.writeln();
  buffer.writeln('    final options = <String, dynamic>{');
  buffer.writeln('      if (validate != null) \'validate\': validate,');
  buffer.writeln(
    '      if (individualHooks != null) \'individualHooks\': individualHooks,',
  );
  buffer.writeln(
    '      if (ignoreDuplicates != null) \'ignoreDuplicates\': ignoreDuplicates,',
  );
  buffer.writeln(
    '      if (updateOnDuplicate != null) \'updateOnDuplicate\': updateOnDuplicate,',
  );
  buffer.writeln('      if (fields != null) \'fields\': fields,');
  buffer.writeln('      if (returning != null) \'returning\': returning,');
  buffer.writeln('    };');
  buffer.writeln();
  buffer.writeln('    return QueryEngine().bulkCreate(');
  buffer.writeln('      modelName: modelName,');
  buffer.writeln('      data: data,');
  buffer.writeln('      query: query,');
  buffer.writeln('      options: options.isNotEmpty ? options : null,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('      transaction: transaction,');
  buffer.writeln('    ).then((results) {');
  buffer.writeln('      return results.asMap().entries.map((entry) {');
  buffer.writeln('        final rowIndex = entry.key;');
  buffer.writeln('        final result = entry.value;');
  buffer.writeln('        final instance = $valuesClassName.fromJson(');
  buffer.writeln('          result.data,');
  buffer.writeln('          operation: \'bulkCreate\',');
  buffer.writeln('          rowIndex: rowIndex,');
  buffer.writeln('        );');
  buffer.writeln('        instance.originalQuery = query;');
  buffer.writeln('        instance.setPreviousDataValues(result.data);');
  buffer.writeln('        return instance;');
  buffer.writeln('      }).toList();');
  buffer.writeln('    });');
  buffer.writeln('  }');
  buffer.writeln();
}
