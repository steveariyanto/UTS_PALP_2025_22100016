import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddStorePage extends StatefulWidget {
  const AddStorePage({super.key});

  @override
  State<AddStorePage> createState() => _AddStorePageState();
}

class _AddStorePageState extends State<AddStorePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final prefs = await SharedPreferences.getInstance();
    final enteredCode = _codeCtrl.text.trim();
    final enteredName = _nameCtrl.text.trim();

    final existing = await FirebaseFirestore.instance
        .collection('stores')
        .where('code', isEqualTo: enteredCode)
        .limit(1)
        .get();

    DocumentReference storeDoc;

    if (existing.docs.isNotEmpty) {
      storeDoc = existing.docs.first.reference;
    } else {
      final newEntry = await FirebaseFirestore.instance.collection('stores').add({
        'code': enteredCode,
        'name': enteredName,
      });
      storeDoc = newEntry;
    }

    await prefs.setString('code', enteredCode);
    await prefs.setString('name', enteredName);
    await prefs.setString('store_ref', storeDoc.path);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Toko')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Kode Toko'),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'NIM tidak boleh kosong'
                    : null,
              ),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Toko'),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Nama Toko tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Simpan Toko'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}