import 'package:flutter/material.dart';

import '../tema.dart';
import '../vm/metricas_vm.dart';
import 'widgets.dart';

class PantallaMetricas extends StatefulWidget {
  const PantallaMetricas({super.key});
  @override
  State<PantallaMetricas> createState() => _EstadoPantalla();
}

class _EstadoPantalla extends State<PantallaMetricas> {
  late final MetricasViewModel vm = MetricasViewModel(DateTime(2026, 1, 1));

  String _pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final c = vm.comparacion;
    return Scaffold(
      appBar: AppBar(title: const Text('Tablero de retención')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
        const Panel(
          color: Cafe.latte,
          borde: null,
          padding: EdgeInsets.all(14),
          child: Text(
            'Datos SIMULADOS con semilla fija (200 usuarios inventados). Sirven para aprender a leer '
            'las métricas, no para sacar conclusiones reales.',
            style: TextStyle(color: Cafe.espresso, height: 1.35),
          ),
        ),
        const Seccion('Usuarios activos'),
        Row(children: [
          _Dato('DAU', '${vm.dau}', 'hoy'),
          const SizedBox(width: 10),
          _Dato('WAU', '${vm.wau}', '7 días'),
          const SizedBox(width: 10),
          _Dato('MAU', '${vm.mau}', '30 días'),
        ]),
        const Seccion('Retención'),
        Panel(
          padding: EdgeInsets.zero,
          child: Column(children: [
            _Fila('Stickiness (DAU/MAU)', _pct(vm.stickiness)),
            const Divider(indent: 16),
            _Fila('Retención D1 (promedio)', _pct(vm.retencionPromedio(1))),
            const Divider(indent: 16),
            _Fila('Retención D7 (promedio)', _pct(vm.retencionPromedio(7))),
            const Divider(indent: 16),
            _Fila('Servicios por usuario', vm.serviciosPorUsuario.toStringAsFixed(2)),
            const Divider(indent: 16),
            _Fila('Usuarios multiservicio', _pct(vm.multiservicio)),
          ]),
        ),
        const Seccion('Semana 2 según servicios de la semana 1'),
        Panel(
          padding: EdgeInsets.zero,
          child: Column(children: [
            _Fila('1 servicio (n=${c.nUno})', _pct(c.unServicio)),
            const Divider(indent: 16),
            _Fila('2 o más servicios (n=${c.nMulti})', _pct(c.multiservicio)),
          ]),
        ),
        const SizedBox(height: 14),
        const Text(
          'Cuidado: es una correlación. Quien está motivado prueba más servicios y además se queda más; '
          'no sabemos si usar más servicios CAUSA quedarse. Para saberlo hace falta un experimento '
          'controlado (prueba A/B).',
          style: TextStyle(fontStyle: FontStyle.italic, color: Cafe.suave, height: 1.4),
        ),
      ]),
    );
  }
}

class _Dato extends StatelessWidget {
  final String titulo;
  final String valor;
  final String detalle;
  const _Dato(this.titulo, this.valor, this.detalle);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Panel(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: const TextStyle(color: Cafe.suave, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Cafe.espresso)),
            Text(detalle, style: const TextStyle(color: Cafe.suave, fontSize: 12)),
          ]),
        ),
      );
}

class _Fila extends StatelessWidget {
  final String titulo;
  final String valor;
  const _Fila(this.titulo, this.valor);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Expanded(child: Text(titulo, style: const TextStyle(color: Cafe.texto))),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w700, color: Cafe.espresso)),
        ]),
      );
}
