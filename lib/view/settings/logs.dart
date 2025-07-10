import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //
import 'package:share_plus/share_plus.dart';
import 'package:weather_app/common/app_logger.dart';
import 'package:weather_app/l10n/app_localizations.dart';

import '../../common/utils.dart';

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  String _logsContent = '';
  bool _isLoading = true;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });
    final logs = await AppLogger.getLogs();
    setState(() {
      _logsContent = logs ?? AppLocalizations.of(context)!.logsNotFound;
      _isLoading = false;
    });
  }

  Future<void> _copyLogs() async {
    await Clipboard.setData(ClipboardData(text: _logsContent));

    AppLogger.instance.i("Logs copied successfully");
    // Prevent snackbar to be shown if widget not mounted (on page change for example)
    if(!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.logsCopied)),
    );
  }

  Future<void> _shareLogs() async {
    if (_logsContent.isNotEmpty) {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: _logsContent,
          title: AppLocalizations.of(context)!.appLogs
        )
      );

      if(result.status == ShareResultStatus.success) {
        AppLogger.instance.i("Logs shared successfully");
      }
      else {
        AppLogger.instance.i("Logs cannot be shared, maybe by user cancel action or an unknown action");
      }

    } else {
      AppLogger.instance.i("Logs unavailable for sharing");

      // Prevent snackbar to be shown if widget not mounted (on page change for example)
      if(!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.logsUnavailable)),
      );
    }
  }

  Future<void> _clearLogs() async {
    await AppLogger.clearLogs();

    await _loadLogs(); // Reload logs

    if(!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.logsCleared)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appLogs),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _isLoading ? null : _copyLogs,
            tooltip: AppLocalizations.of(context)!.copyLogs,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isLoading ? null : _shareLogs,
            tooltip: AppLocalizations.of(context)!.shareLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _isLoading ? null : _clearLogs,
            tooltip: AppLocalizations.of(context)!.clearLogs,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadLogs,
            tooltip: AppLocalizations.of(context)!.refreshLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
            thumbVisibility: kIsWeb || Utils.checkIfDesktop(),
            controller: controller,
            child: Container(
              width: double.infinity,
              child: SingleChildScrollView(
                      controller: controller,
                      child: SelectableText(
              _logsContent,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12
              ),
                      ),
                    ),
            ),
          ),
    );
  }
}