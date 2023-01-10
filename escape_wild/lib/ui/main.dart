import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:easy_localization/easy_localization.dart';

part 'main.i18n.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return [
      buildTitle(),
      [
        buildNewGameBtn(),
        buildContinueGameBtn(),
      ].column(maa: MainAxisAlignment.center, caa: CrossAxisAlignment.stretch).constrained(maxW: 220),
    ].column(maa: MainAxisAlignment.spaceEvenly, caa: CrossAxisAlignment.center).center();
  }

  Widget buildTitle() {
    return _I.title.text(
      style: context.textTheme.displayLarge,
    );
  }

  Widget buildContinueGameBtn() {
    return ElevatedButton(
      onPressed: () {},
      child: _I.$continue
          .text(
            style: TextStyle(fontSize: 28),
          )
          .padAll(5),
    ).padAll(5);
  }

  Widget buildNewGameBtn() {
    return ElevatedButton(
      onPressed: () {},
      child: _I.newGame
          .text(
            style: TextStyle(fontSize: 28),
          )
          .padAll(5),
    ).padAll(5);
  }
}
