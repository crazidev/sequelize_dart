import 'package:orm_benchmarks/utils/benchmark_runner.dart';

/// Formats and displays an aligned comparative benchmark table in the terminal
class BenchmarkTable {
  /// Prints the comparative summary table given reports from multiple packages
  static void displayComparison(List<PackageBenchmarkReport> reports) {
    if (reports.isEmpty) return;

    // Arrange them by longest title descending for the detailed results
    final sortedByTitleReports = List<PackageBenchmarkReport>.from(reports)
      ..sort((a, b) => b.packageName.length.compareTo(a.packageName.length));

    print('\n');
    print(
      '╔═══════════════════════════════════════════════════════════════════════════════════════════════╗',
    );
    print(
      '║                                  ORM BENCHMARK RESULTS                                      ║',
    );
    print(
      '╚═══════════════════════════════════════════════════════════════════════════════════════════════╝',
    );
    print('');

    final testNames = sortedByTitleReports.first.results
        .map((r) => r.testName)
        .toList();
    const testColWidth = 32;

    int getColWidth(String packageName) {
      final name = packageName.toLowerCase();
      if (name.contains('sequelize')) {
        return 16;
      } else if (name == 'drift' || name == 'prisma') {
        return 9;
      }
      return 12;
    }

    // Header row
    final headerBuffer = StringBuffer();
    headerBuffer.write('│ ${'Query / Test Name'.padRight(testColWidth)} ');
    for (final report in sortedByTitleReports) {
      final width = getColWidth(report.packageName);
      headerBuffer.write('│ ${report.packageName.padRight(width)} ');
    }
    headerBuffer.write('│ Fastest'.padRight(12));
    headerBuffer.write('│');

    final separator =
        '├${'─' * (testColWidth + 2)}${sortedByTitleReports.map((r) => '┼${'─' * (getColWidth(r.packageName) + 2)}').join()}┼${'─' * 11}┤';

    final topBorder =
        '┌${'─' * (testColWidth + 2)}${sortedByTitleReports.map((r) => '┬${'─' * (getColWidth(r.packageName) + 2)}').join()}┬${'─' * 11}┐';

    final bottomBorder =
        '└${'─' * (testColWidth + 2)}${sortedByTitleReports.map((r) => '┴${'─' * (getColWidth(r.packageName) + 2)}').join()}┴${'─' * 11}┘';

    print(topBorder);
    print(headerBuffer.toString());
    print(separator);

    // Each test row
    for (var i = 0; i < testNames.length; i++) {
      final testName = testNames[i];
      final rowBuffer = StringBuffer();
      rowBuffer.write('│ ${testName.padRight(testColWidth)} ');

      double minDuration = double.infinity;
      String fastestPackage = '';

      for (final report in sortedByTitleReports) {
        final result = report.results[i];
        final val = '${result.durationMs.toStringAsFixed(2)}ms';
        final width = getColWidth(report.packageName);
        rowBuffer.write('│ ${val.padLeft(width)} ');

        if (result.durationMs < minDuration) {
          minDuration = result.durationMs;
          fastestPackage = report.packageName;
        }
      }

      rowBuffer.write('│ ${fastestPackage.padRight(10)}│');
      print(rowBuffer.toString());
    }

    print(bottomBorder);
    print('');

    // Sort reports by total duration ascending for the ranking table
    final sortedReports = List<PackageBenchmarkReport>.from(reports)
      ..sort((a, b) => a.totalDurationMs.compareTo(b.totalDurationMs));

    print(
      '╔══════════════════════════════════════════════════════════════════════════════════╗',
    );
    print(
      '║                              ORM BENCHMARK RANKING                               ║',
    );
    print(
      '╚══════════════════════════════════════════════════════════════════════════════════╝',
    );
    print('');

    const rankCol = 6;
    const pkgCol = 22;
    const totalCol = 14;
    const avgCol = 14;
    const slowdownCol = 12;

    final rankHeaderBuffer = StringBuffer();
    rankHeaderBuffer.write('│ ${'Rank'.padRight(rankCol)} ');
    rankHeaderBuffer.write('│ ${'Package'.padRight(pkgCol)} ');
    rankHeaderBuffer.write('│ ${'Total Time'.padLeft(totalCol)} ');
    rankHeaderBuffer.write('│ ${'Avg Time'.padLeft(avgCol)} ');
    rankHeaderBuffer.write('│ ${'Slowdown'.padLeft(slowdownCol)} │');

    final rankSeparator =
        '├${'─' * (rankCol + 2)}┼${'─' * (pkgCol + 2)}┼${'─' * (totalCol + 2)}┼${'─' * (avgCol + 2)}┼${'─' * (slowdownCol + 2)}┤';
    final rankTopBorder =
        '┌${'─' * (rankCol + 2)}┬${'─' * (pkgCol + 2)}┬${'─' * (totalCol + 2)}┬${'─' * (avgCol + 2)}┬${'─' * (slowdownCol + 2)}┐';
    final rankBottomBorder =
        '└${'─' * (rankCol + 2)}┴${'─' * (pkgCol + 2)}┴${'─' * (totalCol + 2)}┴${'─' * (avgCol + 2)}┴${'─' * (slowdownCol + 2)}┘';

    print(rankTopBorder);
    print(rankHeaderBuffer.toString());
    print(rankSeparator);

    final fastestTotal = sortedReports.first.totalDurationMs;

    for (var i = 0; i < sortedReports.length; i++) {
      final report = sortedReports[i];
      final rowBuffer = StringBuffer();

      final rankStr = '#${i + 1}';
      final totalStr = '${report.totalDurationMs.toStringAsFixed(2)}ms';
      final avgStr = '${report.averageDurationMs.toStringAsFixed(2)}ms';

      final multiplier = fastestTotal > 0
          ? report.totalDurationMs / fastestTotal
          : 0.0;
      final slowdownStr = i == 0 ? '-' : '${multiplier.toStringAsFixed(2)}x';

      rowBuffer.write('│ ${rankStr.padRight(rankCol)} ');
      rowBuffer.write('│ ${report.packageName.padRight(pkgCol)} ');
      rowBuffer.write('│ ${totalStr.padLeft(totalCol)} ');
      rowBuffer.write('│ ${avgStr.padLeft(avgCol)} ');
      rowBuffer.write('│ ${slowdownStr.padLeft(slowdownCol)} │');

      print(rowBuffer.toString());
    }

    print(rankBottomBorder);
    print('');
  }

