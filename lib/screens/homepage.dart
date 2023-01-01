import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int hour = now.hour;
    String time = (hour > 12) ? "evening" : "morning";
    return Container(
      child: Column(children: [
        Container(
            alignment: Alignment.bottomLeft,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(('assets/images/bg.png')))),
            child: Container(
              padding: const EdgeInsets.all(36),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Good$time!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      "Ready to learn?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    )
                  ]),
            )),
        Expanded(
            child: LiquidPullToRefresh(
          onRefresh: () async => {await Future.delayed(Duration(seconds: 10))},
          child: ListView.separated(
              itemBuilder: (context, index) => ListTile(),
              separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: Divider(),
                  ),
              itemCount: 30),
        ))
      ]),
    );
  }
}
