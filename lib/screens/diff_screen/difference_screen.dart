import 'package:files_manager/theme/color.dart';
import 'package:flutter/material.dart';

class DiffViewer extends StatefulWidget {
  @override
  _DiffViewerState createState() => _DiffViewerState();
}

class _DiffViewerState extends State<DiffViewer> {
  List<Map<String, dynamic>> _lineDiffs = [];

  @override
  void initState() {
    super.initState();
    const diff = "--- Original\n+++ New\n@@ @@\n \r\n /////i am still a rockstar..\r\n \r\n-abodododdododod\r\n+hwuhe\r\n \r\n-hwuhe\r\n+new line herre\r\n+dfsdsf some edit here\r\n \r\n-dfsdsf\n+some otehr +sf+asd+fas\t\n";
    generateLineDiffs(diff);
  }

  void generateLineDiffs(String diffString) {
    final lines = diffString.split('\n');
    final processedDiffs = <Map<String, dynamic>>[];
    int originalLine = 1;
    int newLine = 1;

    for (var line in lines) {
      if (line.startsWith('---') || line.startsWith('+++') || line.startsWith('@@')) continue;

      if (line.startsWith('-')) {
        processedDiffs.add({
          'type': 'removed',
          'original': line.substring(1).trim(),
          'new': '',
          'originalLine': originalLine++,
          'newLine': null,
        });
      } else if (line.startsWith('+')) {
        processedDiffs.add({
          'type': 'added',
          'original': '',
          'new': line.substring(1).trim(),
          'originalLine': null,
          'newLine': newLine++,
        });
      } else {
        processedDiffs.add({
          'type': 'unchanged',
          'original': line.trim(),
          'new': line.trim(),
          'originalLine': originalLine++,
          'newLine': newLine++,
        });
      }
    }

    setState(() {
      _lineDiffs = processedDiffs.where((diff) => diff['originalLine'] != null || diff['newLine'] != null).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diff Viewer', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.dark,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildDiffColumns(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black12,
      child: Row(
        children: [
          // Original Header
          Expanded(
            child: _buildLineNumberHeader('Original', Colors.red),
          ),
          // Vertical Divider
          Container(
            width: 3,
            color: Colors.white,
          ),
          // New Header
          Expanded(
            child: _buildLineNumberHeader('New', Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildLineNumberHeader(String text, Color color) {
    return Container(
      color: Colors.black12,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDiffColumns() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey, width: 1),
          right: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOriginalColumn(),
          Container(
            width: 1,
            color: Colors.grey,
          ),
          _buildNewColumn(),
        ],
      ),
    );
  }

  Widget _buildOriginalColumn() {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _lineDiffs.length,
        itemBuilder: (context, index) {
          final diff = _lineDiffs[index];
          return _buildLineItem(
            lineNumber: diff['originalLine'],
            content: diff['original'],
            backgroundColor: diff['type'] == 'removed' ? Colors.red.withOpacity(0.1) : null,
            textColor: diff['type'] == 'removed' ? Colors.red : Colors.white,
            prefix: diff['type'] == 'removed' ? '-' : null,
          );
        },
      ),
    );
  }

  Widget _buildNewColumn() {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _lineDiffs.length,
        itemBuilder: (context, index) {
          final diff = _lineDiffs[index];
          return _buildLineItem(
            lineNumber: diff['newLine'],
            content: diff['new'],
            backgroundColor: diff['type'] == 'added' ? Colors.green.withOpacity(0.1) : null,
            textColor: diff['type'] == 'added' ? Colors.green : Colors.white,
            prefix: diff['type'] == 'added' ? '+' : null,
          );
        },
      ),
    );
  }

  Widget _buildLineItem({
    required dynamic lineNumber,
    required String content,
    Color? backgroundColor,
    Color textColor = Colors.white,
    String? prefix,
  }) {
    return Container(
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (prefix != null) Text(prefix, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Text(
                  lineNumber?.toString() ?? '',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: SelectableText(
                content,
                style: TextStyle(
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}