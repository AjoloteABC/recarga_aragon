import 'package:flutter/material.dart';
import 'package:unam_movil/services/authentication.dart';
import 'package:unam_movil/pages/google_sign_in_button.dart';

//Pagina Principal de la aplicacion para el inicio de sesion

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, //Color de fondo transparente
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('lib/images/fondo.jpg'), //Cambiar fondo de aplicación
              fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 10.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Image.asset(
                        'lib/images/fes.png',//Imagen pantalla principal
                        height: 300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Recarga Aragón',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error al inicializar Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return GoogleSignInButton();
                  }
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white!,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
