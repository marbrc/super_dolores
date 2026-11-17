import 'package:flutter/material.dart';

import '../../dominio/dinero.dart';
import '../../dominio/lealtad.dart';
import '../../dominio/plataforma.dart';
import '../tema.dart';
import '../vm/inicio_vm.dart';
import 'pantalla_horoscopo.dart';
import 'pantalla_metricas.dart';
import 'widgets.dart';

class PantallaInicio extends StatelessWidget {
  final InicioViewModel vm;
  const PantallaInicio({super.key, required this.vm});

  String _nombre() => vm.plataforma.perfiles.firstWhere((p) => p.id == vm.usuarioId).nombre;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 68,
          title: const Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Super Dolores'),
            Text('Todo tu día en una sola app',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Cafe.suave)),
          ]),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Cambiar de persona (demo)',
              onSelected: vm.cambiarUsuario,
              itemBuilder: (_) => [
                for (final p in vm.plataforma.perfiles) PopupMenuItem(value: p.id, child: Text(p.nombre)),
              ],
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ListenableBuilder(listenable: vm, builder: (_, __) => Inicial(_nombre(), radio: 19)),
              ),
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final s = vm.sugerencia;
            final puedeCanjear = vm.puntos >= Lealtad.puntosPorCanje;
            return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
              // ---------- Saldo ----------
              Panel(
                color: Cafe.espresso,
                borde: null,
                padding: const EdgeInsets.all(22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Hola, ${_nombre()}', style: const TextStyle(color: Color(0xFFD9C6B0), fontSize: 15)),
                  const SizedBox(height: 14),
                  const Text('Saldo disponible', style: TextStyle(color: Color(0xFFB9A48F), fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(formatearPesos(vm.saldo),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  const Text('Saldo de práctica: no es dinero real.',
                      style: TextStyle(color: Color(0xFFB9A48F), fontSize: 12)),
                ]),
              ),
              const SizedBox(height: 12),

              // ---------- Puntos ----------
              Panel(
                child: Row(children: [
                  const Icono(Icons.workspace_premium_outlined),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${vm.puntos} puntos · Nivel ${vm.nivel.nombre}',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Cafe.espresso)),
                      const SizedBox(height: 2),
                      Text(
                        'Racha: ${vm.racha} ${vm.racha == 1 ? "día" : "días"} · '
                        '${Lealtad.puntosPorCanje} pts = ${formatearPesos(Lealtad.centavosPorCanje)}',
                        style: const TextStyle(color: Cafe.suave, fontSize: 13),
                      ),
                    ]),
                  ),
                  TextButton(
                    onPressed: puedeCanjear
                        ? () {
                            final c = vm.canjearTodo();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Canjeaste ${formatearPesos(c)}')));
                          }
                        : null,
                    child: const Text('Canjear'),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // ---------- Sugerencia ----------
              Panel(
                color: Cafe.latte,
                borde: null,
                child: Row(children: [
                  Icono(iconoServicio(s.servicio), fondo: Colors.white),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Para ti', style: TextStyle(color: Cafe.suave, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(s.razon, style: const TextStyle(fontWeight: FontWeight.w600, color: Cafe.espresso)),
                    ]),
                  ),
                ]),
              ),

              // ---------- Servicios ----------
              const Seccion('Servicios'),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
                children: [
                  for (final a in vm.miniApps)
                    Column(children: [
                      Icono(iconoMiniApp(a.id), tamano: 54, fondo: Colors.white),
                      const SizedBox(height: 6),
                      Text(a.nombre,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Cafe.texto)),
                    ]),
                ],
              ),

              // ---------- Herramientas de la clase ----------
              const Seccion('Para la clase'),
              _Opcion(
                icono: Icons.query_stats_rounded,
                titulo: 'Tablero de retención',
                subtitulo: 'Métricas con datos simulados',
                alTocar: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaMetricas())),
              ),
              const SizedBox(height: 8),
              _Opcion(
                icono: Icons.shield_outlined,
                titulo: 'Mini-app de un tercero',
                subtitulo: 'Prueba que los permisos la frenan',
                alTocar: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PantallaHoroscopo(plataforma: vm.plataforma, usuarioId: vm.usuarioId))),
              ),
              const SizedBox(height: 8),
              if (vm.plataforma.registro.estaActiva(Plataforma.miniViajes.id))
                _Opcion(
                  icono: Icons.power_settings_new_rounded,
                  titulo: 'Simular falla: apagar Viajes',
                  subtitulo: 'Kill switch sin publicar otra versión',
                  alTocar: () {
                    vm.plataforma.registro.apagar(Plataforma.miniViajes.id);
                    vm.notificar();
                  },
                )
              else
                _Opcion(
                  icono: Icons.power_rounded,
                  titulo: 'Volver a encender Viajes',
                  subtitulo: 'El servicio regresa a la barra',
                  alTocar: () {
                    vm.plataforma.registro.encender(Plataforma.miniViajes.id);
                    vm.notificar();
                  },
                ),
            ]);
          },
        ),
      );
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback alTocar;
  const _Opcion({required this.icono, required this.titulo, required this.subtitulo, required this.alTocar});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: alTocar,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Cafe.borde),
            ),
            child: Row(children: [
              Icono(icono, tamano: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, color: Cafe.espresso)),
                  Text(subtitulo, style: const TextStyle(color: Cafe.suave, fontSize: 13)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: Cafe.suave),
            ]),
          ),
        ),
      );
}
