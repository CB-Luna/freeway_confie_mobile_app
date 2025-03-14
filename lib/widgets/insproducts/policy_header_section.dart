import 'package:flutter/material.dart';

class PolicyHeaderSection extends StatefulWidget {
  final String title;
  final Map<String, String> fields;
  final Function(Map<String, String>) onFieldsChanged;

  const PolicyHeaderSection({
    required this.title, required this.fields, required this.onFieldsChanged, super.key,
  });

  @override
  State<PolicyHeaderSection> createState() => _PolicyHeaderSectionState();
}

class _PolicyHeaderSectionState extends State<PolicyHeaderSection> {
  bool _isEditing = false;
  late Map<String, String> _editableFields;
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _editableFields = Map.from(widget.fields);
    _controllers = {};
    widget.fields.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFF0046B9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
                color: const Color(0xFF0046B9),
                onPressed: () {
                  if (_isEditing) {
                    // Guardar cambios
                    widget.fields.forEach((key, value) {
                      _editableFields[key] = _controllers[key]!.text;
                    });
                    widget.onFieldsChanged(_editableFields);
                  }
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          ..._buildFields(),
        ],
      ),
    );
  }

  List<Widget> _buildFields() {
    return widget.fields.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _isEditing
            ? TextField(
                controller: _controllers[entry.key],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              )
            : Text(
                _editableFields[entry.key] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: entry.key == 'Name' ? Colors.black : Colors.black54,
                ),
              ),
      );
    }).toList();
  }
}
