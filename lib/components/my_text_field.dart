import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.onChanged,
    this.focusNode,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFocused = false;
  bool _isObscure = false;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    widget.focusNode?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          widget.errorText != null
                              ? Colors.red
                              : _isFocused
                              ? Colors.green
                              : Colors.grey.withOpacity(0.5),
                      width: widget.errorText != null || _isFocused ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        widget.errorText != null
                            ? Colors.red.withOpacity(0.1)
                            : Colors.transparent,
                    boxShadow:
                        _isFocused
                            ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [],
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: widget.controller,
                        obscureText: _isObscure,
                        keyboardType: widget.keyboardType,
                        focusNode: widget.focusNode,
                        onChanged: widget.onChanged,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Quicksand',
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          suffixIcon:
                              widget.obscureText
                                  ? IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  )
                                  : widget.errorText != null
                                  ? TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 300),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Icon(
                                          Icons.error_outline,
                                          color: Colors.red.withOpacity(value),
                                        ),
                                      );
                                    },
                                  )
                                  : _isFocused
                                  ? FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    ),
                                  )
                                  : null,
                        ),
                      ),
                      // Animated highlight line
                      if (_isFocused)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Container(
                                height: 2,
                                width:
                                    MediaQuery.of(context).size.width * value,
                                color: Colors.green.withOpacity(0.2),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.errorText != null)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.red.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.errorText!,
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.8),
                            fontSize: 12,
                            fontFamily: 'Quicksand',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
