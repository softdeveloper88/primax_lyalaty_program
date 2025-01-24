import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonShimmerLoading extends StatelessWidget {
  final int itemCount;
  final double avatarRadius;
  final double textHeight;
  final double cardHeight;
  final EdgeInsetsGeometry padding;

  const CommonShimmerLoading({
    Key? key,
    this.itemCount = 5, // Number of shimmer items to show
    this.avatarRadius = 50.0, // Default avatar size for circular shimmer
    this.textHeight = 16.0, // Default height for text shimmer
    this.cardHeight = 100.0, // Default height for card shimmer
    this.padding = const EdgeInsets.all(8.0), // Default padding
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: textHeight,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: textHeight,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
