import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileLogOutput extends LogOutput {
  final Function(int bytesWritten) onLogWritten;

  FileLogOutput(this.onLogWritten);

  @override
  void output(OutputEvent event) {
    if (AppLogger._logFile != null && AppLogger._logFile!.existsSync()) {
      int bytesWritten = 0;
      for (var line in event.lines) {
        final List<int> lineBytes = utf8.encode('$line\n');
        AppLogger._logFile!.writeAsBytesSync(lineBytes, mode: FileMode.append);
        bytesWritten += lineBytes.length;
      }
      onLogWritten(bytesWritten);
    }
  }
}

class AppLogger {
  static Logger? _logger;
  static File? _logFile;
  static Directory? _logDirectory;

  static const int _maxLogFileSizeInBytes = 5 * 1024 * 1024; // 5 MB per file
  static const int _maxLogFiles = 10;

  static Future<void> initialize() async {
    _logger ??= Logger(
      printer: SimplePrinter(
        printTime: true,
        colors: false
      ),
      output: MultiOutput([
        ConsoleOutput(), // For debug
        FileLogOutput(_onLogWritten), // Save file
      ]),
      level: Level.trace,
    );

    _logDirectory = await getApplicationSupportDirectory();

    _logDirectory = Directory('${_logDirectory!.path}/app_logs');
    if (!await _logDirectory!.exists()) {
      await _logDirectory!.create(recursive: true);
    }

    await _rotateLogsIfNecessary(initialization: true);
  }

  static Logger get instance {
    if (_logger == null) {
      throw Exception("Logger not initialized. Call AppLogger.initialize() first.");
    }
    return _logger!;
  }

  static Future<void> _onLogWritten(int bytesWritten) async {
    if (_logFile != null) {
      final currentLength = await _logFile!.length();
      if (currentLength >= _maxLogFileSizeInBytes) {
        await _rotateLogsIfNecessary();
      }
    }
  }

  // Logs rotation
  static Future<void> _rotateLogsIfNecessary({bool initialization = false}) async {
    if (_logDirectory == null) return;

    final List<FileSystemEntity> entities = await _logDirectory!.list().toList();
    List<File> logFiles = entities
        .whereType<File>()
        .where((file) => file.path.endsWith('.txt'))
        .toList();

    // Sort by modification date (from most old to most recent)
    logFiles.sort((a, b) {
      return a.lastModifiedSync().compareTo(b.lastModifiedSync());
    });

    // Delete old files
    while (logFiles.length >= _maxLogFiles) {
      final oldFile = logFiles.removeAt(0); // Delete the most old one
      try {
        await oldFile.delete();
        _logger?.i('Old log file deleted: ${oldFile.path}');
      } catch (e) {
        _logger?.e('Failed to delete old log file: ${oldFile.path}', error: e);
      }
    }

    final String newLogFileName =
        'app_log_${DateTime.now().toIso8601String().replaceAll(':', '-')}.txt';
    _logFile = File('${_logDirectory!.path}/$newLogFileName');

    if (!await _logFile!.exists()) {
      await _logFile!.create(recursive: true);
      if(!initialization) { // Prevent looping
        _logger?.i('New log file created: ${_logFile!.path}');
      }
    }
  }

  static Future<String?> getLogs() async {
    if (_logDirectory == null || !await _logDirectory!.exists()) return null;

    final List<FileSystemEntity> entities = await _logDirectory!.list().toList();
    List<File> logFiles = entities
        .whereType<File>()
        .where((file) => file.path.endsWith('.txt'))
        .toList();

    // Sort files chronologically
    logFiles.sort((a, b) => a.path.compareTo(b.path));

    StringBuffer allLogs = StringBuffer();
    for (var file in logFiles) {
      try {
        allLogs.writeln('--- Log File: ${file.path.split('/').last} ---');
        allLogs.writeln(await file.readAsString(encoding: utf8));
        allLogs.writeln('--- End of ${file.path.split('/').last} ---');
        allLogs.writeln(''); // Separation line
      } catch (e) {
        allLogs.writeln('--- Error reading file: ${file.path} ---');
        allLogs.writeln(e.toString());
        allLogs.writeln(''); // Separation line
      }
    }
    return allLogs.toString();
  }

  // Clear logs files
  static Future<void> clearLogs() async {
    if (_logDirectory == null) return;
    try {
      if (await _logDirectory!.exists()) {
        await _logDirectory!.delete(recursive: true);
      }

      // Recreate directory and create new file
      await AppLogger.initialize();
      _logger?.i('All log files cleared and new log file created.');
    } catch (e) {
      _logger?.e('Failed to clear log files', error: e);
    }
  }
}