import 'package:flutter/material.dart';

class AsyncGenericButton<T> extends StatefulWidget {
  final String text;
  final Future<T> Function() onPressed;
  final void Function(T result)? onSuccess;
  final void Function(dynamic error)? onError;
  final Widget? icon;
  final ButtonStyle? style;
  final bool enabled;
  final Widget? loadingWidget;
  final Duration? timeout;

  const AsyncGenericButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onSuccess,
    this.onError,
    this.icon,
    this.style,
    this.enabled = true,
    this.loadingWidget,
    this.timeout,
  });

  @override
  State<AsyncGenericButton<T>> createState() => _AsyncGenericButtonState<T>();
}

class _AsyncGenericButtonState<T> extends State<AsyncGenericButton<T>> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading || !widget.enabled) return;

    setState(() => _isLoading = true);

    try {
      final Future<T> operation = widget.timeout != null
          ? widget.onPressed().timeout(widget.timeout!)
          : widget.onPressed();

      final T result = await operation;

      if (mounted) {
        widget.onSuccess?.call(result);
      }
    } catch (error) {
      if (mounted) {
        widget.onError?.call(error);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = _isLoading
        ? widget.loadingWidget ??
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
        : widget.icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.icon!,
              const SizedBox(width: 8),
              Text(widget.text),
            ],
          )
        : Text(widget.text);

    return ElevatedButton(
      onPressed: _isLoading || !widget.enabled ? null : _handlePress,
      style: widget.style,
      child: child,
    );
  }
}
