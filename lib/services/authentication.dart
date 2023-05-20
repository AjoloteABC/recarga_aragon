import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unam_movil/pages/my_navigation_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unam_movil/services/global_variables.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unam_movil/pages/my_user_info.dart';

// Se encarga de hacer la autentificacion de la cuenta google con firebase

class Authentication {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      GlobalVariables.setUID(uid);
      String? name = user.displayName;
      GlobalVariables.setName(name!);
      String? email = user.email;
      GlobalVariables.setEmail(email!);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyNavigationBar(
            user: user,
          ),
        ),
      );
    }

    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    await googleSignIn.signOut();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
//Apartir de este if se encarga de ver si hay un inicio de sesion y si es con una
    // cuenta diferente a la de aragon
    if (googleSignInAccount != null) {
      final String email = googleSignInAccount.email;
      final String domain = email.split('@')[1];

      if (domain == 'aragon.unam.mx') {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;

          if (user != null) {
            String uid = user.uid;
            GlobalVariables.setUID(uid);
            String? name = user.displayName;
            GlobalVariables.setName(name!);
            String? email = user.email;
            GlobalVariables.setEmail(email!);


            // Verificar si es la primera vez que el usuario ingresa
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('usuarios_google')
                .doc(uid)
                .get();

            if (userDoc.exists) {
              // El usuario ya ha ingresado antes, redirigir a la clase deseada
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MyNavigationBar(user: user!,),
                ),
              );
            } else {
              // Es la primera vez que el usuario ingresa, crear un nuevo documento en la base de datos
              await FirebaseFirestore.instance
                  .collection('usuarios_google')
                  .doc(uid)
                  .set({
                'name': user.displayName,
                'email': user.email,
                // Agrega cualquier otra información que quieras guardar para el usuario
              });
              // Redirigir a una nueva clase
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MyInfo(user: user!,),
                ),
              );
            }


          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content: 'La cuenta ya existe',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'Ocurrió un error al acceder a las credenciales. Intentar otra vez.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content:
                  'Se produjo un error al utilizar el inicio de sesión de Google. Intentar otra vez.',
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content:
                'Debes iniciar sesión con una cuenta institucional válida.',
          ),
        );
      }
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error al cerrar sesión. Intentar otra vez.',
        ),
      );
    }
  }
}
