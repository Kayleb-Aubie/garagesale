// page dajoutage avec toute les controller demander

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/garage_sale.dart';
import '../services/firebase_service.dart';

class AddGarageSaleScreen extends StatefulWidget 
{
  const AddGarageSaleScreen({super.key});

  @override
  State<AddGarageSaleScreen> createState() => _AddGarageSaleScreenState();
}

class _AddGarageSaleScreenState extends State<AddGarageSaleScreen> 
{
  final _formKey = GlobalKey<FormState>();

  // Controller pour les fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController specialNotesController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String? selectedCategory;
  bool isVeryPopular = false;
  bool addToFavoriteOnCreate = false;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) 
  {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) 
    {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté")),
      );
    }

    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text("Ajouter une vente"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      body: Container
      (
        decoration: const BoxDecoration
        (
          gradient: LinearGradient
          (
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding
        (
          padding: const EdgeInsets.all(16),
          child: Card
          (
            elevation: 6,
            shape: RoundedRectangleBorder
            (
              borderRadius: BorderRadius.circular(18)
            ),
            child: Padding
            (
              padding: const EdgeInsets.all(16),
              child: Form
              (
                key: _formKey,
                child: ListView
                (
                  children: 
                  [
                    _sectionTitle("Informations principales"),

                    _textField("Titre de la vente", titleController, icon: Icons.title),
                    _textField("Nom du vendeur", sellerNameController, icon: Icons.person),
                    _textField("Téléphone", phoneController, icon: Icons.phone),
                    _textField("Adresse", addressController, icon: Icons.location_on),
                    _textField("Ville", cityController, icon: Icons.location_city),

                    _sectionTitle("Date et heures"),

                    _dateField(),
                    _timeField("Heure de début", startTimeController, Icons.access_time),
                    _timeField("Heure de fin", endTimeController, Icons.access_time_filled),

                    _sectionTitle("Catégorie et détails"),

                    _categoryDropdown(),
                    _textField("Description détaillée", descriptionController, icon: Icons.description, maxLines: 3),
                    _textField("Prix spéciaux / remarques", specialNotesController, icon: Icons.sell),

                    _sectionTitle("Options"),

                    CheckboxListTile
                    (
                      title: const Text("Très populaire"),
                      value: isVeryPopular,
                      onChanged: (v) => setState(() => isVeryPopular = v ?? false)
                    ),

                    SwitchListTile
                    (
                      title: const Text("Ajouter aux favoris dès la création"),
                      value: addToFavoriteOnCreate,
                      onChanged: (v) => setState(() => addToFavoriteOnCreate = v)
                    ),

                    _textField("Notes", notesController, icon: Icons.note, maxLines: 2),

                    const SizedBox(height: 20),

                    ElevatedButton
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
                      onPressed: isLoading ? null : () => _saveSale(user.uid),
                      child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Ajouter la vente"),
                    )
                  ]
                )
              )
            )
          )
        )
      )
    );
  }

  // Save dans firebase
  Future<void> _saveSale(String userId) async 
  {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final sale = GarageSale(
      id: const Uuid().v4(),
      userId: userId,
      title: titleController.text.trim(),
      sellerName: sellerNameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      date: dateController.text.trim(),
      startTime: startTimeController.text.trim(),
      endTime: endTimeController.text.trim(),
      category: selectedCategory ?? "Autre",
      description: descriptionController.text.trim(),
      specialNotes: specialNotesController.text.trim(),
      notes: notesController.text.trim(),
      isVeryPopular: isVeryPopular,
      isFavorite: addToFavoriteOnCreate,
      imageUrl: "images/garagesale.jpg",
    );

    try 
    {
      await FirebaseService().addSale(sale);

      if (context.mounted) 
      {
        ScaffoldMessenger.of(context).showSnackBar
        (
          const SnackBar
          (
            content: Text("Vente ajoutée avec succès!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) 
    {
      if (context.mounted) 
      {
        ScaffoldMessenger.of(context).showSnackBar
        (
          SnackBar
          (
            content: Text("Erreur : $e"),
            backgroundColor: Colors.red
          )
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  // Widget pour faire un section header

  Widget _sectionTitle(String text) 
  {
    return Padding
    (
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text
      (
        text,
        style: const TextStyle
        (
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget pour les textfields
  Widget _textField(String label, TextEditingController controller, {IconData? icon, int maxLines = 1}) 
  {
    return Padding
    (
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField
      (
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration
        (
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder
          (
            borderRadius: BorderRadius.circular(12)
          )
        ),
        validator: (value) => value == null || value.isEmpty ? "Champ obligatoire" : null,
      )
    );
  }

  // Widget pour la date
  Widget _dateField() 
  {
    return Padding
    (
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField
      (
        controller: dateController,
        readOnly: true,
        decoration: InputDecoration
        (
          labelText: "Date",
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder
          (
            borderRadius: BorderRadius.circular(12)
          )
        ),
        validator: (value) => value == null || value.isEmpty ? "Champ obligatoire" : null,
        onTap: () async 
        {
          final picked = await showDatePicker
          (
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
          );
          if (picked != null) 
          {
            dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          }
        }
      )
    );
  }

  // Widget pour les temps
  Widget _timeField(String label, TextEditingController controller, IconData icon) 
  {
    return Padding
    (
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration
        (
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder
          (
            borderRadius: BorderRadius.circular(12)
          )
        ),
        validator: (value) => value == null || value.isEmpty ? "Champ obligatoire" : null,
        onTap: () async 
        {
          final picked = await showTimePicker
          (
            context: context,
            initialTime: TimeOfDay.now()
          );
          if (picked != null) 
          {
            controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
          }
        }
      )
    );
  }

  // Widget pour le dropdown de categorie
  Widget _categoryDropdown() 
  {
    return Padding
    (
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>
      (
        initialValue: selectedCategory,
        decoration: InputDecoration
        (
          labelText: "Catégorie",
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder
          (
            borderRadius: BorderRadius.circular(12),
          )
        ),
        items: const 
        [
          DropdownMenuItem(value: "Outils", child: Text("Outils")),
          DropdownMenuItem(value: "Vêtements", child: Text("Vêtements")),
          DropdownMenuItem(value: "Articles d’enfants", child: Text("Articles d’enfants")),
          DropdownMenuItem(value: "Électronique", child: Text("Électronique")),
        ],
        onChanged: (value) => setState(() => selectedCategory = value),
        validator: (value) => value == null ? "Sélectionnez une catégorie" : null
      )
    );
  }
}