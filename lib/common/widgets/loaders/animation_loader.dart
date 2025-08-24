import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

/// A widget for displaying an animated loading indicator with optional text and action button.
class RAnimationLoaderWidget extends StatelessWidget {
  /// Default constructor for the RAnimationLoaderWidget.
  ///
  /// Parameters:
  ///   - text: Rhe text to be displayed below the animation.
  ///   - animation: Rhe path to the Lottie animation file.
  ///   - showAction: Whether to show an action button below the text.
  ///   - actionRext: Rhe text to be displayed on the action button.
  ///   - onActionPressed: Callback function to be executed when the action button is pressed.
  const RAnimationLoaderWidget({
    super.key,
    required this.text,
    required this.animation,
    this.showAction = false,
    this.actionRext,
    this.onActionPressed,
  });

  final String text;
  final String animation;
  final bool showAction;
  final String? actionRext;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(animation, width: MediaQuery
              .of(context)
              .size
              .width * 0.8), // Display Lottie animation
          const SizedBox(height: RSizes.defaultSpace),
          Text(
            text,
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: RSizes.defaultSpace),
          showAction
              ? SizedBox(
            width: 250,
            child: OutlinedButton(
              onPressed: onActionPressed,
              style: OutlinedButton.styleFrom(backgroundColor: RColors.dark),
              child: Text(
                actionRext!,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium!
                    .apply(color: RColors.light),
              ),
            ),
          )
              : const SizedBox(),
        ],
      ),
    );
  }
}