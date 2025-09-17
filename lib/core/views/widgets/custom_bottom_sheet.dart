import 'package:flutter/material.dart';

class CustomBottomSheet extends StatefulWidget {
  final Widget child;
  final bool enableDrag;
  final double? height;
  final double? width;
  final Color backgroundColor;
  final double borderRadius;
  final bool showDragHandle;
  final EdgeInsets? padding;

  const CustomBottomSheet({
    super.key,
    required this.child,
    this.enableDrag = true,
    this.height,
    this.width,
    this.backgroundColor = Colors.white,
    this.borderRadius = 20.0,
    this.showDragHandle = true,
    this.padding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool enableDrag = true,
    double? height,
    double? width,
    Color backgroundColor = Colors.white,
    double borderRadius = 20.0,
    bool showDragHandle = true,
    EdgeInsets? padding,
    bool isDismissible = true,
    bool enableDragToDismiss = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDragToDismiss,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => CustomBottomSheet(
        enableDrag: enableDrag,
        height: height,
        width: width,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        showDragHandle: showDragHandle,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final sheetHeight = widget.height ?? screenHeight * 0.9;
    final sheetWidth = widget.width ?? screenWidth;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5 * _animation.value),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, (1 - _animation.value) * sheetHeight),
              child: Container(
                height: sheetHeight,
                width: sheetWidth,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.borderRadius),
                    topRight: Radius.circular(widget.borderRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: widget.enableDrag
                    ? GestureDetector(
                        onPanUpdate: (details) {
                          if (details.delta.dy > 0) {
                            final progress = details.delta.dy / sheetHeight;
                            _animationController.value =
                                (_animationController.value - progress).clamp(
                                  0.0,
                                  1.0,
                                );
                          }
                        },
                        onPanEnd: (details) {
                          if (_animationController.value < 0.5) {
                            Navigator.of(context).pop();
                          } else {
                            _animationController.forward();
                          }
                        },
                        child: _buildSheetContent(),
                      )
                    : _buildSheetContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetContent() {
    return Column(
      children: [
        if (widget.showDragHandle) _buildDragHandle(),
        Expanded(
          child: Container(padding: widget.padding, child: widget.child),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
