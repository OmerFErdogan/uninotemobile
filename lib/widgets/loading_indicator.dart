import 'package:flutter/material.dart';

/// Yükleme durumlarında gösterilecek gösterge
class LoadingIndicator extends StatelessWidget {
  /// Göstergenin boyutu
  final double size;
  
  /// Göstergenin rengi
  final Color? color;
  
  /// Göstergenin kalınlığı
  final double strokeWidth;
  
  /// Göstergenin etrafındaki boşluk
  final EdgeInsetsGeometry padding;

  /// Yükleme göstergesi oluşturur
  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 4.0,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: color != null
                ? AlwaysStoppedAnimation<Color>(color!)
                : null,
          ),
        ),
      ),
    );
  }
}
