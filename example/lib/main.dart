import 'package:clever_commandbar/clever_commandbar.dart';
import 'package:flutter/material.dart';

import 'demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clever Commandbar',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandActions(
      commands: [
        SimpleCommand(
          name: 'Hello World',
          description: 'This is a hello world command',
          shortcut: 'Ctrl + H',
          intent: const HelloWordIntent(),
          action: HelloWorldAction(context: context),
        ),
        SimpleCommand(
          name: 'About',
          description: 'About this app',
          shortcut: 'Ctrl + D',
          intent: const AboutIntent(),
          action: AboutAction(context: context),
        ),
      ],
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Clever Commandbar'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const DemoPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.navigation_rounded),
              )
            ],
          ),
          body: Center(
            child: FilledButton(
              onPressed: () {
                showDefaultCommandbar(context);
              },
              child: const Text('Show Commandbar'),
            ),
          ),
        );
      }),
    );
  }
}

class HelloWordIntent extends Intent {
  const HelloWordIntent();
}

class HelloWorldAction extends Action<HelloWordIntent> {
  final BuildContext context;

  HelloWorldAction({required this.context});

  @override
  void invoke(HelloWordIntent intent) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hello World'),
      ),
    );
  }
}

class AboutIntent extends Intent {
  const AboutIntent();
}

class AboutAction extends Action<AboutIntent> {
  final BuildContext context;

  AboutAction({required this.context});

  @override
  void invoke(AboutIntent intent) {
    showAboutDialog(context: context);
  }
}
