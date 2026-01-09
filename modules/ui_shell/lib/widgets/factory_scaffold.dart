import 'package:flutter/material.dart';

class FactoryScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool showBackButton;

  const FactoryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton && Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: actions,
      ),
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
