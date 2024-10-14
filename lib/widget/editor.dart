import 'dart:convert';
import 'dart:math';
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
  final _rowHeight = 25.0;
  final _colWidth = 30.0;
  final _rightColdWidth = 20.0;
  final _left = 0.6;
  final _selectColor = Colors.blue.shade300;
  bool _selecting = false;

  Offset _startPos = const Offset(0, 0);
  Offset _currentPost = const Offset(0, 0);
  List<int> _rowRange = [];
  List<int> _colRnage = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _handleDown(PointerDownEvent e) {
    setState(() {
      _selecting = true;
      _startPos = e.localPosition;
      _rowRange = [];
      _colRnage = [];
    });
  }

  void _handleMove(PointerMoveEvent e) {
    if (_selecting) {
      _currentPost = e.localPosition;

      int startCol = (_startPos.dx / _colWidth).floor();
      int startRow =
          ((_startPos.dy + _scrollController.offset) / _rowHeight).floor();

      int curCol = (_currentPost.dx / _colWidth).floor();
      int curRow =
          ((_currentPost.dy + _scrollController.offset) / _rowHeight).floor();

      setState(() {
        _colRnage = [min(startCol, curCol), max(startCol, curCol)];
        _rowRange = [min(startRow, curRow), max(startRow, curRow)];
      });
    }
  }

  void _handleUp(PointerUpEvent e) {
    _selecting = false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleDown,
      onPointerMove: _handleMove,
      onPointerUp: _handleUp,
      child: LayoutBuilder(
        builder: _buildList,
      ),
    );
  }

  Widget _buildList(BuildContext context, BoxConstraints constr) {
    final leftWidth = constr.maxWidth * _left;

    final cols = leftWidth ~/ _colWidth;
    final rows = widget.binData.length ~/ cols + 1;

    return ListView.builder(
      controller: _scrollController,
      itemCount: rows,
      itemExtent: _rowHeight,
      itemBuilder: (ctx, row) => _buildRow(context, row, cols),
    );
  }

  Widget _buildRow(BuildContext context, int row, int colNum) {
    final rowChild = <Widget>[];
    final rightChild = <Widget>[];
    for (int col = 0; col < colNum; col++) {
      int idx = row * colNum + col;
      if (idx >= widget.binData.length) break;
      debugPrint('col:$col');
      Color? color;
      if (_rowRange.isNotEmpty) {
        if (_rowRange[0] == _rowRange[1]) {
          if (row == _rowRange[0] &&
              col >= _colRnage[0] &&
              col <= _colRnage[1]) {
            color = _selectColor;
          }
        } else {
          if (row > _rowRange[0] && row < _rowRange[1]) {
            color = _selectColor;
          }
          if (_rowRange[0] == row && col >= _colRnage[0]) {
            color = _selectColor;
          } else if (_rowRange[1] == row && col <= _colRnage[1]) {
            color = _selectColor;
          }
        }
      }

      int byte = widget.binData[idx];
      rowChild.add(Container(
        width: _colWidth,
        alignment: Alignment.center,
        child: Text(
          byte.toRadixString(16).padLeft(2, "0"),
          style: TextStyle(
            fontFamily: "Menlo",
            backgroundColor: color,
          ),
        ),
      ));
      String content = ".";
      if (byte <= 127 && byte != 32) {
        content = Encoding.getByName("ascii")?.decode([byte]) ?? " ";
      }
      rightChild.add(Container(
        width: _rightColdWidth,
        alignment: Alignment.center,
        child: Text(
          content,
          style: TextStyle(
            fontFamily: "Menlo",
            backgroundColor: color,
          ),
        ),
      ));
    }
    return SizedBox(
      height: _rowHeight,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: rowChild,
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 2,
            child: Row(
              children: rightChild,
            ),
          ),
        ],
      ),
    );
  }
}
