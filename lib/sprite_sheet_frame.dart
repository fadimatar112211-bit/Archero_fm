import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpriteSheetFrame extends StatelessWidget {
  const SpriteSheetFrame({
    super.key,
    required this.asset,
    required this.frameCount,
    required this.frameIndex,
  });

  final String asset;
  final int frameCount;
  final int frameIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) {
          return const SizedBox.expand();
        }
        final frame = frameIndex % frameCount;
        return ClipRect(
          child: SizedBox(
            width: width,
            height: height,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: width * frameCount,
              maxWidth: width * frameCount,
              minHeight: height,
              maxHeight: height,
              child: Transform.translate(
                offset: Offset(-width * frame, 0),
                child: SizedBox(
                  width: width * frameCount,
                  height: height,
                  child: SvgPicture.asset(asset, fit: BoxFit.fill),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
