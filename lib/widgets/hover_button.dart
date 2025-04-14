import 'package:flutter/material.dart';

class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;

  const HoverButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFCC2B2B),
    this.elevation = 4.0,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + 4,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
      if (_isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                child: Card(
                  elevation: _elevationAnimation.value,
                  color: widget.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 