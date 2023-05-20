import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unam_movil/services/global_variables.dart';

class MyNoNFC extends StatefulWidget {
  const MyNoNFC({Key? key}) : super(key: key);

  @override
  State<MyNoNFC> createState() => _MyNoNFCState();
}

class _MyNoNFCState extends State<MyNoNFC> {
  //Variable de saldo
  int _counter = 0;
  //Variable numero de cuenta
  String numeroCuenta = '';

  final _formKey = GlobalKey<FormState>();


  @override
  initState() {
    super.initState();
  }
  //Inicializamos la base de datos
  FirebaseFirestore db = FirebaseFirestore.instance;

  //Metodo para cargar o recibir datos de FireBase
  void _loadCounter() {
    //Manda a llamar la coleccion usuario y buscando el documento de acuerdo al
    //numero de cuenta almacenado en la variable
    db.collection("usuarios").doc(numeroCuenta).get().then((docSnapshot) {
      //Si el docomento existe obtine:
      if (docSnapshot.exists) {
        //El UID de Google de la BD
        String uidFirestore = docSnapshot.data()!['UID_usuario'];
        //El UID almacenado en el telefono
        String globalUid = GlobalVariables.getUID();
        print('UID almacenado globalmente: $globalUid');
        print('UID_almacenado en nube: $uidFirestore');

        //Si ambos ID son iguales, procede a obtener el valor de saldo de la BD
        // Y lo asigna a la variable saldo del telefono
        if (uidFirestore == globalUid) {
          int incremento = docSnapshot.data()!['saldo'];
          setState(() {
            _counter = incremento;
          });
        } else {
          //Si no es así pone el saldo en 0 y muestra un ShowDialog
          setState(() {
            _counter = 0;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('El numero de cuenta no coincide con el usuario actual'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Aceptar'),
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //Aqui va todo el Texform
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            title: Text('Consultar Saldo')),
        body: PageView(children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(60, 50, 60, 25),
                    width: 600,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        focusColor: Colors.red,
                        icon: IconTheme(
                          data: IconThemeData(
                            color: Colors.black, // Cambia el color aquí
                          ),
                          child: Icon(Icons.credit_card),
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
                      onChanged: (value) {
                        setState(() {
                          numeroCuenta = value;
                        });
                      },
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
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _loadCounter();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black, // Cambia este color por el que desees
                      padding: EdgeInsets.all(
                          16), // Cambia el valor para ajustar el tamaño del botón
                      textStyle: TextStyle(
                          fontSize:
                              20), // Cambia el valor para ajustar el tamaño del texto
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Cambia el valor para ajustar el radio de los bordes
                      ),
                    ),
                    child: const Text('Consultar'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
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
                  )
                ],
              ),
            ),
          ),
        ]));
  }
}
