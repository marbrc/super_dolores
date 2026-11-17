import 'package:flutter/material.dart';

import '../../dominio/excepciones.dart';
import '../../dominio/plataforma.dart';
import '../tema.dart';
import 'widgets.dart';

/// Mini-app de un TERCERO. Solo tiene el permiso "identidad". Intenta cosas que no debe y la
/// plataforma se lo impide: ese es el principio del menor privilegio en acción.
class PantallaHoroscopo extends StatefulWidget {
  final Plataforma plataforma;
  final String usuarioId;
  const PantallaHoroscopo({super.key, required this.plataforma, required this.usuarioId});
  @override
  State<PantallaHoroscopo> createState() => _EstadoPantalla();
}

class _EstadoPantalla extends State<PantallaHoroscopo> {
  String? resultado;
  bool bloqueado = true;

  void _intentar(String queQuiere, void Function() accion) {
    String texto;
    var seBloqueo = true;
    try {
      accion();
      texto = '¡Se permitió $queQuiere! (esto sería un fallo de seguridad)';
      seBloqueo = false;
    } catch (e) {
      texto = 'Bloqueado: $queQuiere → ${mensajeSeguro(e)}';
    }
    setState(() {
      resultado = texto;
      bloqueado = seBloqueo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctx = widget.plataforma.contextoPara(Plataforma.miniHoroscopo, widget.usuarioId);
    return Scaffold(
      appBar: AppBar(title: const Text('Horóscopo (tercero)')),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
        const Panel(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icono(Icons.nights_stay_outlined),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Hoy los astros dicen que tendrás un gran día. Mientras tanto, esta mini-app de un tercero '
                'intentará hacer cosas que no le corresponden. Solo tiene el permiso de "identidad".',
                style: TextStyle(color: Cafe.texto, height: 1.4),
              ),
            ),
          ]),
        ),
        const Seccion('Intentos indebidos'),
        _Boton('Intentar leer mi saldo', Icons.account_balance_wallet_outlined,
            () => _intentar('leer tu saldo', () => ctx.monedero.saldo())),
        const SizedBox(height: 8),
        _Boton('Intentar cobrarme', Icons.payments_outlined,
            () => _intentar('cobrarte', () => ctx.pagos.pagar(100, 'Premium', clave: 'x'))),
        const SizedBox(height: 8),
        _Boton('Intentar leer mis chats', Icons.chat_bubble_outline_rounded,
            () => _intentar('leer tus mensajes', () => ctx.mensajes.resumenes())),
        if (resultado != null)
          bloqueado ? Exito(resultado!) : Aviso(resultado),
      ]),
    );
  }
}

class _Boton extends StatelessWidget {
  final String texto;
  final IconData icono;
  final VoidCallback alTocar;
  const _Boton(this.texto, this.icono, this.alTocar);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
          icon: Icon(icono),
          label: Text(texto),
          onPressed: alTocar,
        ),
      );
}
