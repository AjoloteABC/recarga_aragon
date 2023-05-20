import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unam_movil/services/global_variables.dart';
import 'package:unam_movil/pages/my_navigation_bar.dart';

class MyInfo extends StatefulWidget {
  const MyInfo({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  State<MyInfo> createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  final TextEditingController cuentaController = TextEditingController();
  final TextEditingController nfcController = TextEditingController();
  final TextEditingController carreraController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  void enviarFormulario() {
    String nombreDocumento = cuentaController.text;
    String nfc = nfcController.text;
    String carrera = carreraController.text;
    String globalUid = GlobalVariables.getUID();
    String globalName = GlobalVariables.getName();
    String globalEmail = GlobalVariables.getEmail();

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
                          builder: (context) => MyNavigationBar(user: widget._user),
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
            title: Text('Actualizar Datos')),
        body: PageView(children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                          borderRadius: BorderRadius.all(Radius.circular(70)),
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
                    padding: const EdgeInsets.fromLTRB(60, 10, 60, 5),
                    width: 600,
                    child: TextFormField(
                      controller: nfcController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        focusColor: Colors.red,
                        icon: IconTheme(
                          data: IconThemeData(
                            color: Colors.black, // Cambia el color aquí
                          ),
                          child: Icon(Icons.nfc),
                        ),
                        labelText: 'NFC ID',
                        labelStyle: TextStyle(
                          color: Colors.black, // Cambia el color aquí
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(70)),
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
                        } else if (value.length != 8) {
                          return 'El valor debe tener 8 caracteres';
                        }
                        return null; // La validación es exitosa
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(60, 30, 60, 50),
                    width: 600,
                    child: TextFormField(
                      controller: carreraController,
                      keyboardType: TextInputType.name,
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
                          borderRadius: BorderRadius.all(Radius.circular(70)),
                          borderSide: BorderSide(
                            color: Colors.black, // Cambia el color aquí
                          ),
                        ),
                        hintText: 'Ingresa tu carrera',
                        hintStyle: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Campo obligatorio';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        enviarFormulario();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black, // Cambia este color por el que desees
                      padding: EdgeInsets.all(
                          18), // Cambia el valor para ajustar el tamaño del botón
                      textStyle: TextStyle(
                          fontSize:
                              20), // Cambia el valor para ajustar el tamaño del texto
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Cambia el valor para ajustar el radio de los bordes
                      ),
                    ),
                    child: const Text('Actualizar Informacion'),
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}
