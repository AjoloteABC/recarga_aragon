import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:unam_movil/pages/my_no_nfc.dart';


class MyNFC extends StatefulWidget {
  const MyNFC({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => MyNFCState();
}

class MyNFCState extends State<MyNFC> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            title: Text('Consultar Saldo')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) {
              //Evalua si el dispositivo cuenta con NFC
              if (ss.data != true) {
                //Si el resultado es false, muestra una pantalla de carga por un segundo
                //Y manda a llamar la clase MyNoNFC
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyNoNFC()),
                  );
                });
                return Center(
                  // Mostrar un indicador de carga mientras se realiza la navegación
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue!,
                    ),
                  ),
                );
              } else {
                //Botón encargado de llamar al metodo para leer el tag _tagRead
                return ElevatedButton(
                    child: Text('Tag Read'), onPressed: _tagRead
                );
              }
            },
          ),
        ),
        ) );
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      NfcManager.instance.stopSession();
    });
  }
}
