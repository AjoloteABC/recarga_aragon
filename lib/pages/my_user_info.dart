import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unam_movil/services/global_variables.dart';
import 'package:unam_movil/pages/my_navigation_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:unam_movil/pages/my_user_info_no_nfc.dart';
import 'package:unam_movil/services/shared_preferences.dart';

class MyInfo extends StatefulWidget {
  const MyInfo({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  State<MyInfo> createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  String selectedCarrera = '';
  String? nfc;
  int _counter = 0;
  String botton = "Escanear tarjeta";
  bool tarjetaLeida = true;

  List carreras = [
    'Ing.Civil',
    'Ing.Computación',
    'Ing. Industrial',
    'Ing. Eléctrica Electrónica',
    'Ing. Mecánica',
    'Economía',
    'Derecho',
    'Sociología',
    'Relaciones Internacionales',
    'PDA',
    'Comunicación y Periodismo',
    'Arquitectura',
    'Diseño Industrial',
    'Pedagogía'
  ];

  final TextEditingController cuentaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  void enviarFormulario() {
    String nombreDocumento = cuentaController.text;
    MySharedPreferences.saveString('cuenta', nombreDocumento);

    String carrera = selectedCarrera;
    String globalUid = GlobalVariables.getUID();
    String globalName = GlobalVariables.getName();
    String globalEmail = GlobalVariables.getEmail();
    GlobalVariables.setCuenta(nombreDocumento);


    // Verificar si el documento ya existe en Firestore
    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(nombreDocumento)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // El documento ya existe, realizar alguna acción si es necesario
        print('El documento ya existe en Firestore');

        // Mostrar un mensaje al usuario indicando que el documento ya existe
      } else {
        // El documento no existe, guardar los valores en Firestore
        FirebaseFirestore.instance
            .collection('usuarios')
            .doc(nombreDocumento)
            .set({
          'nombre': globalName,
          'NFC': nfc,
          'carrera': carrera,
          'UID_usuario': globalUid,
          'correo': globalEmail,
        }).then((_) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Éxito'),
                content: Text('El formulario se envió correctamente.'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyNavigationBar(user: widget._user),
                        ),
                      );
                    },
                    child: Text('Aceptar'),
                  ),
                ],
              );
            },
          );
          // Éxito al enviar el formulario
          print('Formulario enviado correctamente');

          // Realizar cualquier acción adicional después de enviar el formulario
        }).catchError((error) {
          // Error al enviar el formulario
          print('Error al enviar el formulario: $error');

          // Mostrar un mensaje de error al usuario si es necesario
        });
      }
    }).catchError((error) {
      // Error al verificar la existencia del documento
      print('Error al verificar la existencia del documento: $error');

      // Mostrar un mensaje de error al usuario si es necesario
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Text('Actualizar Datos'),
      ),
      body: PageView(
        children: [
          Form(
            key: _formKey,
            child: FutureBuilder<bool>(
              future: NfcManager.instance.isAvailable(),
              builder: (context, ss) {
                // Evalua si el dispositivo cuenta con NFC
                if (ss.data == false) {
                  // Si el resultado es false, muestra una pantalla de carga por un segundo
                  // Y manda a llamar la clase MyNoNFC
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MyInfoNFC(user: widget._user)),
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
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.fromLTRB(60, 60, 60, 25),
                          width: 600,
                          child: TextFormField(
                            controller: cuentaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              focusColor: Colors.red,
                              icon: IconTheme(
                                data: IconThemeData(
                                  color: Colors.black, // Cambia el color aquí
                                ),
                                child: Icon(Icons.person),
                              ),
                              labelText: 'N° Cuenta',
                              labelStyle: TextStyle(
                                color: Colors.black, // Cambia el color aquí
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(70)),
                                borderSide: BorderSide(
                                  color: Colors.black, // Cambia el color aquí
                                ),
                              ),
                              hintText: 'Ingresa tu n° de cuenta',
                              hintStyle: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Campo obligatorio';
                              } else if (value.length != 9) {
                                return 'El número de cuenta debe tener 9 dígitos';
                              }
                              return null; // La validación es exitosa
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(60, 30, 41, 30),
                          width: 600,
                          child: DropdownButtonFormField(
                            items: carreras.map((name) {
                              return DropdownMenuItem(
                                child: Text(name),
                                value: name,
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCarrera = value.toString();
                              });
                            },
                            validator: (value) {},
                            decoration: const InputDecoration(
                              focusColor: Colors.red,
                              icon: IconTheme(
                                data: IconThemeData(
                                  color: Colors.black, // Cambia el color aquí
                                ),
                                child: Icon(Icons.school),
                              ),
                              labelText: 'Carrera',
                              labelStyle: TextStyle(
                                color: Colors.black, // Cambia el color aquí
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(75)),
                                borderSide: BorderSide(
                                  color: Colors.black, // Cambia el color aquí
                                ),
                              ),
                              hintText: 'Ingresa tu carrera',
                              hintStyle: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(60, 20, 60, 50),
                          width: 600,
                          child: ElevatedButton(
                            onPressed:
                            tarjetaLeida ?   () {
                              _tagRead();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Escanear Tarjeta'),
                                    content: Text(
                                      'Coloca tu tarjeta en el sensor NFC $nfc',
                                    ),
                                    actions: [

                                    ],
                                  );
                                },
                              );
                            } :null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Cambia este color por el que desees
                              padding: EdgeInsets.all(15), // Cambia el valor para ajustar el tamaño del botón
                              textStyle: TextStyle(
                                  fontSize: 20), // Cambia el valor para ajustar el tamaño del texto
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    10), // Cambia el valor para ajustar el radio de los bordes
                              ),
                            ),
                            child: Text('$botton'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              enviarFormulario();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Cambia este color por el que desees
                            padding: EdgeInsets.all(
                                18), // Cambia el valor para ajustar el tamaño del botón
                            textStyle: TextStyle(
                                fontSize:
                                20), // Cambia el valor para ajustar el tamaño del texto
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  10), // Cambia el valor para ajustar el radio de los bordes
                            ),
                          ),
                          child: const Text('Actualizar Informacion'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }


  void _tagRead() {
    nfc = "";
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      final Map<String, dynamic>? data = tag.data?.cast<String, dynamic>();
      if (data != null && data.containsKey('nfca')) {
        final Map<String, dynamic>? nfcaData =
            data['nfca']?.cast<String, dynamic>();
        if (nfcaData != null && nfcaData.containsKey('identifier')) {
          final List<int>? identifier = nfcaData['identifier']?.cast<int>();
          if (identifier != null) {
            //final hexResult = identifier.map((number) => number.toRadixString(16)).join('');
            List<String> hexResult = identifier
                .map((decimal) => '${decimal.toRadixString(16)}')
                .toList();
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
            _uploadResultToDatabase(nfc!, _counter);
            setState(() {
              tarjetaLeida = false; // Se ha leído una tarjeta NFC
              Navigator.of(context).pop();
              botton = "TARJETA ESCANEADA";
            });
          }
        }
      }
      NfcManager.instance.stopSession();
    });
  }

  void _uploadResultToDatabase(String result, int counter) {
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

    databaseRef.update({
      result: counter,
    }).then((value) {
      // Subida exitosa
      print('Resultado subido a la base de datos');
    }).catchError((error) {
      // Error al subir
      print('Error al subir el resultado: $error');
    });
  }
}
