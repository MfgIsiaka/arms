import 'package:flutter/material.dart';

class PropertyEditScreen extends StatefulWidget {
  Map<String, dynamic> prop;
  PropertyEditScreen(this.prop, {super.key});

  @override
  State<PropertyEditScreen> createState() => _PropertyEditScreenState();
}

class _PropertyEditScreenState extends State<PropertyEditScreen> {
  Map<String, dynamic> _prop = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prop = widget.prop;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
