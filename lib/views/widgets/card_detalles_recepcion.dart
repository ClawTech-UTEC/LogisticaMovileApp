import 'package:barcode_widget/barcode_widget.dart';
import 'package:clawtech_logistica_app/models/recepcion.dart';
import 'package:clawtech_logistica_app/models/recepcion_producto.dart';
import 'package:clawtech_logistica_app/utils/confirmation_diolog.dart';
import 'package:clawtech_logistica_app/view_model/detalle_pedido_viewmodel.dart';
import 'package:clawtech_logistica_app/view_model/detalle_recepcion_viewmodel.dart';
import 'package:clawtech_logistica_app/views/screens/controllar_recepcion_screen.dart';
import 'package:clawtech_logistica_app/views/screens/dashboard.dart';
import 'package:clawtech_logistica_app/views/screens/loading_screen.dart';
import 'package:clawtech_logistica_app/views/screens/ubicar_productos_screen.dart';
import 'package:clawtech_logistica_app/views/widgets/card_general.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardDetallesRecepcion extends StatefulWidget {
  CardDetallesRecepcion({Key? key, required this.recepcion}) : super(key: key);
  Recepcion recepcion;
  @override
  State<CardDetallesRecepcion> createState() => _CardDetallesRecepcionState();
}

class _CardDetallesRecepcionState extends State<CardDetallesRecepcion> {
  DetalleRecepcionViewModel viewModel = DetalleRecepcionViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.add(LoadRecepcionEvent(widget.recepcion));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: viewModel,
        builder: (context, DetalleRecepcionState state) {
          if (state.state == DetalleRecepcionStateEnum.loaded) {
            return CardGeneral(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recepcion: ${widget.recepcion.idRecepcion}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      BarcodeWidget(
                        height: 30,
                        drawText: false,
                        barcode: Barcode.code128(),
                        data: '${widget.recepcion.idRecepcion}',
                      )
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Text('Productos: ',
                      style: Theme.of(context).textTheme.titleMedium),
                  Center(
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: _createRecepctionProductsDataTable(
                            widget.recepcion.productos)),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Center(
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: DataTable(
                            horizontalMargin: 12,
                            columns: [
                              DataColumn(
                                label: Text("Fecha:"),
                              ),
                              DataColumn(
                                label: Text("Provedor:"),
                              ),
                              DataColumn(label: Text("TOTAL:"))
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Text('${widget.recepcion.getFecha}')),
                                DataCell(
                                  Text(
                                      '${widget.recepcion.provedor?.nombreProv}'),
                                ),
                                DataCell(Text('\$${widget.recepcion.total}'))
                              ])
                            ],
                          ))),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: botonesRecepcionProducto(viewModel,widget.recepcion, context )
            )]),
            );
          } else {
            return LoadingPage();
          }
        });
  }
}

Widget botonesRecepcionProducto(
    DetalleRecepcionViewModel viewModel, Recepcion recepcion, context) {
  List<Widget> botones = [];
  botones.add(Padding(
    padding: const EdgeInsets.all(8.0),
    child: ElevatedButton(
      child: Text('Inicio'),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ));

  if (recepcion.getEstadoActual.name == "PENDIENTE") {
    botones.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: Text('Controlar'),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ControllarRecepcionScreen(
                        recepcion: recepcion,
                      )));
        },
      ),
    ));
  }

  if (recepcion.getEstadoActual.name == "CANCELADO") {
    botones.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: Text('Inicio'),
         onPressed: () {
          confirmarcionDiolog(
              context: context,
              title: '¿Confirma cancelar la recepcion?',
              onConfirm: () {
                viewModel.add(CancelarRecepcionEvent());
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DashboardPage()));
              });
        },
      ),
    ));
  }

  return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: botones);
}

DataTable _createRecepctionProductsDataTable(
    List<RecepcionProducto> productos) {
  return DataTable(
      columns: _createRecepctionProductsColumns(),
      rows: _createRecepctionProductsRows(productos));
}

List<DataColumn> _createRecepctionProductsColumns() {
  return [
    DataColumn(label: Text('Producto')),
    DataColumn(label: Text('Cantidad')),
    DataColumn(label: Text('Precio'))
  ];
}

List<DataRow> _createRecepctionProductsRows(List<RecepcionProducto> productos) {
  return productos.map((producto) => _createRow(producto)).toList();
}

DataRow _createRow(RecepcionProducto producto) {
  return DataRow(cells: [
    DataCell(Text(producto.producto.nombre)),
    DataCell(Text('${producto.cantidad}')),
    DataCell(Text('\$${producto.producto.precio}'))
  ]);
}
