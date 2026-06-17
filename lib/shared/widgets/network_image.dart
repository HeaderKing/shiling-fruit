import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final widget = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      errorWidget: (context, _, _) => Container(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.broken_image_rounded,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: widget);
    }
    return widget;
  }
}