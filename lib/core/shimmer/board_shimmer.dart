import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:files_manager/theme/color.dart';

class BoardShimmer extends StatelessWidget {
  const BoardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: List.generate(
        4,
        (index) {
          return Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 78, 78, 78),
            highlightColor: Colors.grey[300]!,
            child: Container(
              height: mediaQuery.height / 7,
              width: mediaQuery.width,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: const BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ).animate().fade(duration: const Duration(milliseconds: 50));
        },
      ),
    );
  }
}
