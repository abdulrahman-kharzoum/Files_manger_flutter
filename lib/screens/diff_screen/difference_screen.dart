import 'dart:js' as js;
import 'package:flutter/material.dart';

class DiffViewer extends StatefulWidget {
  @override
  _DiffViewerState createState() => _DiffViewerState();
}

class _DiffViewerState extends State<DiffViewer> {
  String _diffHtml = '';

  // Function to get the diff HTML using JavaScript interop
  void generateDiff(String diff) {
    // Call the JavaScript function from index.html
    var result = js.context.callMethod('generateDiffHtml', [diff]);

    setState(() {
      _diffHtml = result; // Set the HTML diff to display in the widget
    });
  }

  @override
  void initState() {
    super.initState();
    const comparison = "--- Original\n+++ New\n@@ @@\n-hello this a new file \r\n-so so what \r\n+hello this a new folder \r\n+ so what \r\n \r\n i am still a rockstar..\r\n-idon't need u ..\r\n+\r\n+ad\r\n+dd\r\n";
    generateDiff(comparison); // Generate the diff HTML
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diff Viewer')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Check if diffHtml is not empty
            _diffHtml.isNotEmpty
                ? HtmlElementView(viewType: 'diffView')
                : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

