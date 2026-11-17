import 'package:flutter/material.dart';

import '../../dominio/comercio.dart';
import '../../dominio/contexto.dart';
import '../../dominio/dinero.dart';
import '../tema.dart';
import '../vm/tienda_vm.dart';
import 'widgets.dart';

class PantallaTienda extends StatefulWidget {
  final ContextoMiniApp contexto;
  final VoidCallback alCambiar;
  const PantallaTienda({super.key, required this.contexto, required this.alCambiar});
  @override
  State<PantallaTienda> createState() => _EstadoPantalla();
}

class _EstadoPantalla extends State<PantallaTienda> {
  late final TiendaViewModel vm = TiendaViewModel(widget.contexto, alCambiar: widget.alCambiar);

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final t = vm.tienda;
          return Scaffold(
            appBar: AppBar(
              title: Text(t == null ? 'Negocios de Dolores' : t.nombre),
              leading: t == null ? null : IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: vm.volver),
            ),
            body: t == null ? _negocios() : _productos(t),
          );
        },
      );

  Widget _negocios() => ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        const Text('Compra en negocios locales y paga con tu monedero.', style: TextStyle(color: Cafe.suave)),
        const SizedBox(height: 14),
        for (final x in vm.tiendas) ...[
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => vm.elegirTienda(x),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Cafe.borde),
                ),
                child: Row(children: [
                  Icono(iconoTienda(x.id), tamano: 50),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(x.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Cafe.espresso)),
                      Text('${x.productos.length} productos',
                          style: const TextStyle(color: Cafe.suave, fontSize: 13)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Cafe.suave),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ]);

  Widget _productos(Tienda t) => Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 16), children: [
            for (final p in t.productos) ...[
              Panel(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600, color: Cafe.espresso)),
                      const SizedBox(height: 2),
                      Text(formatearPesos(p.precioCentavos),
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Cafe.principal)),
                      Text('Quedan ${p.existencias}', style: const TextStyle(color: Cafe.suave, fontSize: 12)),
                    ]),
                  ),
                  _Contador(
                    cantidad: vm.carrito[p.id] ?? 0,
                    menos: () => vm.cambiar(p.id, -1),
                    mas: () => vm.cambiar(p.id, 1),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
            ],
            Aviso(vm.error),
            if (vm.ultimoPedido != null)
              Exito('Pedido ${vm.ultimoPedido!.id} confirmado · Total ${formatearPesos(vm.ultimoPedido!.totalCentavos)}'),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Cafe.borde)),
          ),
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total', style: TextStyle(color: Cafe.suave, fontSize: 13)),
                  Text(formatearPesos(vm.total),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Cafe.espresso)),
                ]),
              ),
              FilledButton(
                onPressed: vm.carrito.isEmpty || vm.ocupado ? null : vm.comprar,
                child: const Text('Pagar con monedero'),
              ),
            ]),
          ),
        ),
      ]);
}

class _Contador extends StatelessWidget {
  final int cantidad;
  final VoidCallback menos;
  final VoidCallback mas;
  const _Contador({required this.cantidad, required this.menos, required this.mas});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: Cafe.crema, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.remove_rounded, size: 18), onPressed: menos, color: Cafe.principal),
          SizedBox(
            width: 22,
            child: Text('$cantidad',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Cafe.espresso)),
          ),
          IconButton(icon: const Icon(Icons.add_rounded, size: 18), onPressed: mas, color: Cafe.principal),
        ]),
      );
}
