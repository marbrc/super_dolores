import 'package:flutter/material.dart';

import '../../dominio/contexto.dart';
import '../../dominio/dinero.dart';
import '../../dominio/transporte.dart';
import '../tema.dart';
import '../vm/viajes_vm.dart';
import 'widgets.dart';

class PantallaViajes extends StatefulWidget {
  final ContextoMiniApp contexto;
  final VoidCallback alCambiar;
  const PantallaViajes({super.key, required this.contexto, required this.alCambiar});
  @override
  State<PantallaViajes> createState() => _EstadoPantalla();
}

class _EstadoPantalla extends State<PantallaViajes> {
  late final ViajesViewModel vm = ViajesViewModel(widget.contexto, alCambiar: widget.alCambiar);

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  String _estado(EstadoViaje e) => switch (e) {
        EstadoViaje.solicitado => 'Buscando conductor',
        EstadoViaje.aceptado => 'Conductor en camino',
        EstadoViaje.enCurso => 'En viaje',
        EstadoViaje.finalizado => 'Finalizado',
        EstadoViaje.cancelado => 'Cancelado',
      };

  Widget _selector(IconData icono, String etiqueta, Lugar valor, void Function(Lugar) alElegir) => Row(children: [
        Icon(icono, size: 20, color: Cafe.principal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(etiqueta, style: const TextStyle(color: Cafe.suave, fontSize: 12)),
            DropdownButton<Lugar>(
              value: valor,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Cafe.espresso),
              items: [for (final l in lugaresDolores) DropdownMenuItem(value: l, child: Text(l.nombre))],
              onChanged: (l) {
                if (l != null) alElegir(l);
              },
            ),
          ]),
        ),
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Viajes')),
        body: ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final v = vm.actual;
            final activo = v != null && v.estado != EstadoViaje.finalizado && v.estado != EstadoViaje.cancelado;
            return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
              Panel(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(children: [
                  _selector(Icons.trip_origin_rounded, 'Origen', vm.origen, (l) => vm.elegir(nuevoOrigen: l)),
                  const Divider(indent: 32),
                  _selector(Icons.place_outlined, 'Destino', vm.destino, (l) => vm.elegir(nuevoDestino: l)),
                ]),
              ),
              const SizedBox(height: 12),
              Panel(
                color: Cafe.latte,
                borde: null,
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Distancia', style: TextStyle(color: Cafe.suave, fontSize: 12)),
                      Text('${vm.distancia.toStringAsFixed(1)} km',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Cafe.espresso)),
                    ]),
                  ),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Tarifa estimada', style: TextStyle(color: Cafe.suave, fontSize: 12)),
                      Text(formatearPesos(vm.estimado),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Cafe.espresso)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              if (!activo)
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.local_taxi_outlined),
                    onPressed: vm.solicitar,
                    label: const Text('Pedir viaje'),
                  ),
                ),
              Aviso(vm.error),
              if (v != null) ...[
                const Seccion('Viaje actual'),
                Panel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icono(Icons.local_taxi_outlined, tamano: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_estado(v.estado),
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Cafe.espresso)),
                          Text(v.cobradoCentavos != null
                              ? 'Cobrado: ${formatearPesos(v.cobradoCentavos!)}'
                              : 'Estimado: ${formatearPesos(v.estimadoCentavos)}',
                              style: const TextStyle(color: Cafe.suave, fontSize: 13)),
                        ]),
                      ),
                    ]),
                    if (activo) ...[
                      const SizedBox(height: 14),
                      const Text('Simulación del conductor',
                          style: TextStyle(color: Cafe.suave, fontSize: 12)),
                      const SizedBox(height: 6),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        if (v.estado == EstadoViaje.solicitado)
                          OutlinedButton(onPressed: vm.conductorAcepta, child: const Text('Conductor acepta')),
                        if (v.estado == EstadoViaje.aceptado)
                          OutlinedButton(onPressed: vm.iniciar, child: const Text('Iniciar viaje')),
                        if (v.estado == EstadoViaje.enCurso)
                          FilledButton(onPressed: vm.finalizar, child: const Text('Llegar y pagar')),
                        if (v.estado == EstadoViaje.solicitado || v.estado == EstadoViaje.aceptado)
                          TextButton(onPressed: vm.cancelar, child: const Text('Cancelar')),
                      ]),
                    ],
                  ]),
                ),
              ],
              if (vm.historial.isNotEmpty) ...[
                const Seccion('Historial'),
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    for (var i = 0; i < vm.historial.length; i++) ...[
                      if (i > 0) const Divider(indent: 16),
                      ListTile(
                        dense: true,
                        title: Text('Viaje ${vm.historial[i].id}',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Cafe.espresso)),
                        subtitle: Text(_estado(vm.historial[i].estado)),
                        trailing: vm.historial[i].cobradoCentavos == null
                            ? null
                            : Text(formatearPesos(vm.historial[i].cobradoCentavos!),
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ]),
                ),
              ],
            ]);
          },
        ),
      );
}
