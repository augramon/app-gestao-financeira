import 'dart:async';

import 'package:flutter/material.dart';

/// Texto com efeito "máquina de escrever": digita uma frase caractere a
/// caractere, faz uma pausa, apaga e passa para a próxima — em loop. Acompanha
/// um cursor piscando ao final do texto.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.phrases,
    this.style,
    this.typingSpeed = const Duration(milliseconds: 55),
    this.deletingSpeed = const Duration(milliseconds: 28),
    this.pauseAfterTyping = const Duration(milliseconds: 1600),
    this.pauseBeforeTyping = const Duration(milliseconds: 350),
  });

  /// Frases exibidas em sequência (volta à primeira ao terminar).
  final List<String> phrases;
  final TextStyle? style;
  final Duration typingSpeed;
  final Duration deletingSpeed;
  final Duration pauseAfterTyping;
  final Duration pauseBeforeTyping;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _cursorController;
  int _phraseIndex = 0;
  int _charCount = 0;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _scheduleNext(widget.pauseBeforeTyping);
  }

  void _scheduleNext(Duration delay) {
    _timer = Timer(delay, _tick);
  }

  void _tick() {
    if (!mounted) return;
    final current = widget.phrases[_phraseIndex];

    if (!_deleting) {
      // Digitando.
      if (_charCount < current.length) {
        setState(() => _charCount++);
        _scheduleNext(widget.typingSpeed);
      } else {
        // Terminou de digitar: pausa e começa a apagar.
        _deleting = true;
        _scheduleNext(widget.pauseAfterTyping);
      }
    } else {
      // Apagando.
      if (_charCount > 0) {
        setState(() => _charCount--);
        _scheduleNext(widget.deletingSpeed);
      } else {
        // Apagou tudo: vai para a próxima frase.
        _deleting = false;
        _phraseIndex = (_phraseIndex + 1) % widget.phrases.length;
        _scheduleNext(widget.pauseBeforeTyping);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style =
        widget.style ?? DefaultTextStyle.of(context).style;
    final visible = widget.phrases.isEmpty
        ? ''
        : widget.phrases[_phraseIndex].substring(0, _charCount);
    final cursorColor = (style.color ?? Colors.black).withValues(alpha: 0.7);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(visible, style: style)),
        FadeTransition(
          opacity: _cursorController,
          child: Container(
            width: 2,
            height: (style.fontSize ?? 14) * 1.1,
            margin: const EdgeInsets.only(left: 2),
            color: cursorColor,
          ),
        ),
      ],
    );
  }
}
