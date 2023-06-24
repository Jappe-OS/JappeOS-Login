//  JappeOS-Login, A login screen for JappeOS.
//  Copyright (C) 2023  Jappe02
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as
//  published by the Free Software Foundation, either version 3 of the
//  License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jappeos_desktop_ui/widgets/bases/button_base_glasshover.dart';
import 'package:jappeos_desktop_ui/widgets/blur_container.dart';
import 'package:jappeos_desktop_ui/widgets/loading_indicator.dart';
import 'package:jappeos_desktop_ui/widgets/text.dart';
import 'package:jappeos_desktop_ui/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:shade_theming/shade_theming.dart';
import 'package:jappeos_core_lib/jappeos_core_lib.dart';

void main(List<String> arguments) {
  List<String?> login = [null, null];

  //JappeOS.INIT();

  if (arguments.isNotEmpty) login = arguments[0].split(r"$¤&&£$");
  if (login[0] != null && login[1] != null) JappeOS.login(login[0] ?? "", login[1] ?? "");

  ShadeTheme.setThemeProperties(
      DarkThemeProperties(ThemeProperties(
          const Color.fromARGB(255, 30, 30, 30),
          const Color.fromARGB(255, 37, 37, 38),
          const Color.fromARGB(80, 243, 243, 243),
          Colors.blue,
          const Color(0xFFFFFFFF).withOpacity(0.9),
          const Color(0xFFFFFFFF),
          const Color(0xFFFFFFFF).withOpacity(0.6),
          const Color(0xFF000000).withOpacity(0.9))),
      LightThemeProperties(ThemeProperties(
          const Color.fromARGB(255, 255, 255, 255),
          const Color.fromARGB(255, 243, 243, 243),
          const Color.fromARGB(80, 37, 37, 38),
          Colors.blue,
          const Color(0xFF000000).withOpacity(0.9),
          const Color(0xFF000000),
          const Color(0xFF000000).withOpacity(0.6),
          const Color(0xFFFFFFFF).withOpacity(0.9))));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ShadeThemeProvider>(
            create: (_) => ShadeThemeProvider())
      ],
      child: const AppMain(),
    ),
  );
}

class AppMain extends StatelessWidget {
  const AppMain({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JappeOS Login',
      home: LoginUI(),
    );
  }
}

class LoginUI extends StatefulWidget {
  const LoginUI({super.key});

  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> with SingleTickerProviderStateMixin {
  bool showUserLogin = false;
  bool userLoginLoading = false;
  String backgroundImage = "resources/images/backgrounds/wallpaper1.jpg";

  DateTime _currentDateTime = DateTime.now();
  Timer? _timer;
  final _timeFormat = DateFormat('HH:mm');
  final _dateFormat = DateFormat('EEEE, MMMM d');

  Timer? _userLoginTimer;

  late AnimationController _controller;
  late Animation<double> _animation;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _startTimer();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _stopTimer();
    _controller.dispose();
    super.dispose();
  }

  void _loginScreen() {
    setState(() {
      showUserLogin = true;
    });
    _controller.reset();
    _controller.forward();
    _startUserLoginTimer();
  }

  void _mainScreen() {
    setState(() {
      showUserLogin = false;
    });
    _controller.reset();
    _stopUserLoginTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      _updateDateTime();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateDateTime() {
    setState(() {
      _currentDateTime = DateTime.now();
    });
  }

  void _startUserLoginTimer() {
    _userLoginTimer =
        Timer.periodic(const Duration(seconds: 25), (Timer timer) {
      if (userLoginLoading) return;
      setState(() {
        _mainScreen();
      });
      _stopUserLoginTimer();
    });
  }

  void _stopUserLoginTimer() {
    _userLoginTimer?.cancel();
    _userLoginTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget base(Widget? child) {
      return Scaffold(
        body: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              scale: 1 + (_animation.value / 8),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: child,
        ),
      );
    }

    if (!showUserLogin) {
      final time = _timeFormat.format(_currentDateTime);
      final date = _dateFormat.format(_currentDateTime);

      return base(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _loginScreen,
          onScaleStart: (details) => _loginScreen(),
          child: RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent) _loginScreen();
            },
            child: Focus(
              autofocus: true,
              onFocusChange: (hasFocus) {
                if (hasFocus) _focusNode.requestFocus();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 95,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 5,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 5,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      List<Widget> columnItems = !userLoginLoading
          ? [
              const DeuiTextField(
                hintText: "Username",
              ),
              const SizedBox(
                height: 5,
              ),
              const DeuiTextField(
                hintText: "Password",
              ),
              const SizedBox(
                height: 10,
              ),
              DeuiButtonBaseGlasshover(
                borderRadius: 55,
                backgroundColorTransp: true,
                //backgroundColor: SHUI_THEME_PROPERTIES(context).backgroundColor1.withOpacity(0.1),
                onPress: () {
                  setState(() => userLoginLoading = true);
                },
                child: const Center(
                  child: DeuiText(isTitle: false, text: "Log In"),
                ),
              )
            ]
          : [
              const DeuiLoadingIndicator(),
              const DeuiText(isTitle: false, text: "Please Wait..."),
            ];

      return base(
        AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? child) {
            final animProgress = _animation.value;
            return Transform.scale(
              scale: 1 - 1 / 8,
              child: Center(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: animProgress * 10, sigmaY: animProgress * 10),
                  child: DeuiBlurContainer(
                    width: 300,
                    bordered: true,
                    gradient: true,
                    radiusSides: BorderRadiusSides(true, true, true, true),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: columnItems,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
