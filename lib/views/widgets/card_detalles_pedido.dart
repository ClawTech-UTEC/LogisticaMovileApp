import 'package:barcode_widget/barcode_widget.dart';
import 'package:clawtech_logistica_app/models/pedido_producto.dart';
import 'package:clawtech_logistica_app/models/pedidos.dart';
import 'package:clawtech_logistica_app/utils/confirmation_diolog.dart';
import 'package:clawtech_logistica_app/view_model/detalle_pedido_viewmodel.dart';
import 'package:clawtech_logistica_app/views/screens/controlar_pedido_screen.dart';
import 'package:clawtech_logistica_app/views/screens/dashboard.dart';
import 'package:clawtech_logistica_app/views/screens/despachar_pedido_screen.dart';
import 'package:clawtech_logistica_app/views/screens/entregar_pedido_screen.dart';
import 'package:clawtech_logistica_app/views/screens/preparar_pedido_screen.dart';
import 'package:clawtech_logistica_app/views/widgets/card_general.dart';
import 'package:clawtech_logistica_app/views/widgets/tabla_detalle_pedido.dart';
import 'package:flutter/material.dart';

class CardDetallePedido extends StatefulWidget {
  CardDetallePedido(
      {Key? key, required this.pedido, required this.detallePedidoViewModel})
      : super(key: key);
  Pedido pedido;
  DetallePedidoViewModel detallePedidoViewModel;
  @override
  State<CardDetallePedido> createState() => _CardDetallePedidoState();
}

class _CardDetallePedidoState extends State<CardDetallePedido> {
  @override
  Widget build(BuildContext context) {
    return CardGeneral(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedido: ${widget.pedido.idPedido}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              BarcodeWidget(
                height: 30,
                drawText: false,
                barcode: Barcode.code128(),
                data: '${widget.pedido.idPedido}',
              )
            ],
          ),
          Divider(
            thickness: 1,
          ),
          Text('Productos: ', style: Theme.of(context).textTheme.titleMedium),
          FittedBox(
              fit: BoxFit.fitWidth,
              child: TablaDetallePedido(pedido: widget.pedido)),
          Divider(
            thickness: 1,
          ),
          Text('Cliente: ${widget.pedido.cliente.nombre}',
              style: Theme.of(context).textTheme.titleMedium),
          FittedBox(
              fit: BoxFit.fitWidth,
              child: DataTable(
                headingTextStyle: Theme.of(context).textTheme.titleSmall,
                dataTextStyle: Theme.of(context).textTheme.bodySmall,
                columns: [
                  DataColumn(
                    label: Text("Fecha:"),
                  ),
                  DataColumn(label: Text("TOTAL:"))
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text('${widget.pedido.getFecha}')),
                    DataCell(Text('\$${widget.pedido.total}'))
                  ])
                ],
              )),
          botonesDetallePedido( widget.pedido, context, widget.detallePedidoViewModel),
        ],
      ),
    );
  }
}

Widget botonesDetallePedido(Pedido pedido, context, DetallePedidoViewModel  detallePedidoViewModel) {
  List<Widget> botones = [];

  botones.add(ElevatedButton(
    child: Text('Inicio'),
    onPressed: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DashboardPage())); // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => ControllarPedidoScreen(
      //               Pedido: widget.Pedido,
      //             )));
    },
  ));

  if (pedido.getEstadoActual.name == "PENDIENTE") {
    botones.add(ElevatedButton(
      child: Text('Preparar'),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PrepararPedidoScreen(
                      pedido: pedido,
                    )));
      },
    ));
  }
  if (pedido.getEstadoActual.name == "PREPARADO") {
    botones.add(ElevatedButton(
      child: Text('Controlar'),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ControlarPedidoScreen(
                      pedido: pedido,
                    )));
      },
    ));
  }
  if (pedido.getEstadoActual.name == "CONTROLADO") {
    botones.add(ElevatedButton(
      child: Text('Despachar'),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DespacharPedidoScren(
                      pedido: pedido,
                    )));
      },
    ));
  }
  if (pedido.getEstadoActual.name == "DESPACHADO") {
    botones.add(ElevatedButton(
      child: Text('Entregar'),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EntregarPedidoScren(pedido: pedido)));
      },
    ));
  }
  if (pedido.getEstadoActual.name != "CANCELADO") {
    botones.add(ElevatedButton(
       
      child: Text('Cancelar'),
      onPressed: () {
        confirmarcionDiolog(
            context: context,
            title: '¿Confirmar Cancelar el Pedido?',
            onConfirm: () {
              detallePedidoViewModel.cancelarPedido(pedido);

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashboardPage()));
            });
      },
    ));
  }
  if (pedido.getEstadoActual.name == "ENTREGADO") {
    botones.add(ElevatedButton(
      child: Text('Devolver'),
     onPressed: () {
        confirmarcionDiolog(
            context: context,
            title: '¿Confirmar Devolver el Pedido?',
            onConfirm: () async {
              await detallePedidoViewModel.devolverPedido(pedido);

              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashboardPage()));
            });
      },
    ));
  }
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: botones);
}
