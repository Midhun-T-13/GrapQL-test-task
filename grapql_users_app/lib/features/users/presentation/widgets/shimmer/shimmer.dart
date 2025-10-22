import 'package:flutter/material.dart';

import 'shimmer_widget.dart';

class ShimmerWidget extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerWidget({
    super.key,
    required this.height,
    required this.width,
    this.baseColor = const Color(0xFFBDBDBD),
    this.borderRadius =8, // Default grey
    this.highlightColor = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor.withValues(alpha: 0.4),
      highlightColor: highlightColor.withValues(alpha: 0.5),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: highlightColor,
        ),
      ),
    );
  }
}

class CircleShimmer extends StatelessWidget {
  const CircleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerWidget(
      height: 40,
      width: 40,
      baseColor: Color(0xFFBDBDBD),
      highlightColor: Color(0xFFFFFFFF),
      borderRadius: 40,
    );
  }
}

class ChatShimmerScreen extends StatelessWidget {
  const ChatShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final isSender = index.isEven;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSender)
                const CircleShimmer(),
              if (!isSender)
                const SizedBox(width: 8),
              ShimmerWidget(
                width: isSender
                    ? MediaQuery.of(context).size.width * 0.5
                    : MediaQuery.of(context).size.width * 0.6,
                height: 60, // Vary message length
              ),
              if (isSender)
                const SizedBox(width: 8),
              if (isSender)
                const CircleShimmer(),
            ],
          ),
        );
      },
    );
  }
}
