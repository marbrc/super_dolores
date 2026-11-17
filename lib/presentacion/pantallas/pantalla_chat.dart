import 'package:flutter/material.dart';

import '../../dominio/contexto.dart';
import '../../dominio/dinero.dart';
import '../../dominio/mensajeria.dart';
import '../../dominio/plataforma.dart';
import '../tema.dart';
import '../vm/chat_vm.dart';
import 'widgets.dart';

class PantallaChat extends StatefulWidget {
  final ContextoMiniApp contexto;
  final VoidCallback alCambiar;
  final Plataforma plataforma;
  const PantallaChat({super.key, required this.contexto, required this.alCambiar, required this.plataforma});
  @override
  State<PantallaChat> createState() => _EstadoPantalla();
}

class _EstadoPantalla extends State<PantallaChat> {
  late final ChatViewModel vm = ChatViewModel(widget.contexto, alCambiar: widget.alCambiar);
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    vm.dispose();
    super.dispose();
  }

  String _nombre(String id) {
    for (final p in widget.plataforma.perfiles) {
      if (p.id == id) return p.nombre;
    }
    return id == ServicioMensajes.sistema ? 'Super Dolores' : id;
  }

  void _enviar() {
    vm.enviar(_texto.text);
    if (vm.error == null) _texto.clear();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: vm,
        builder: (context, _) => vm.con == null ? _lista(context) : _conversacion(context),
      );

  Widget _lista(BuildContext context) {
    final yo = widget.contexto.usuarioId;
    final otros = widget.plataforma.perfiles.where((p) => p.id != yo).toList();
    final res = vm.resumenes;
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        const Text('Nuevo chat', style: TextStyle(color: Cafe.suave, fontSize: 13)),
        const SizedBox(height: 10),
        SizedBox(
          height: 86,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final p in otros)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => vm.abrir(p.id),
                  child: Column(children: [
                    Inicial(p.nombre, radio: 27),
                    const SizedBox(height: 6),
                    Text(p.nombre, style: const TextStyle(fontSize: 13, color: Cafe.texto)),
                  ]),
                ),
              ),
          ]),
        ),
        const Seccion('Conversaciones'),
        if (res.isEmpty)
          const Panel(
            child: Text('Todavía no tienes conversaciones. Elige a alguien arriba para empezar.',
                style: TextStyle(color: Cafe.suave)),
          )
        else
          Panel(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (var i = 0; i < res.length; i++) ...[
                if (i > 0) const Divider(indent: 72),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: res[i].con == ServicioMensajes.sistema
                      ? const Icono(Icons.notifications_none_rounded, tamano: 44)
                      : Inicial(_nombre(res[i].con)),
                  title: Text(_nombre(res[i].con),
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Cafe.espresso)),
                  subtitle: Text(res[i].ultimo.texto,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Cafe.suave)),
                  trailing: res[i].noLeidos > 0 ? Badge(label: Text('${res[i].noLeidos}')) : null,
                  onTap: () => vm.abrir(res[i].con),
                ),
              ],
            ]),
          ),
      ]),
    );
  }

  Widget _conversacion(BuildContext context) {
    final yo = widget.contexto.usuarioId;
    final esSistema = vm.con == ServicioMensajes.sistema;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: vm.cerrar),
        titleSpacing: 0,
        title: Row(children: [
          Inicial(_nombre(vm.con!), radio: 18),
          const SizedBox(width: 10),
          Text(_nombre(vm.con!)),
        ]),
        actions: [
          if (!esSistema)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                icon: const Icon(Icons.payments_outlined, size: 18),
                label: Text('Enviar ${formatearPesos(5000)}'),
                onPressed: () => vm.enviarDinero(5000),
              ),
            ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: [
            for (final m in vm.mensajes) _Burbuja(mensaje: m, mia: m.de == yo),
            Aviso(vm.error),
          ]),
        ),
        if (!esSistema)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Cafe.borde)),
            ),
            child: SafeArea(
              top: false,
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _texto,
                    maxLength: ServicioMensajes.maxCaracteres,
                    decoration: const InputDecoration(hintText: 'Mensaje', counterText: '', fillColor: Cafe.crema),
                    onSubmitted: (_) => _enviar(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(icon: const Icon(Icons.send_rounded), onPressed: _enviar),
              ]),
            ),
          ),
      ]),
    );
  }
}

class _Burbuja extends StatelessWidget {
  final Mensaje mensaje;
  final bool mia;
  const _Burbuja({required this.mensaje, required this.mia});

  @override
  Widget build(BuildContext context) {
    final dinero = mensaje.tipo == TipoMensaje.dinero;
    final sistema = mensaje.tipo == TipoMensaje.sistema;
    final fondo = dinero
        ? const Color(0xFFE5EFE5)
        : sistema
            ? Cafe.latte
            : (mia ? Cafe.principal : Colors.white);
    final colorTexto = (mia && !dinero && !sistema) ? Colors.white : Cafe.texto;
    return Align(
      alignment: mia ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: fondo,
          border: (!mia && !dinero && !sistema) ? Border.all(color: Cafe.borde) : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mia ? 18 : 4),
            bottomRight: Radius.circular(mia ? 4 : 18),
          ),
        ),
        child: dinero
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.payments_outlined, size: 18, color: Cafe.entra),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(mensaje.texto,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2C4A33))),
                ),
              ])
            : Text(mensaje.texto, style: TextStyle(color: colorTexto, fontSize: 15, height: 1.3)),
      ),
    );
  }
}
