import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddReceiptPage extends StatefulWidget {
  const AddReceiptPage({super.key});

  @override
  State<AddReceiptPage> createState() => _AddReceiptPageState();
}

class _AddReceiptPageState extends State<AddReceiptPage> {
  final _formKey = GlobalKey<FormState>();
  final _formNumberCtrl = TextEditingController();

  DocumentReference? _supplierRef;
  DocumentReference? _warehouseRef;
  List<DocumentSnapshot> _supplierList = [];
  List<DocumentSnapshot> _warehouseList = [];
  List<DocumentSnapshot> _productList = [];

  final List<_ReceiptDetail> _details = [];

  int get _totalItems => _details.fold(0, (sum, item) => sum + item.qty);
  int get _totalAmount => _details.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final suppliers = await FirebaseFirestore.instance.collection('suppliers').get();
    final warehouses = await FirebaseFirestore.instance.collection('warehouses').get();
    final products = await FirebaseFirestore.instance.collection('products').get();

    setState(() {
      _supplierList = suppliers.docs;
      _warehouseList = warehouses.docs;
      _productList = products.docs;
    });
  }

  void _addProduct() {
    setState(() {
      _details.add(_ReceiptDetail(products: _productList));
    });
  }

  void _deleteProduct(int i) {
    setState(() => _details.removeAt(i));
  }

  Future<void> _submitReceipt() async {
    if (!_formKey.currentState!.validate() ||
        _supplierRef == null ||
        _warehouseRef == null ||
        _details.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final storePath = prefs.getString('store_ref');
    if (storePath == null) return;
    final storeRef = FirebaseFirestore.instance.doc(storePath);

    final header = {
      'no_form': _formNumberCtrl.text.trim(),
      'grandtotal': _totalAmount,
      'item_total': _totalItems,
      'post_date': DateTime.now().toIso8601String(),
      'created_at': DateTime.now(),
      'store_ref': storeRef,
      'supplier_ref': _supplierRef,
      'warehouse_ref': _warehouseRef,
      'synced': true,
    };

    final receiptRef = await FirebaseFirestore.instance
        .collection('purchaseGoodsReceipts')
        .add(header);

    for (final d in _details) {
      await receiptRef.collection('details').add(d.toMap());
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Receipt')),
      body: _productList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _formNumberCtrl,
                      decoration: const InputDecoration(labelText: 'No. Form'),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DocumentReference>(
                      value: _supplierRef,
                      decoration: const InputDecoration(labelText: 'Supplier'),
                      items: _supplierList.map((doc) => DropdownMenuItem(
                        value: doc.reference,
                        child: Text(doc['name']),
                      )).toList(),
                      onChanged: (val) => setState(() => _supplierRef = val),
                      validator: (val) => val == null ? 'Pilih supplier' : null,
                    ),
                    DropdownButtonFormField<DocumentReference>(
                      value: _warehouseRef,
                      decoration: const InputDecoration(labelText: 'Warehouse'),
                      items: _warehouseList.map((doc) => DropdownMenuItem(
                        value: doc.reference,
                        child: Text(doc['name']),
                      )).toList(),
                      onChanged: (val) => setState(() => _warehouseRef = val),
                      validator: (val) => val == null ? 'Pilih warehouse' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text('Detail Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._details.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              DropdownButtonFormField<DocumentReference>(
                                value: item.productRef,
                                decoration: const InputDecoration(labelText: 'Produk'),
                                items: _productList.map((doc) => DropdownMenuItem(
                                  value: doc.reference,
                                  child: Text(doc['name']),
                                )).toList(),
                                onChanged: (val) => setState(() {
                                  item.productRef = val;
                                  item.unitName = val!.id == '1' ? 'pcs' : 'dus';
                                }),
                                validator: (val) => val == null ? 'Pilih produk' : null,
                              ),
                              TextFormField(
                                initialValue: item.price.toString(),
                                decoration: const InputDecoration(labelText: 'Harga'),
                                keyboardType: TextInputType.number,
                                onChanged: (val) => setState(() {
                                  item.price = int.tryParse(val) ?? 0;
                                }),
                                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                              ),
                              TextFormField(
                                initialValue: item.qty.toString(),
                                decoration: const InputDecoration(labelText: 'Jumlah'),
                                keyboardType: TextInputType.number,
                                onChanged: (val) => setState(() {
                                  item.qty = int.tryParse(val) ?? 1;
                                }),
                                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                              ),
                              const SizedBox(height: 8),
                              Text('Satuan: ${item.unitName}'),
                              Text('Subtotal: ${item.subtotal}'),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                onPressed: () => _deleteProduct(idx),
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                label: const Text('Hapus Produk'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    ElevatedButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Produk'),
                    ),
                    const SizedBox(height: 16),
                    Text('Item Total: $_totalItems'),
                    Text('Grand Total: $_totalAmount'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitReceipt,
                      child: const Text('Simpan Receipt'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ReceiptDetail {
  DocumentReference? productRef;
  int price = 0;
  int qty = 1;
  String unitName = 'unit';
  final List<DocumentSnapshot> products;

  _ReceiptDetail({required this.products});

  int get subtotal => price * qty;

  Map<String, dynamic> toMap() => {
        'product_ref': productRef,
        'price': price,
        'qty': qty,
        'unit_name': unitName,
        'subtotal': subtotal,
      };
}