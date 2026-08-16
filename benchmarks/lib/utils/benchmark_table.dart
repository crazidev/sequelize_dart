import 'package:orm_benchmarks/utils/benchmark_runner.dart';

/// Formats and displays an aligned comparative benchmark table in the terminal
class BenchmarkTable {
  /// Prints the comparative summary table given reports from multiple packages
  static void displayComparison(List<PackageBenchmarkReport> reports) {
    if (reports.isEmpty) return;

    print('\n');
    print(
      '╔═══════════════════════════════════════════════════════════════════════════════════════════════╗',
    );
    print(
      '║                                  ORM BENCHMARK COMPARISON                                     ║',
    );
    print(
      '╚═══════════════════════════════════════════════════════════════════════════════════════════════╝',
    );
    print('');

    final testNames = reports.first.results.map((r) => r.testName).toList();
    const testColWidth = 32;
    const dataColWidth = 18;

    // Header row
    final headerBuffer = StringBuffer();
    headerBuffer.write('│ ${'Query / Test Name'.padRight(testColWidth)} ');
    for (final report in reports) {
      headerBuffer.write('│ ${report.packageName.padRight(dataColWidth)} ');
    }
    headerBuffer.write('│ Fastest'.padRight(12));
    headerBuffer.write('│');

    final separator =
        '├${'─' * (testColWidth + 2)}${reports.map((_) => '┼${'─' * (dataColWidth + 2)}').join()}┼${'─' * 11}┤';

    final topBorder =
        '┌${'─' * (testColWidth + 2)}${reports.map((_) => '┬${'─' * (dataColWidth + 2)}').join()}┬${'─' * 11}┐';

    final bottomBorder =
        '└${'─' * (testColWidth + 2)}${reports.map((_) => '┴${'─' * (dataColWidth + 2)}').join()}┴${'─' * 11}┘';

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

      for (final report in reports) {
        final result = report.results[i];
        final val = '${result.durationMs.toStringAsFixed(2)}ms';
        rowBuffer.write('│ ${val.padLeft(dataColWidth)} ');

        if (result.durationMs < minDuration) {
          minDuration = result.durationMs;
          fastestPackage = report.packageName;
        }
      }

      rowBuffer.write('│ ${fastestPackage.padRight(10)}│');
      print(rowBuffer.toString());
    }

    print(separator);

    // Total row
    final totalRowBuffer = StringBuffer();
    totalRowBuffer.write('│ ${'TOTAL TIME'.padRight(testColWidth)} ');
    double minTotal = double.infinity;
    String fastestTotal = '';
    for (final report in reports) {
      final totalStr = '${report.totalDurationMs.toStringAsFixed(2)}ms';
      totalRowBuffer.write('│ ${totalStr.padLeft(dataColWidth)} ');
      if (report.totalDurationMs < minTotal) {
        minTotal = report.totalDurationMs;
        fastestTotal = report.packageName;
      }
    }
    totalRowBuffer.write('│ ${fastestTotal.padRight(10)}│');
    print(totalRowBuffer.toString());

    // Average per query row
    final avgRowBuffer = StringBuffer();
    avgRowBuffer.write('│ ${'AVERAGE / QUERY'.padRight(testColWidth)} ');
    double minAvg = double.infinity;
    String fastestAvg = '';
    for (final report in reports) {
      final avgStr = '${report.averageDurationMs.toStringAsFixed(2)}ms';
      avgRowBuffer.write('│ ${avgStr.padLeft(dataColWidth)} ');
      if (report.averageDurationMs < minAvg) {
        minAvg = report.averageDurationMs;
        fastestAvg = report.packageName;
      }
    }
    avgRowBuffer.write('│ ${fastestAvg.padRight(10)}│');
    print(avgRowBuffer.toString());

    print(bottomBorder);
    print('');
  }
}
