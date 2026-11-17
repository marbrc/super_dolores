import 'package:flutter/material.dart';

import '../tema.dart';

/// Mensaje amable de error (nunca muestra detalles técnicos).
class Aviso extends StatelessWidget {
  final String? texto;
  const Aviso(this.texto, {super.key});
  @override
  Widget build(BuildContext context) => texto == null
      ? const SizedBox.shrink()
      : Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF6E1DC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: Cafe.sale, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(texto!, style: const TextStyle(color: Color(0xFF5C2219)))),
          ]),
        );
}

/// Confirmación sencilla (pedido hecho, dinero enviado...).
class Exito extends StatelessWidget {
  final String texto;
  const Exito(this.texto, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EFE5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          const Icon(Icons.check_circle_outline_rounded, color: Cafe.entra, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: const TextStyle(color: Color(0xFF2C4A33)))),
        ]),
      );
}

/// Contenedor blanco con borde fino: la "tarjeta" base de la app.
class Panel extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final Color? borde;
  const Panel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(18),
    this.borde = Cafe.borde,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: borde == null ? null : Border.all(color: borde!),
        ),
        child: child,
      );
}

/// Título de sección.
class Seccion extends StatelessWidget {
  final String texto;
  final Widget? accion;
  const Seccion(this.texto, {super.key, this.accion});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Row(children: [
          Expanded(
            child: Text(texto,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Cafe.espresso)),
          ),
          if (accion != null) accion!,
        ]),
      );
}

/// Cuadrito con ícono (para servicios, tiendas, movimientos).
class Icono extends StatelessWidget {
  final IconData icono;
  final Color fondo;
  final Color color;
  final double tamano;
  const Icono(this.icono, {super.key, this.fondo = Cafe.latte, this.color = Cafe.principal, this.tamano = 44});
  @override
  Widget build(BuildContext context) => Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(tamano * 0.3)),
        child: Icon(icono, color: color, size: tamano * 0.5),
      );
}

/// Inicial de una persona en un círculo.
class Inicial extends StatelessWidget {
  final String nombre;
  final double radio;
  const Inicial(this.nombre, {super.key, this.radio = 22});
  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: radio,
        backgroundColor: Cafe.latte,
        child: Text(
          nombre.isEmpty ? '?' : nombre[0].toUpperCase(),
          style: TextStyle(color: Cafe.principal, fontWeight: FontWeight.w700, fontSize: radio * 0.8),
        ),
      );
}
