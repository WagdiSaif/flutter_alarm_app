import 'package:flutter/material.dart';

class SizerModel {
  static late double hieght;
  static late double width;

  static void initSize(double h, double w) {
    hieght = h;
    width = w;
  }
}

class SizerUitles extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  const SizerUitles({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = MediaQuery.of(context).size.width;
        final h = MediaQuery.of(context).size.height;

        SizerModel.initSize(h, w);
        return builder(context);
      },
    );
  }
}

extension ResponseSize on num {
  double get sh => (SizerModel.hieght * (this / 100));

  double get sw => (SizerModel.width * (this / 100));
}





//------------------


