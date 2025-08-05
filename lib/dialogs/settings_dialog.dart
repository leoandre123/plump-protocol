import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plumpen_app/models/game_settings.dart';

class SettingsDialog extends StatefulWidget {
  final GameSettings initialSettings;
  const SettingsDialog({super.key, required this.initialSettings});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  GameSettings _settings = GameSettings();

  @override
  void initState() {
    super.initState();
    _settings = GameSettings(
      oneCardMode: widget.initialSettings.oneCardMode,
      scoreForZero: widget.initialSettings.scoreForZero,
      allwaysShowScore: widget.initialSettings.allwaysShowScore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController editingController = TextEditingController();
    editingController.text = _settings.scoreForZero.toString();

    return AlertDialog(
      title: Text("Inställningar"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Antal rundor med 1 kort",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            DropdownButton<OneCardMode>(
              value: _settings.oneCardMode,

              items: OneCardMode.values
                  .map(
                    (mode) =>
                        DropdownMenuItem(value: mode, child: Text(mode.label)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _settings.oneCardMode = value!;
                });
              },
            ),
            Text(
              "Poäng för 0 kort",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: editingController,
              onChanged: (value) =>
                  _settings.scoreForZero = int.tryParse(value) ?? 5,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            Text(
              "Visa alltid total poäng",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Switch(
              value: _settings.allwaysShowScore,
              onChanged: (value) => setState(() {
                _settings.allwaysShowScore = value;
              }),
            ),
            Padding(padding: EdgeInsetsGeometry.all(16.0)),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _settings = GameSettings();
                });
              },
              child: Text("Återställ inställningar"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Avbryt"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_settings);
          },
          child: Text("Spara"),
        ),
      ],
    );
  }
}
