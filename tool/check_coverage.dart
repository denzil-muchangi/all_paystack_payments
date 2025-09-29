import 'dart:io';
import 'dart:convert';

/// Script to check test coverage and enforce minimum thresholds
void main() async {
  const minCoverage = 80.0; // Minimum coverage percentage

  try {
    // Run tests with coverage
    print('Running tests with coverage...');
    final testResult = await Process.run('flutter', ['test', '--coverage']);

    if (testResult.exitCode != 0) {
      print('Tests failed!');
      print(testResult.stdout);
      print(testResult.stderr);
      exit(1);
    }

    // Check if coverage file exists
    final coverageFile = File('coverage/lcov.info');
    if (!coverageFile.existsSync()) {
      print('Coverage file not found. Run tests with --coverage flag.');
      exit(1);
    }

    // Parse coverage data
    final coverage = parseLcovCoverage(coverageFile.readAsStringSync());
    final totalCoverage = calculateTotalCoverage(coverage);

    print('Total test coverage: ${totalCoverage.toStringAsFixed(2)}%');
    print('Minimum required coverage: ${minCoverage.toStringAsFixed(2)}%');

    if (totalCoverage < minCoverage) {
      print('❌ Coverage is below minimum threshold!');
      print('Please add more tests to increase coverage.');
      exit(1);
    } else {
      print('✅ Coverage meets minimum requirements!');
    }

    // Print detailed coverage by file
    print('\nCoverage by file:');
    coverage.forEach((file, lines) {
      final covered = lines.where((line) => line > 0).length;
      final total = lines.length;
      final percentage = total > 0 ? (covered / total) * 100 : 0.0;
      print(
        '${file.padRight(50)}: ${percentage.toStringAsFixed(1).padLeft(5)}% ($covered/$total lines)',
      );
    });
  } catch (e) {
    print('Error checking coverage: $e');
    exit(1);
  }
}

Map<String, List<int>> parseLcovCoverage(String lcovContent) {
  final coverage = <String, List<int>>{};
  final lines = lcovContent.split('\n');

  String? currentFile;
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      coverage[currentFile] = [];
    } else if (line.startsWith('DA:') && currentFile != null) {
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        final lineNumber = int.tryParse(parts[0]);
        final hits = int.tryParse(parts[1]) ?? 0;
        if (lineNumber != null && lineNumber > 0) {
          // Expand list to accommodate line number
          while (coverage[currentFile]!.length < lineNumber) {
            coverage[currentFile]!.add(0);
          }
          coverage[currentFile]![lineNumber - 1] = hits;
        }
      }
    }
  }

  return coverage;
}

double calculateTotalCoverage(Map<String, List<int>> coverage) {
  int totalLines = 0;
  int coveredLines = 0;

  for (final lines in coverage.values) {
    for (final hits in lines) {
      totalLines++;
      if (hits > 0) {
        coveredLines++;
      }
    }
  }

  return totalLines > 0 ? (coveredLines / totalLines) * 100 : 0.0;
}
