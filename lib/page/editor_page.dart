import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hex_editor/widget/editor.dart';
import 'package:hex_editor/widget/sandbox.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  Uint8List _leftContext = Uint8List(0);

  void _handleMenuSelection(String operation) {
    switch (operation) {
      case 'open':
        _handleOpenFile();
        break;
    }
  }

  void _handleOpenFile() async {
    final file = await openFile();
    final data = await file?.readAsBytes();
    setState(() {
      _leftContext = data ?? Uint8List(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        const PlatformMenu(
          label: "hex_editor",
          menus: [
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.about),
              ],
            ),
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.hide),
                PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.hideOtherApplications),
                PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.showAllApplications),
              ],
            ),
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.quit),
              ],
            ),
          ],
        ),
        PlatformMenu(
          label: "File",
          menus: [
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: 'Open a file',
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyO,
                    meta: true,
                  ),
                  onSelected: () {
                    _handleMenuSelection('open');
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Editor(binData: _leftContext),
        ),
      ),
    );
  }
}
