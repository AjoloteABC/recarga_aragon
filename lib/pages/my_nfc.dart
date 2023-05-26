import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unam_movil/services/global_variables.dart';
import 'package:unam_movil/pages/my_no_nfc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unam_movil/services/shared_preferences.dart';


class MyNFC extends StatefulWidget {
  const MyNFC({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyNFCState();
}

class MyNFCState extends State<MyNFC> {
  int _counter = 0;
  String numeroCuenta = GlobalVariables.getCuenta();
  String _cuenta = '';


  @override
  void initState() {
    super.initState();
    _tagRead();
  }

  FirebaseDatabase database = FirebaseDatabase.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  ValueNotifier<dynamic> result = ValueNotifier(null);
  String? nfc;

  Future<void> _loadCuenta() async {
    String? cuenta = await MySharedPreferences.getString('cuenta', '');
    setState(() {
      _cuenta = cuenta!;
    });
  }

  void _loadCounter() {
    // Manda a llamar la colección "usuarios" y busca el documento de acuerdo al
    // número de cuenta almacenado en la variable

    db.collection("usuarios").doc(_cuenta).get().then((docSnapshot) async {
      // Si el documento existe, obtiene los datos
      if (docSnapshot.exists) {
        String uidFirestore = docSnapshot.data()!['UID_usuario'];
        String nfc = docSnapshot.data()!['NFC'];
        print(nfc);
        String globalUid = GlobalVariables.getUID();
        print('UID almacenado globalmente: $globalUid');
        print('UID almacenado en la nube: $uidFirestore');

        // Si ambos IDs son iguales, procede a obtener el valor de saldo de la BD
        // y lo asigna a la variable _counter del teléfono
        if (uidFirestore == globalUid && nfc == result.value) {
          final ref = FirebaseDatabase.instance.ref();
          final snapshot = await ref.child(nfc).get();
          if (snapshot.exists) {
            print(snapshot.value);//Imprime el valor del saldo
            int incremento = int.parse(snapshot.value.toString());
            setState(() {
              _counter = incremento;
            });
          } else {
            print('No hay datos disponibles.');
          }
        } else {
          // Si no son iguales, pone el saldo en 0 y muestra un ShowDialog
          setState(() {
            _counter = 0;
            print('TARJETA INVALIDA');
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Tarjerta Invalida'),
                  content: Text(
                    'Tarjeta no vinculada a la cuenta $_cuenta',
                  ),
                  actions: [
                  ],
                );
              },
            );
          });
        }
      } else {
        // El documento no existe
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          title: Text('Consultar Saldo'),
        ),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) {
              if (ss.data == false) {
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyNoNFC()),
                  );
                });
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                );
              } else {
                return Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,30,0, 0),
                        child: Container(
                          child: Text('Ingresa tarjeta',style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                          ),),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(50, 120, 40, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Tu saldo es:',
                              style: TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '\$' + '$_counter',
                              style: const TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _tagRead() {
    _loadCuenta();
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      final Map<String, dynamic>? data = tag.data.cast<String, dynamic>();
      nfc = "";
      if (data != null && data.containsKey('nfca')) {
        final Map<String, dynamic>? nfcaData = data['nfca']?.cast<String, dynamic>();
        if (nfcaData != null && nfcaData.containsKey('identifier')) {
          final List<int>? identifier = nfcaData['identifier']?.cast<int>();
          if (identifier != null) {
            List<String> hexResult = identifier.map((decimal) => '${decimal.toRadixString(16)}').toList();
            for (int x = 0; x < hexResult.length; x++) {
              int value = int.parse(hexResult[x], radix: 16);
              if (value < 10) {
                String convert = '';
                convert = '0${value.toRadixString(16)}';
                hexResult[x] = convert;
              }

              if (nfc == null) {
                nfc = hexResult[x];
              } else {
                nfc = '$nfc ${hexResult[x]}';
              }
              nfc = nfc!.replaceAll(' ', '');
            }
            result.value = nfc;

            // Llama al método para cargar el contador
            _loadCounter();
          }
        }
      }
      NfcManager.instance.stopSession();
    });
  }
}
