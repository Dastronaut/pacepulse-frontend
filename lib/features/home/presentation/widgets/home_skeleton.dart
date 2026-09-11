import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';

const double _ringsBlock = 208;
const double _tileBlock = 108;
const double _cardBlock = 88;

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Column(
        key: const Key('home_skeleton'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: PPSpacing.padScreen),
            child: PPSkeleton(
              key: Key('home_skeleton_rings'),
              height: _ringsBlock,
              radius: PPRadius.lg,
            ),
          ),
          const SizedBox(height: PPSpacing.gapSection),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: PPSpacing.padScreen),
            child: Row(
              children: [
                Expanded(
                  child: PPSkeleton(height: _tileBlock, radius: PPRadius.md),
                ),
                SizedBox(width: PPSpacing.s3),
                Expanded(
                  child: PPSkeleton(height: _tileBlock, radius: PPRadius.md),
                ),
              ],
            ),
          ),
          const SizedBox(height: PPSpacing.gapSection),
          for (var i = 0; i < 2; i++)
            const Padding(
              padding: EdgeInsets.only(
                left: PPSpacing.padScreen,
                right: PPSpacing.padScreen,
                bottom: PPSpacing.gapStack,
              ),
              child: PPSkeleton(height: _cardBlock, radius: PPRadius.md),
            ),
        ],
      );
}