  /// Prints detailed step profiler breakdown for packages with step-level profiling
  static void displayStepBreakdown(List<PackageBenchmarkReport> reports) {
    for (final report in reports) {
      final profiledResults = report.results
          .where(
            (r) => r.stepBreakdownMs != null && r.stepBreakdownMs!.isNotEmpty,
          )
          .toList();

      if (profiledResults.isEmpty) continue;

      print(
        '╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════╗',
      );
      print(
        '║                        STEP-BY-STEP LATENCY BREAKDOWN: ${report.packageName.padRight(46)}║',
      );
      print(
        '╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════╝',
      );

      // Collect all distinct step names across queries
      final allStepKeys = <String>{};
      for (final r in profiledResults) {
        allStepKeys.addAll(r.stepBreakdownMs!.keys);
      }
      final stepList = allStepKeys.toList();

      const testColWidth = 28;
      const totalColWidth = 10;
      const stepColWidth = 12;

      final headerBuffer = StringBuffer();
      headerBuffer.write('│ ${'Query / Test Name'.padRight(testColWidth)} ');
      headerBuffer.write('│ ${'Total'.padLeft(totalColWidth)} ');
      for (final step in stepList) {
        headerBuffer.write('│ ${step.padLeft(stepColWidth)} ');
      }
      headerBuffer.write('│');

      final topBorder =
          '┌${'─' * (testColWidth + 2)}┬${'─' * (totalColWidth + 2)}${stepList.map((_) => '┬${'─' * (stepColWidth + 2)}').join()}┐';
      final separator =
          '├${'─' * (testColWidth + 2)}┼${'─' * (totalColWidth + 2)}${stepList.map((_) => '┼${'─' * (stepColWidth + 2)}').join()}┤';
      final bottomBorder =
          '└${'─' * (testColWidth + 2)}┴${'─' * (totalColWidth + 2)}${stepList.map((_) => '┴${'─' * (stepColWidth + 2)}').join()}┘';

      print(topBorder);
      print(headerBuffer.toString());
      print(separator);

      for (final result in profiledResults) {
        final rowBuffer = StringBuffer();
        rowBuffer.write('│ ${result.testName.padRight(testColWidth)} ');
        rowBuffer.write(
          '│ ${(result.durationMs.toStringAsFixed(2) + 'ms').padLeft(totalColWidth)} ',
        );

        final breakdown = result.stepBreakdownMs!;
        for (final step in stepList) {
          final val = breakdown[step];
          final valStr = val != null ? '${val.toStringAsFixed(2)}ms' : '-';
          rowBuffer.write('│ ${valStr.padLeft(stepColWidth)} ');
        }
        rowBuffer.write('│');
        print(rowBuffer.toString());
      }

      print(bottomBorder);
      print('');
    }
  }
}
