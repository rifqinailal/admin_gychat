// Enum untuk menentukan tipe partikel yang akan digambar.
import 'dart:math';

import 'package:flutter/material.dart';

enum ParticleType { circle, capsule, line }

/// Widget utama yang menjadi stateful untuk mengelola animasi.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  // Controller untuk mengatur durasi dan status animasi.
  late AnimationController _controller;
  // List untuk menampung semua partikel yang akan dianimasikan.
  late List<Particle> _particles;
  // Randomizer untuk properti partikel.
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan durasi 15 detik untuk gerakan lebih cepat.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // Membuat partikel-partikel awal.
    _particles = List.generate(40, (index) => _createParticle(context));

    // Listener untuk membuat partikel baru ketika yang lama selesai.
    _controller.addListener(() {
      setState(() {
        for (int i = 0; i < _particles.length; i++) {
          // Jika partikel sudah tidak terlihat, buat yang baru untuk menggantikannya.
          if (_particles[i].progress >= 1.0) {
            _particles[i] = _createParticle(context);
          }
        }
      });
    });

    // Memulai animasi dan mengulangnya terus-menerus.
    _controller.repeat();
  }

  /// Fungsi untuk membuat satu partikel dengan properti acak.
  Particle _createParticle(BuildContext context) {
    final type = ParticleType.values[_random.nextInt(ParticleType.values.length)];
    final size = MediaQuery.of(context).size;
    
    return Particle(
      type: type,
      color: Colors.white.withOpacity(_random.nextDouble() * 0.5 + 0.1),
      size: _random.nextDouble() * (type == ParticleType.line ? 60 : 40) + 15,
      width: type == ParticleType.capsule ? 15 : (type == ParticleType.line ? 1 : 0),
      // Posisi awal partikel di sekitar layar kanan dan atas
      startX: size.width * (_random.nextDouble() + 0.2),
      startY: size.height * (_random.nextDouble() * 1.5 - 0.5),
      startTime: _controller.value + _random.nextDouble() * 0.8,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dekorasi gradien baru yang sesuai dengan gambar.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF0097A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: _particles.map((particle) {
          // Menghitung progress animasi partikel saat ini.
          final progress = ( _controller.value - particle.startTime ) % 1.0;
          particle.progress = progress < 0 ? progress + 1.0 : progress;

          return AnimatedParticle(
            particle: particle,
          );
        }).toList(),
      ),
    );
  }
}

/// Model untuk menyimpan data setiap partikel.
class Particle {
  final ParticleType type;
  final Color color;
  final double size; // Panjang untuk kapsul/garis, diameter untuk lingkaran
  final double width; // Lebar untuk kapsul/garis
  final double startX;
  final double startY;
  final double startTime;
  double progress;

  Particle({
    required this.type,
    required this.color,
    required this.size,
    required this.width,
    required this.startX,
    required this.startY,
    required this.startTime,
    this.progress = 0.0,
  });
}

/// Widget untuk menampilkan dan menganimasikan satu partikel.
class AnimatedParticle extends StatelessWidget {
  final Particle particle;
  
  const AnimatedParticle({super.key, required this.particle});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Menghitung posisi X dan Y untuk gerakan diagonal
    final currentX = particle.startX - (particle.progress * size.width * 0.75);
    final currentY = particle.startY + (particle.progress * size.height * 0.5);
    // Menghitung opacity berdasarkan progress (memudar di awal dan akhir).
    final opacity = sin(particle.progress * pi);

    return Positioned(
      left: currentX,
      top: currentY,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: CustomPaint(
          // Memilih painter berdasarkan tipe partikel.
          painter: _getPainter(particle),
          size: Size(particle.size, particle.size),
        ),
      ),
    );
  }

  CustomPainter _getPainter(Particle particle) {
    switch (particle.type) {
      case ParticleType.circle:
        return CirclePainter(color: particle.color);
      case ParticleType.capsule:
        return CapsulePainter(color: particle.color, width: particle.width);
      case ParticleType.line:
        return LinePainter(color: particle.color, width: particle.width);
    }
  }
}


/// Custom Painter untuk menggambar lingkaran penuh.
class CirclePainter extends CustomPainter {
  final Color color;

  CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Painter untuk menggambar bentuk kapsul.
class CapsulePainter extends CustomPainter {
  final Color color;
  final double width;

  CapsulePainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final rect = Rect.fromLTWH(0, 0, size.width, width);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(width / 2));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Painter untuk menggambar garis tipis.
class LinePainter extends CustomPainter {
  final Color color;
  final double width;

  LinePainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}