// Page de login avec auth pour firebase

import 'package:test2_garagesale_kayleb/screens/garage_sale_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget 
{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> 
{
  // Controller pour le email et password entrer par lutilisateur
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Si sa load
  bool isLoading = false;

  @override
  void initState() 
  {
    super.initState();

    // Si lutilisateur est deja connecter -> skip login
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) 
    {
      Future.microtask(() 
      {
        Navigator.pushReplacement
        (
          context,
          MaterialPageRoute(builder: (_) => const GarageSaleListScreen())
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      body: Stack
      (
        children: 
        [
          // Image du background
          Container(
            decoration: const BoxDecoration
            (
              image: DecorationImage
              (
                image: AssetImage("images/garagesale.jpg"),
                fit: BoxFit.cover
              )
            )
          ),

          // Petit shade sur toute lecran
          Container(color: Colors.black.withValues(alpha: 128)),

          // Carte de login
          Center
          (
            child: Card
            (
              elevation: 10,
              color: Colors.white.withValues(alpha: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)
              ),
              child: Container
              (
                width: 330,
                padding: const EdgeInsets.all(20),
                child: Column
                (
                  mainAxisSize: MainAxisSize.min,
                  children: 
                  [
                    const Text(
                      "Connexion",
                      style: TextStyle
                      (
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple
                      )
                    ),

                    const SizedBox(height: 20),

                    // TextField pour le email
                    TextField
                    (
                      controller: emailController,
                      decoration: InputDecoration
                      (
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                      )
                    ),

                    const SizedBox(height: 16),

                    // TextField pour le password
                    TextField
                    (
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration
                      (
                        labelText: "Mot de passe",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                      )
                    ),

                    const SizedBox(height: 24),

                    // Le bouton pour se connecter avec le cercle si sa load pour longtemp asser
                    SizedBox
                    (
                      width: double.infinity,
                      child: ElevatedButton
                      (
                        style: ElevatedButton.styleFrom
                        (
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder
                          (
                            borderRadius: BorderRadius.circular(12)
                          )
                        ),
                        onPressed: isLoading ? null : _login,
                        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Se connecter")
                      )
                    )
                  ]
                )
              )
            )
          )
        ]
      )
    );
  }

  // Fonction pour loger in
  Future<void> _login() async 
  {
    // Variables pour les controller
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Verification si les champ son remplit
    if (email.isEmpty || password.isEmpty) 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar
        (
          content: Text("Veuillez remplir tous les champs."),
          backgroundColor: Colors.red
        )
      );
      return;
    }

    setState(() => isLoading = true);

    // Essayer la connexion avec firebase
    try 
    {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      // Si la connexion est reussi sa te push a la fenetre de list screen
      if (context.mounted) 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connexion réussie!"),
            backgroundColor: Colors.green
          )
        );

        Navigator.pushReplacement
        (
          context,
          MaterialPageRoute(builder: (_) => const GarageSaleListScreen())
        );
      }
    } on FirebaseAuthException catch (e) // Si sa marche pas tu tombe dans le catch de firebase
    {
      String message = "Erreur inconnue";

      if (e.code == "user-not-found") message = "Utilisateur introuvable";
      if (e.code == "wrong-password") message = "Mot de passe incorrect";
      if (e.code == "invalid-email") message = "Email invalide";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar
        (
          content: Text(message),
          backgroundColor: Colors.red,
        )
      );
    } catch (e) { // Erreur generale
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar
        (
          content: Text("Erreur : $e"),
          backgroundColor: Colors.red
        )
      );
    }

    if (mounted) setState(() => isLoading = false);
  }
}