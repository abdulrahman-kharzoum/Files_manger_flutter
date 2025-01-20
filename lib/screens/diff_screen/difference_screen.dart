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
    const diff = "--- Original\n+++ New\n@@ @@\n-hello this is a new file\n-so so what\n+hello this is a new folder\n+so what\n\ni am still a rockstar..\n-idon't need you\n+ad\n+dd";

    // Parse the diff string into line-based differences
    generateLineDiffs(diff);
  }

  void generateLineDiffs(String diffString) {
    final lines = diffString.split('\n');

    final processedDiffs = <Map<String, dynamic>>[];
    int originalLineNumber = 0;
    int newLineNumber = 0;

    for (var line in lines) {
      // Ignore metadata lines
      if (line.startsWith('---') || line.startsWith('+++') || line.startsWith('@@')) continue;

      if (line.startsWith('-')) {
        originalLineNumber++;
        processedDiffs.add({
          'type': 'removed',
          'original': line.substring(1).trim(),
          'new': '',
          'originalLine': originalLineNumber,
          'newLine': null,
        });
      } else if (line.startsWith('+')) {
        newLineNumber++;
        processedDiffs.add({
          'type': 'added',
          'original': '',
          'new': line.substring(1).trim(),
          'originalLine': null,
          'newLine': newLineNumber,
        });
      } else {
        originalLineNumber++;
        newLineNumber++;
        processedDiffs.add({
          'type': 'unchanged',
          'original': line.trim(),
          'new': line.trim(),
          'originalLine': originalLineNumber,
          'newLine': newLineNumber,
        });
      }
    }

    setState(() {
      _lineDiffs = processedDiffs;
    });
  }

  List<TextSpan> _highlightChangedWords(String original, String updated) {
    final originalWords = original.split(' ');
    final updatedWords = updated.split(' ');

    List<TextSpan> spans = [];
    for (int i = 0; i < originalWords.length || i < updatedWords.length; i++) {
      if (i < originalWords.length &&
          i < updatedWords.length &&
          originalWords[i] == updatedWords[i]) {
        spans.add(TextSpan(text: '${originalWords[i]} ', style: TextStyle(color: Colors.black)));
      } else {
        if (i < originalWords.length) {
          spans.add(TextSpan(
              text: '${originalWords[i]} ',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
        }
        if (i < updatedWords.length) {
          spans.add(TextSpan(
              text: '${updatedWords[i]} ',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)));
        }
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Line Diff Viewer')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text(
                  'Original',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'New',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Original (Removed and Unchanged Lines)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _lineDiffs.map((diff) {
                        Color bgColor = diff['type'] == 'removed'
                            ? Colors.red.withOpacity(0.1)
                            : Colors.transparent;

                        return Container(
                          color: bgColor,
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                diff['originalLine'] != null
                                    ? '${diff['originalLine']} -'
                                    : '',
                                style:
                                TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: diff['type'] == 'unchanged'
                                    ? SelectableText(
                                  diff['original'],
                                  style: TextStyle(fontSize: 16),
                                )
                                    : SelectableText.rich(
                                  TextSpan(
                                    children: _highlightChangedWords(
                                      diff['original'],
                                      diff['new'],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between columns
                  // Right Column: New (Added and Unchanged Lines)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _lineDiffs.map((diff) {
                        Color bgColor = diff['type'] == 'added'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.transparent;

                        return Container(
                          color: bgColor,
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                diff['newLine'] != null
                                    ? '${diff['newLine']} +'
                                    : '',
                                style:
                                TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: diff['type'] == 'unchanged'
                                    ? SelectableText(
                                  diff['new'],
                                  style: TextStyle(fontSize: 16),
                                )
                                    : SelectableText.rich(
                                  TextSpan(
                                    children: _highlightChangedWords(
                                      diff['original'],
                                      diff['new'],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
