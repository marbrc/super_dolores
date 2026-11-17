import 'package:flutter/material.dart';

import '../../dominio/contexto.dart';
import '../../dominio/dinero.dart';
import '../../dominio/monedero.dart';
import '../../dominio/plataforma.dart';
import '../tema.dart';
import '../vm/monedero_vm.dart';
import 'widgets.dart';

class PantallaMonedero extends StatefulWidget {
  final ContextoMiniApp contexto;
  final VoidCallback alCambiar;
  final Plataforma plataforma;
  const PantallaMonedero({super.key, required this.contexto, required this.alCambiar, required this.plataforma});
  @override
  State<PantallaMonedero> createState() => _EstadoPantalla();
}

class _EstadoPantalla extends State<PantallaMonedero> {
  late final MonederoViewModel vm = MonederoViewModel(widget.contexto, alCambiar: widget.alCambiar);
  final _monto = TextEditingController(text: '100');
  String? _para;

  @override
  void dispose() {
    _monto.dispose();
    vm.dispose();
    super.dispose();
  }

  String _tipo(TipoMovimiento t) => switch (t) {
        TipoMovimiento.deposito => 'Recarga',
        TipoMovimiento.pago => 'Pago',
        TipoMovimiento.transferenciaEnviada => 'Enviado',
        TipoMovimiento.transferenciaRecibida => 'Recibido',
        TipoMovimiento.reembolso => 'Reembolso',
      };

  @override
  Widget build(BuildContext context) {
    final otros = widget.plataforma.perfiles.where((p) => p.id != widget.contexto.usuarioId).toList();
    _para ??= otros.first.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Monedero')),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
          Panel(
            color: Cafe.espresso,
            borde: null,
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Saldo', style: TextStyle(color: Color(0xFFB9A48F), fontSize: 13)),
              const SizedBox(height: 4),
              Text(formatearPesos(vm.saldo),
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Saldo de práctica. En producción exige una entidad financiera autorizada.',
                  style: TextStyle(color: Color(0xFFB9A48F), fontSize: 12)),
            ]),
          ),
          const Seccion('Enviar dinero'),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Para', style: TextStyle(color: Cafe.suave, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final p in otros)
                  ChoiceChip(
                    label: Text(p.nombre),
                    selected: _para == p.id,
                    showCheckmark: false,
                    selectedColor: Cafe.principal,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Cafe.borde),
                    labelStyle: TextStyle(color: _para == p.id ? Colors.white : Cafe.texto),
                    onSelected: (_) => setState(() => _para = p.id),
                  ),
              ]),
              const SizedBox(height: 14),
              TextField(
                controller: _monto,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(prefixText: '\$ ', hintText: 'Monto en pesos'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: vm.ocupado
                      ? null
                      : () {
                          final pesos = int.tryParse(_monto.text.trim()) ?? 0;
                          vm.enviarDinero(_para!, pesos * 100);
                        },
                  child: const Text('Enviar'),
                ),
              ),
              Aviso(vm.error),
              if (vm.exito != null) Exito(vm.exito!),
            ]),
          ),
          const Seccion('Movimientos'),
          if (vm.movimientos.isEmpty)
            const Panel(child: Text('Aún no hay movimientos.', style: TextStyle(color: Cafe.suave)))
          else
            Panel(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (var i = 0; i < vm.movimientos.length; i++) ...[
                  if (i > 0) const Divider(indent: 70),
                  _FilaMovimiento(mov: vm.movimientos[i], tipo: _tipo(vm.movimientos[i].tipo)),
                ],
              ]),
            ),
        ]),
      ),
    );
  }
}

class _FilaMovimiento extends StatelessWidget {
  final Movimiento mov;
  final String tipo;
  const _FilaMovimiento({required this.mov, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final entra = mov.montoCentavos >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icono(entra ? Icons.south_west_rounded : Icons.north_east_rounded,
            tamano: 40,
            fondo: entra ? const Color(0xFFE5EFE5) : const Color(0xFFF6E1DC),
            color: entra ? Cafe.entra : Cafe.sale),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mov.concepto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Cafe.espresso)),
            Text(tipo, style: const TextStyle(color: Cafe.suave, fontSize: 13)),
          ]),
        ),
        Text(
          '${entra ? '+' : ''}${formatearPesos(mov.montoCentavos)}',
          style: TextStyle(fontWeight: FontWeight.w700, color: entra ? Cafe.entra : Cafe.sale),
        ),
      ]),
    );
  }
}
