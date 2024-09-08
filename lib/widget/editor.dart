import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.binData,
  });

  final Uint8List binData;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final _left = 0.6;
  late double _textWidth = 0;

  @override
  void initState() {
    super.initState();

    TextPainter tp = TextPainter(
      text: const TextSpan(
        text: "00",
        style: TextStyle(fontFamily: "Menlo"),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    _textWidth = tp.width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: _buildList,
    );
  }

  Widget _buildList(BuildContext context, BoxConstraints constr) {
    final leftWidth = constr.maxWidth * _left;

    final cols = leftWidth ~/ _textWidth - 8;
    final rows = widget.binData.length ~/ cols + 1;

    return ListView.builder(
      itemCount: rows,
      itemBuilder: (ctx, row) => _buildRow(context, row, cols),
    );
  }

  Widget _buildRow(BuildContext context, int row, int colNum) {
    final rowChild = <Widget>[];
    final rightChild = <Widget>[];
    for (int col = 0; col < colNum; col++) {
      int idx = row * colNum + col;
      if (idx >= widget.binData.length) break;

      int byte = widget.binData[idx];
      rowChild.add(Text(
        byte.toRadixString(16).padLeft(2, "0"),
        style: const TextStyle(fontFamily: "Menlo"),
      ));
      String content = ".";
      if (byte <= 127) {
        content = Encoding.getByName("ascii")?.decode([byte]) ?? "";
      }
      rightChild.add(Text(
        content,
        style: const TextStyle(fontFamily: "Menlo"),
      ));
    }
    return SizedBox(
      height: 25,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowChild,
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rightChild,
            ),
          ),
        ],
      ),
    );
  }
}
