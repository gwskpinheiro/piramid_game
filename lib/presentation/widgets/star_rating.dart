import 'package:flutter/material.dart';

/// Widget de avaliação por estrelas — intervalo de 1 a 5
class StarRating extends StatelessWidget {
  final int stars;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onChanged;

  const StarRating({
    super.key,
    required this.stars,
    this.size = 28,
    this.interactive = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (interactive) {
      return _InterativeStars(
        stars: stars,
        size: size,
        onChanged: onChanged!,
      );
    }
    return _DisplayStars(stars: stars, size: size);
  }
}

class _DisplayStars extends StatelessWidget {
  final int stars;
  final double size;
  const _DisplayStars({required this.stars, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
          color: i < stars ? const Color(0xFFFFD700) : Colors.grey.shade400,
          size: size,
        );
      }),
    );
  }
}

class _InterativeStars extends StatelessWidget {
  final int stars;
  final double size;
  final ValueChanged<int> onChanged;

  const _InterativeStars({
    required this.stars,
    required this.size,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        return GestureDetector(
          onTap: () => onChanged(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i < stars ? const Color(0xFFFFD700) : Colors.grey.shade400,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
