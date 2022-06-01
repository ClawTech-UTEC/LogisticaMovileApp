import 'package:clawtech_logistica_app/models/cliente.dart';
import 'package:clawtech_logistica_app/models/pedidos.dart';
import 'package:clawtech_logistica_app/models/producto.dart';
import 'package:clawtech_logistica_app/models/tipo_producto.dart';
import 'package:clawtech_logistica_app/view_model/crear_pedido_viewmodel.dart';
import 'package:clawtech_logistica_app/views/screens/loading_screen.dart';
import 'package:clawtech_logistica_app/views/widgets/agrega_cliente_pedido_form.dart';
import 'package:clawtech_logistica_app/views/widgets/agregar_productos_pedido_form.dart';
import 'package:clawtech_logistica_app/views/widgets/finalizar_creacion_pedido.dart';
import 'package:clawtech_logistica_app/views/widgets/scafold_general_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CrearPedidoScreen extends StatefulWidget {
  CrearPedidoScreen({Key? key}) : super(key: key);

  @override
  State<CrearPedidoScreen> createState() => _CrearPedidoScreenState();
}

class _CrearPedidoScreenState extends State<CrearPedidoScreen> {
  final _formProductosKey = GlobalKey<FormState>();
  final _formClientesKey = GlobalKey<FormState>();

  CrearPedidoViewModel viewModel = CrearPedidoViewModel();
  TextEditingController _cantidadController = TextEditingController();
  int _index = 0;
  Cliente _cliente = Cliente();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    viewModel..add(CrearPedidoEventLoad());
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldGeneralBackground(
        title: "Crear Pedido",
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                child: BlocListener(
                    bloc: viewModel,
                    listener: (BuildContext context, CrearPedidoState state) {
                      if (state.status == CrearPedidoStateEnum.ERROR) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(context).accentColor,
                            content: Text('${state.error}'),
                          ),
                        );
                      }
                    },
                    child: BlocBuilder(
                        bloc: viewModel,
                        builder: (context, CrearPedidoState state) {
                          if (state.status == CrearPedidoStateEnum.INITIAL) {
                            return LoadingPage();
                          }

                          return Stepper(
                            controlsBuilder: (BuildContext context,
                                ControlsDetails details) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: details.onStepContinue,
                                    child: Text('Continuar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: details.onStepCancel,
                                    child: Text('Cancelar'),
                                  ),
                                ],
                              );
                            },

                            type: StepperType.horizontal,
                            margin: EdgeInsets.symmetric(horizontal: 0),
                            currentStep: _index,
                            onStepCancel: () {
                              if (_index > 0) {
                                setState(() {
                                  _index -= 1;
                                });
                              }
                            },
                            onStepContinue: () {
                              if (_index == 0) {
                                _formProductosKey.currentState!.reset();
                                setState(() {
                                  _index += 1;
                                });
                              }

                              if (_index == 1) {
                                if (_formClientesKey.currentState!.validate()) {
                                  _formClientesKey.currentState!.save();
                                  viewModel.add(
                                      CrearPedidoEventConfirmarCliente(
                                          cliente: _cliente));

                                  setState(() {
                                    _index += 1;
                                  });
                                }
                              }

                              if (_index == 2) {
                                viewModel
                                    .add(CrearPedidoEventConfirmarPedido());
                              }
                            },
                            // onStepTapped: (int index) {
                            //   print(index);
                            //   setState(() {
                            //     _index = index;
                            //   });
                            // },
                            steps: [
                              Step(
                                  title: _index == 0
                                      ? Text("Agregar Productos")
                                      : Container(),
                                  content: AgregarProdoctosPedidoForm(
                                      formKey: _formProductosKey,
                                      viewModel: viewModel,
                                      cantidadController: _cantidadController)),
                              Step(
                                  title: _index == 1
                                      ? Text("Agregar Cliente")
                                      : Container(),
                                  content: AgregarClientePedidoForm(
                                      viewModel: viewModel,
                                      formKey: _formClientesKey,
                                      cliente: _cliente)),
                              Step(
                                  title: _index == 2
                                      ? Text("Finalizar")
                                      : Container(),
                                  content: FinalizarCreacionPedido(
                                    viewModel: viewModel,
                                  )),
                            ],
                          );
                        })))));
  }
}