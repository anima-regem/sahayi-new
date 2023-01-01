import 'package:flutter/material.dart';
import 'main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });

    return Container(
      color: Color.fromARGB(255, 255, 208, 212),
      child: Center(
          child: Container(
        height: 100,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        // decoration: BoxDecoration(
        //     color: Color.fromARGB(255, 255, 208, 212),
        //     borderRadius: BorderRadius.circular(15),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.red.shade400,
        //         offset: Offset(5, 5),
        //         blurRadius: 15,
        //         spreadRadius: 0.5,
        //       ),
        //       BoxShadow(
        //         color: Color.fromARGB(255, 255, 244, 244),
        //         offset: Offset(-5, -5),
        //         blurRadius: 15,
        //         spreadRadius: 0.5,
        //       ),
        //     ]),
        child: Image.asset('assets/images/sahayiR.png'),
      )),
    );
  }
}
