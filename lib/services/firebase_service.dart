// les diffrents services pour interagir avec Firebase, ajouter, recuperer, recuperer les favoris, switcher les favoris et deleter

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/garage_sale.dart';

class FirebaseService 
{
  final sales = FirebaseFirestore.instance.collection('garage_sales');

  Future<void> addSale(GarageSale sale) async 
  {
    await sales.add(sale.toMap());
  }

  Stream<List<GarageSale>> getSales(String userId) 
  {
    return sales.where('userId', isEqualTo: userId).snapshots().map((snapshot) 
    {
      return snapshot.docs.map((doc) 
      {
        return GarageSale.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  Stream<List<GarageSale>> getFavoriteSales(String userId) 
  {
    return sales.where('userId', isEqualTo: userId).where('isFavorite', isEqualTo: true).snapshots().map((snapshot) =>
            snapshot.docs.map((doc) => GarageSale.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> toggleFavorite(String id, bool value) async 
  {
    await sales.doc(id).update({'isFavorite': !value});
  }

  Future<void> deleteSale(String saleId) async 
  {
    await sales.doc(saleId).delete();
  }
}