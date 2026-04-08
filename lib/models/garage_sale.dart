// model pour ma classe GarageSale, qui représente une vente de garage avec ses propriétés et méthodes de conversion pour Firestore.

class GarageSale {
  final String id;
  final String userId;

  final String title;
  final String sellerName;
  final String phone;

  final String address;
  final String city;

  final String date;
  final String startTime;
  final String endTime;

  final String category;
  final String description;
  final String specialNotes;
  final String notes;

  final bool isVeryPopular;
  final bool isFavorite;

  final String imageUrl;

  GarageSale({
    required this.id,
    required this.userId,
    required this.title,
    required this.sellerName,
    required this.phone,
    required this.address,
    required this.city,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.description,
    required this.specialNotes,
    required this.notes,
    required this.isVeryPopular,
    required this.isFavorite,
    required this.imageUrl,
  });

  // pour envoyer a firebase model map
  Map<String, dynamic> toMap() 
  {
    return 
    {
      'userId': userId,
      'title': title,
      'sellerName': sellerName,
      'phone': phone,
      'address': address,
      'city': city,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      'description': description,
      'specialNotes': specialNotes,
      'notes': notes,
      'isVeryPopular': isVeryPopular,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
    };
  }

  // pour creer une card de firebase
  static GarageSale fromMap(String id, Map<String, dynamic> map) 
  {
    return GarageSale
    (
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      sellerName: map['sellerName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      date: map['date'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      specialNotes: map['specialNotes'] ?? '',
      notes: map['notes'] ?? '',
      isVeryPopular: map['isVeryPopular'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      imageUrl: map['imageUrl'] ?? "images/garagesale.jpg",
    );
  }
}