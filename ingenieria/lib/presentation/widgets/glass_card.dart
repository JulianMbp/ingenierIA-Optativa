import 'dart:ui';

import 'package:flutter/material.dart';

/// Glass-style card with blur effect and gradient overlay.
/// Inspired by iOS 18+ glassmorphism design language.
class GlassCard extends StatelessWidget {
  /// Child widget to display inside the glass card
  final Widget child;

  /// Border radius for rounded corners (default: 24px)
  final double borderRadius;

  /// Padding inside the card (default: 16px)
  final EdgeInsets? padding;

  /// Margin around the card (default: none)
  final EdgeInsets? margin;

  /// Background gradient colors (optional)
  final List<Color>? gradientColors;

  /// Opacity of the blur effect (0.0 - 1.0)
  final double opacity;

  /// Blur intensity (sigma value)
  final double blurIntensity;

  /// Border color (optional)
  final Color? borderColor;

  /// Border width (default: 1.0)
  final double borderWidth;

  /// Shadow elevation (default: 8.0)
  final double elevation;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.gradientColors,
    this.opacity = 0.15,
    this.blurIntensity = 10.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.elevation = 8.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Default gradient based on theme
    final defaultGradient = isDark
        ? [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ]
        : [
            Colors.white.withOpacity(0.7),
            Colors.white.withOpacity(0.3),
          ];

    final gradient = gradientColors ?? defaultGradient;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5)),
                width: borderWidth,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass-style container with customizable blur and gradient
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final List<Color>? gradientColors;
  final double blurIntensity;

  const GlassContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.gradientColors,
    this.blurIntensity = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ??
                    [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
