import 'package:flutter/material.dart';

class AsyncLoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String buttonText;
  final String successMessage;
  final String errorMessage;

  const AsyncLoadingButton({
    super.key,
    required this.onPressed,
    this.buttonText = 'Submit',
    this.successMessage = 'Success!',
    this.errorMessage = 'Error occurred',
  });

  @override
  State<AsyncLoadingButton> createState() => _AsyncLoadingButtonState();
}

class _AsyncLoadingButtonState extends State<AsyncLoadingButton> {
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  void _handlePress() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });

    try {
      await widget.onPressed();
      setState(() {
        _isLoading = false;
        _message = widget.successMessage;
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = widget.errorMessage;
        _isError = true;
      });
    }

    // Clear message after 2 seconds
    if (_message != null) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _handlePress,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.buttonText),
        ),
        if (_message != null) ...[
          const SizedBox(height: 8),
          Text(
            _message!,
            style: TextStyle(
              color: _isError ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
