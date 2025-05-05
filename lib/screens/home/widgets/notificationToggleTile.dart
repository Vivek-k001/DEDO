import 'package:flutter/material.dart';

class NotificationToggleTile extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const NotificationToggleTile({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<NotificationToggleTile> createState() => _NotificationToggleTileState();
}

class _NotificationToggleTileState extends State<NotificationToggleTile> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialValue;
  }

  void _toggleSwitch(bool value) {
    setState(() {
      _isEnabled = value;
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Notifications'),
      subtitle: Text(_isEnabled ? 'Enabled' : 'Disabled'),
      value: _isEnabled,
      onChanged: _toggleSwitch,
      secondary: Icon(
        _isEnabled ? Icons.notifications_active : Icons.notifications_off,
        color: _isEnabled ? Colors.green : Colors.grey,
      ),
    );
  }
}
