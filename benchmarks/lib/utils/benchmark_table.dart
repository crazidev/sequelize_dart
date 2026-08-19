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
      '║                                  ORM BENCHMARK COMPARISON                                   ║',
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

    // ─── Side-by-Side Analysis ───────────────────────────────────────
    _displayWhyAnalysis(reports);
  }

  /// Prints a side-by-side analysis showing where Sequelize loses time
  static void _displayWhyAnalysis(List<PackageBenchmarkReport> reports) {
    if (reports.length < 2) return;

    // Find Sequelize and the fastest non-Sequelize package
    PackageBenchmarkReport? seqReport;
    PackageBenchmarkReport? fastestOther;
    double fastestOtherTotal = double.infinity;

    for (final report in reports) {
      if (report.packageName == 'Sequelize') {
        seqReport = report;
      } else if (report.totalDurationMs < fastestOtherTotal) {
        fastestOtherTotal = report.totalDurationMs;
        fastestOther = report;
      }
    }

    if (seqReport == null || fastestOther == null) return;

    print(
      '╔═══════════════════════════════════════════════════════════════════════════════════════════════╗',
    );
    print(
      '║                          WHY IS SEQUELIZE SLOWER?                                           ║',
    );
    print(
      '╚═══════════════════════════════════════════════════════════════════════════════════════════════╝',
    );
    print('');

    const testCol = 32;
    const valCol = 14;

    // Find all package reports for side-by-side comparison
    final otherReports = reports
        .where((r) => r.packageName != 'Sequelize')
        .toList();

    // Build header
    final topParts = StringBuffer('┌${'─' * (testCol + 2)}');
    final sepParts = StringBuffer('├${'─' * (testCol + 2)}');
    final botParts = StringBuffer('└${'─' * (testCol + 2)}');

    // Columns: Sequelize total, each other ORM, IPC overhead, multiplier
    final colHeaders = <String>[
      'Sequelize',
      ...otherReports.map((r) => r.packageName),
      'IPC Overhead',
      'Slowdown',
    ];

    for (var i = 0; i < colHeaders.length; i++) {
      topParts.write('┬${'─' * (valCol + 2)}');
      sepParts.write('┼${'─' * (valCol + 2)}');
      botParts.write('┴${'─' * (valCol + 2)}');
    }
    topParts.write('┐');
    sepParts.write('┤');
    botParts.write('┘');

    print(topParts.toString());

    // Header
    final hdr = StringBuffer('│ ${'Query'.padRight(testCol)} ');
    for (final col in colHeaders) {
      hdr.write('│ ${col.padLeft(valCol)} ');
    }
    hdr.write('│');
    print(hdr.toString());
    print(sepParts.toString());

    // Data rows
    final testNames = seqReport.results.map((r) => r.testName).toList();
    for (var i = 0; i < testNames.length; i++) {
      final row = StringBuffer('│ ${testNames[i].padRight(testCol)} ');
      final seqResult = seqReport.results[i];

      // Sequelize total
      row.write(
        '│ ${'${seqResult.durationMs.toStringAsFixed(2)}ms'.padLeft(valCol)} ',
      );

      // Other ORMs
      double bestOtherMs = double.infinity;
      for (final other in otherReports) {
        final otherResult = other.results[i];
        row.write(
          '│ ${'${otherResult.durationMs.toStringAsFixed(2)}ms'.padLeft(valCol)} ',
        );
        if (otherResult.durationMs < bestOtherMs) {
          bestOtherMs = otherResult.durationMs;
        }
      }

      // IPC overhead (from step breakdown)
      final ipc = seqResult.stepBreakdownMs?['ipc_overhead'];
      final ipcStr = ipc != null ? '${ipc.toStringAsFixed(2)}ms' : '—';
      row.write('│ ${ipcStr.padLeft(valCol)} ');

      // Slowdown multiplier
      final multiplier = bestOtherMs > 0
          ? seqResult.durationMs / bestOtherMs
          : 0.0;
      final multStr = '${multiplier.toStringAsFixed(1)}x';
      row.write('│ ${multStr.padLeft(valCol)} ');

      row.write('│');
      print(row.toString());
    }

    print(sepParts.toString());

    // Summary row
    final summaryRow = StringBuffer('│ ${'TOTAL'.padRight(testCol)} ');

    summaryRow.write(
      '│ ${'${seqReport.totalDurationMs.toStringAsFixed(2)}ms'.padLeft(valCol)} ',
    );

    double bestOtherTotal = double.infinity;
    for (final other in otherReports) {
      summaryRow.write(
        '│ ${'${other.totalDurationMs.toStringAsFixed(2)}ms'.padLeft(valCol)} ',
      );
      if (other.totalDurationMs < bestOtherTotal) {
        bestOtherTotal = other.totalDurationMs;
      }
    }

    // Total IPC overhead
    double totalIpc = 0;
    int ipcCount = 0;
    for (final r in seqReport.results) {
      final ipc = r.stepBreakdownMs?['ipc_overhead'];
      if (ipc != null) {
        totalIpc += ipc;
        ipcCount++;
      }
    }
    summaryRow.write(
      '│ ${ipcCount > 0 ? '${totalIpc.toStringAsFixed(2)}ms' : '—'.padLeft(valCol)} ',
    );

    final totalMult = bestOtherTotal > 0
        ? seqReport.totalDurationMs / bestOtherTotal
        : 0.0;
    summaryRow.write(
      '│ ${'${totalMult.toStringAsFixed(1)}x'.padLeft(valCol)} ',
    );
    summaryRow.write('│');
    print(summaryRow.toString());

    print(botParts.toString());
    print('');
  }
}
