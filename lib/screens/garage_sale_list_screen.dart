// Page principale en retrant du login

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/garage_sale.dart';
import 'add_garage_sale_screen.dart';
import 'favorite_garage_sale_screen.dart';

class GarageSaleListScreen extends StatefulWidget 
{
  const GarageSaleListScreen({super.key});

  @override
  State<GarageSaleListScreen> createState() => _GarageSaleListScreenState();
}

class _GarageSaleListScreenState extends State<GarageSaleListScreen> 
{
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) 
  {
    // Recupere le user quer connecter
    final user = FirebaseAuth.instance.currentUser;

    // Si quil est null pour whatever reason
    if (user == null) 
    {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté")),
      );
    }

    final uid = user.uid;

    return Scaffold
    (
      backgroundColor: Colors.transparent,

      appBar: AppBar
      (
        title: const Text(
          "Garage Sales",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true
      ),

      body: Stack
      (
        children: 
        [
          // Image de background 
          Container
          (
            decoration: const BoxDecoration
            (
              image: DecorationImage
              (
                image: AssetImage("images/garagesale.jpg"),
                fit: BoxFit.cover
              )
            )
          ),

          // Meme transparence
          Container(color: Colors.black.withValues(alpha: 128)),

          selectedIndex == 0 ? _buildAllSales(uid) : FavoriteGarageSaleScreen(userId: uid),
        ],
      ),

      // Bouton qui tapporte au add pour ajouter une garage sale
      floatingActionButton: FloatingActionButton
      (
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () 
        {
          Navigator.push
          (
            context,
            MaterialPageRoute(builder: (_) => const AddGarageSaleScreen())
          );
        }
      ),

      // Bar de navigation dans le bas pour naviguer entre la page normal et elle de favoris
      bottomNavigationBar: BottomNavigationBar
      (
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.black87,
        items: const 
        [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Ventes"
          ),
          BottomNavigationBarItem
          (
            icon: Icon(Icons.star),
            label: "Favoris"
          )
        ]
      )
    );
  }

  // Construire toute les sales dependant du user
  Widget _buildAllSales(String userId) 
  {
    return StreamBuilder<List<GarageSale>>
    (
      stream: FirebaseService().getSales(userId),
      builder: (context, snapshot)
      {
        // Si sa load
        if (snapshot.connectionState == ConnectionState.waiting) 
        {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        // Si il y a une erreure
        if (snapshot.hasError) 
        {
          return Center
          (
            child: Text
            (
              "Erreur : ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
            )
          );
        }

        // Si il y a rien
        if (!snapshot.hasData || snapshot.data!.isEmpty) 
        {
          return const Center
          (
            child: Text
            (
              "Aucune vente trouvée.",
              style: TextStyle(color: Colors.white),
            )
          );
        }

        final sales = snapshot.data!;

        return ListView.builder
        (
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: sales.length,
          itemBuilder: (context, i) 
          {
            return _saleCard(sales[i]);
          }
        );
      }
    );
  }

  // La card pour la garage sale
  Widget _saleCard(GarageSale sale) 
  {
    // Pour le supprimer en le poussant par la droite
    return Dismissible
    (
      key: Key(sale.id),
      direction: DismissDirection.startToEnd,
      background: Container
      (
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async // Pour confirmer la suppression
      {
        return await showDialog
        (
          context: context,
          builder: (_) => AlertDialog
          (
            title: const Text("Supprimer"),
            content: const Text("Voulez-vous vraiment supprimer cette vente?"),
            actions: 
            [
              TextButton
              (
                child: const Text("Annuler"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton
              (
                child: const Text("Supprimer"),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ]
          )
        );
      },
      onDismissed: (_) async 
      {
        await FirebaseService().deleteSale(sale.id);

        ScaffoldMessenger.of(context).showSnackBar
        (
          const SnackBar
          (
            content: Text("Vente supprimée"),
            backgroundColor: Colors.red,
          )
        );
      },

      // La actual carte
      child: Card
      (
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Row
        (
          children: 
          [
            Padding
            (
              padding: const EdgeInsets.all(6),
              child: ClipRRect
              (
                borderRadius: BorderRadius.circular(14),
                child: Image.asset
                (
                  sale.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover
                )
              )
            ),

            // Les infos
            Expanded
            (
              child: Padding
              (
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column
                (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text
                    (
                      sale.title,
                      style: const TextStyle
                      (
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      )
                    ),

                    const SizedBox(height: 6),

                    Row
                    (
                      children: 
                      [
                        const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Expanded
                        (
                          child: Text
                          (
                            "${sale.address}, ${sale.city}",
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis
                          )
                        )
                      ]
                    ),

                    const SizedBox(height: 4),

                    Row
                    (
                      children: 
                      [
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 4),
                        Text(sale.date, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time, size: 14),
                        const SizedBox(width: 4),
                        Text("${sale.startTime} - ${sale.endTime}",
                            style: const TextStyle(fontSize: 12))
                      ]
                    ),

                    const SizedBox(height: 4),

                    Row
                    (
                      children: 
                      [
                        const Icon(Icons.category, size: 14),
                        const SizedBox(width: 4),
                        Text(sale.category, style: const TextStyle(fontSize: 12)),

                        if (sale.isVeryPopular) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                          const Text
                          (
                            " Très populaire",
                            style: TextStyle
                            (
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold
                            )
                          )
                        ]
                      ]
                    )
                  ]
                )
              )
            ),

            // Letoile
            IconButton
            (
              icon: Icon
              (
                sale.isFavorite ? Icons.star : Icons.star_border,
                color: sale.isFavorite ? Colors.yellow[700] : Colors.grey
              ),
              onPressed: () async 
              {
                await FirebaseService().toggleFavorite(sale.id, sale.isFavorite);

                ScaffoldMessenger.of(context).showSnackBar
                (
                  SnackBar
                  (
                    content: Text
                    (
                      sale.isFavorite ? "Retiré des favoris" : "Ajouté aux favoris"
                    ),
                    duration: const Duration(seconds: 1)
                  )
                );
              }
            )
          ]
        )
      )
    );
  }
}