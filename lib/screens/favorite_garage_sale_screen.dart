// page des favoris

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/garage_sale.dart';

class FavoriteGarageSaleScreen extends StatefulWidget 
{
  final String userId;

  const FavoriteGarageSaleScreen({super.key, required this.userId});

  @override
  State<FavoriteGarageSaleScreen> createState() => _FavoriteGarageSaleScreenState();
}

class _FavoriteGarageSaleScreenState extends State<FavoriteGarageSaleScreen> 
{
  @override
  Widget build(BuildContext context) 
  {
    return Stack
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
              fit: BoxFit.cover,
            )
          )
        ),

        // transparence
        Container(color: Colors.black.withValues(alpha: 128)),

        // Recupere les favoris
        StreamBuilder<List<GarageSale>>
        (
          stream: FirebaseService().getFavoriteSales(widget.userId),
          builder: (context, snapshot) 
          {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) 
            {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            // Erreur
            if (snapshot.hasError) 
            {
              return Center(
                child: Text(
                  "Erreur : ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            // Si ses vide
            if (!snapshot.hasData || snapshot.data!.isEmpty) 
            {
              return const Center
              (
                child: Text
                (
                  "Aucun favori pour le moment.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final favorites = snapshot.data!;

            return ListView.builder
            (
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: favorites.length,
              itemBuilder: (context, i) {
                return _saleCard(favorites[i]);
              },
            );
          },
        ),
      ],
    );
  }

  // Encore la card (meme exact que le homescreen)
 Widget _saleCard(GarageSale sale) 
 {
    return Dismissible
    (
      key: Key(sale.id),
      direction: DismissDirection.startToEnd,
      background: Container
      (
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30)
      ),
      confirmDismiss: (direction) async 
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
                onPressed: () => Navigator.of(context).pop(false)
              ),
              TextButton
              (
                child: const Text("Supprimer"),
                onPressed: () => Navigator.of(context).pop(true)
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
            backgroundColor: Colors.red
          )
        );
      },

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

            Expanded
            (
              child: Padding
              (
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column
                (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: 
                  [
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