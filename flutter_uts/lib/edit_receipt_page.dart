import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditReceiptModal extends StatefulWidget {
  final DocumentReference receiptRef;
  final Map<String, dynamic> receiptData;

  const EditReceiptModal({
    super.key,
    required this.receiptRef,
    required this.receiptData,
  });

  @override
  State<EditReceiptModal> createState() => _EditReceiptModalState();
}

class _EditReceiptModalState extends State<EditReceiptModal> {
  final _formKey = GlobalKey<FormState>();
  final _formNumberCtrl = TextEditingController();

  DocumentReference? _supplierRef;
  DocumentReference? _warehouseRef;
  List<DocumentSnapshot> _supplierList = [];
  List<DocumentSnapshot> _warehouseList = [];
  List<DocumentSnapshot> _productList = [];

  final List<_DetailItem> _detailItems = [];

  int get _itemCount => _detailItems.fold(0, (sum, item) => sum + item.qty);
  int get _totalCost => _detailItems.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void initState() {
    super.initState();
    _formNumberCtrl.text = widget.receiptData['no_form'] ?? '';
    _supplierRef = widget.receiptData['supplier_ref'];
    _warehouseRef = widget.receiptData['warehouse_ref'];
    _loadDropdownOptions();
  }

  Future<void> _loadDropdownOptions() async {
    final supplierSnap = await FirebaseFirestore.instance.collection('suppliers').get();
    final warehouseSnap = await FirebaseFirestore.instance.collection('warehouses').get();
    final productSnap = await FirebaseFirestore.instance.collection('products').get();
    final detailSnap = await widget.receiptRef.collection('details').get();

    setState(() {
      _supplierList = supplierSnap.docs;
      _warehouseList = warehouseSnap.docs;
      _productList = productSnap.docs;
      _detailItems.clear();
      for (var detailDoc in detailSnap.docs) {
        _detailItems.add(
          _DetailItem.fromMap(detailDoc.data(), _productList, detailDoc.reference),
        );
      }
    });
  }

  Future<void> _saveReceipt() async {
    if (!_formKey.currentState!.validate() ||
        _supplierRef == null ||
        _warehouseRef == null ||
        _detailItems.isEmpty) return;

    await widget.receiptRef.update({
      'no_form': _formNumberCtrl.text.trim(),
      'supplier_ref': _supplierRef,
      'warehouse_ref': _warehouseRef,
      'item_total': _itemCount,
      'grandtotal': _totalCost,
      'updated_at': DateTime.now(),
    });

    final detailRef = widget.receiptRef.collection('details');
    final existing = await detailRef.get();

    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    for (var item in _detailItems) {
      await detailRef.add(item.toMap());
    }

    if (mounted) Navigator.pop(context, 'updated');
  }

  void _addDetailRow() {
    setState(() => _detailItems.add(_DetailItem(products: _productList)));
  }

  void _deleteDetailRow(int index) {
    setState(() => _detailItems.removeAt(index));
  }

  Future<void> _deleteReceipt() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus receipt ini? Semua detail akan ikut terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final detailColl = widget.receiptRef.collection('details');
    final docs = await detailColl.get();
    for (var doc in docs.docs) {
      await doc.reference.delete();
    }

    await widget.receiptRef.delete();

    await FirebaseFirestore.instance
        .collection('purchaseGoodsReceipts')
        .doc(widget.receiptRef.id)
        .delete();

    if (mounted) Navigator.pop(context, 'deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Receipt')),
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
                    DropdownButtonFormField<DocumentReference>(
                      value: _supplierRef,
                      decoration: const InputDecoration(labelText: 'Supplier'),
                      items: _supplierList.map((doc) {
                        return DropdownMenuItem(
                          value: doc.reference,
                          child: Text(doc['name']),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _supplierRef = val),
                      validator: (val) => val == null ? 'Pilih supplier' : null,
                    ),
                    DropdownButtonFormField<DocumentReference>(
                      value: _warehouseRef,
                      decoration: const InputDecoration(labelText: 'Warehouse'),
                      items: _warehouseList.map((doc) {
                        return DropdownMenuItem(
                          value: doc.reference,
                          child: Text(doc['name']),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _warehouseRef = val),
                      validator: (val) => val == null ? 'Pilih warehouse' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text('Detail Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._detailItems.asMap().entries.map((entry) {
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
                                items: _productList.map((doc) {
                                  return DropdownMenuItem(
                                    value: doc.reference,
                                    child: Text(doc['name']),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    item.productRef = val;
                                    item.unitName = val!.id == '1' ? 'pcs' : 'dus';
                                  });
                                },
                                validator: (val) => val == null ? 'Pilih produk' : null,
                              ),
                              TextFormField(
                                initialValue: item.price.toString(),
                                decoration: const InputDecoration(labelText: 'Harga'),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() => item.price = int.tryParse(val) ?? 0);
                                },
                                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                              ),
                              TextFormField(
                                initialValue: item.qty.toString(),
                                decoration: const InputDecoration(labelText: 'Jumlah'),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() => item.qty = int.tryParse(val) ?? 1);
                                },
                                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                              ),
                              const SizedBox(height: 8),
                              Text('Satuan: ${item.unitName}'),
                              Text('Subtotal: ${item.subtotal}'),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                onPressed: () => _deleteDetailRow(idx),
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                label: const Text('Hapus Produk'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    ElevatedButton.icon(
                      onPressed: _addDetailRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Produk'),
                    ),
                    const SizedBox(height: 16),
                    Text('Item Total: $_itemCount'),
                    Text('Grand Total: $_totalCost'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveReceipt,
                      child: const Text('Update Receipt'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _deleteReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Hapus Receipt'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DetailItem {
  DocumentReference? productRef;
  int price;
  int qty;
  String unitName;
  final List<DocumentSnapshot> products;
  final DocumentReference? docRef;

  _DetailItem({
    this.productRef,
    this.price = 0,
    this.qty = 1,
    this.unitName = 'unit',
    required this.products,
    this.docRef,
  });

  factory _DetailItem.fromMap(Map<String, dynamic> data, List<DocumentSnapshot> products, DocumentReference ref) {
    return _DetailItem(
      productRef: data['product_ref'],
      price: data['price'],
      qty: data['qty'],
      unitName: data['unit_name'] ?? 'unit',
      products: products,
      docRef: ref,
    );
  }

  int get subtotal => price * qty;

  Map<String, dynamic> toMap() {
    return {
      'product_ref': productRef,
      'price': price,
      'qty': qty,
      'unit_name': unitName,
      'subtotal': subtotal,
    };
  }
}
