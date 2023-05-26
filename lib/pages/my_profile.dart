import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unam_movil/services/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  Map<String, dynamic> userData = {};
  String _cuenta = '';
  //String nfc = nfcController.text.toLowerCase();

  @override
  void initState() {
    super.initState();
    _loadCuenta();

  }
  Future<void> _loadCuenta() async {
    String? cuenta = await MySharedPreferences.getString('cuenta', '');
    setState(() {
      _cuenta = cuenta!;
      print(_cuenta);
      recibirFormulario();

    });
  }

  void recibirFormulario() {
    // Verificar si el documento ya existe en Firestore
    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_cuenta)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // El documento ya existe, realizar alguna acción si es necesario
        setState(() {
          // Actualizar el estado con los datos obtenidos del documento
          userData = snapshot.data() as Map<String, dynamic>;
        });

        // Mostrar un mensaje al usuario indicando que el documento ya existe
      } else {
        print('El documento no existe');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Text('Mi Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 40, 0, 0),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Image.asset(
                'lib/images/fes.png', //Imagen pantalla principal
                height: 300,
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Nombre: ${userData['nombre'] ?? ''}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Correo: ${userData['correo'] ?? ''}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Carrera: ${userData['carrera'] ?? ''}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'NFC: ${userData['NFC'].toString().toUpperCase() ?? ''}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
