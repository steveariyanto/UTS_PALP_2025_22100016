import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'add_receipt_page.dart';
import 'add_store_page.dart';
import 'edit_receipt_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "UTS PALP 2025 - Steve Ariyanto",
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Utama')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigate(context, const ReceiptListPage()),
              child: const Text('Lihat Daftar Receipt'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _navigate(context, const ReceiptDetailsPage()),
              child: const Text('Lihat Detail Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptListPage extends StatefulWidget {
  const ReceiptListPage({super.key});

  @override
  State<ReceiptListPage> createState() => _ReceiptListPageState();
}

class _ReceiptListPageState extends State<ReceiptListPage> {
  DocumentReference? _storeRef;
  List<DocumentSnapshot> _allReceipts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchReceipts();
  }

  Future<void> _fetchReceipts() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('store_ref');

    if (path == null || path.isEmpty) return;

    final storeRef = FirebaseFirestore.instance.doc(path);
    final snapshot = await FirebaseFirestore.instance
        .collection('purchaseGoodsReceipts')
        .where('store_ref', isEqualTo: storeRef)
        .get();

    setState(() {
      _storeRef = storeRef;
      _allReceipts = snapshot.docs;
      _loading = false;
    });
  }

  Future<void> _navigateAndRefresh(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _fetchReceipts();
  }

  Widget _buildReceiptCard(DocumentSnapshot document) {
    final data = document.data()! as Map<String, dynamic>;

    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => EditReceiptModal(
            receiptRef: document.reference,
            receiptData: data,
          ),
        );
        if (result == 'deleted' || result == 'updated') {
          await _fetchReceipts();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("No. Form: ${data['no_form']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Post Date: ${data['post_date']}"),
              Text("Grand Total: ${data['grandtotal']}"),
              Text("Item Total: ${data['item_total']}"),
              Text("Store: ${data['store_ref'].path}"),
              Text("Supplier: ${data['supplier_ref'].path}"),
              Text("Warehouse: ${data['warehouse_ref'].path}"),
              Text("Synced: ${data['synced'] ? 'Yes' : 'No'}"),
              Text("Created At: ${data['created_at'].toDate()}"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt List')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allReceipts.isEmpty
              ? const Center(child: Text('Tidak ada produk.'))
              : ListView(children: _allReceipts.map(_buildReceiptCard).toList()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => _navigateAndRefresh(const AddStorePage()),
            child: const Text('Tambah Nama Toko'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _navigateAndRefresh(const AddReceiptPage()),
            child: const Text('Tambah Receipt'),
          ),
        ],
      ),
    );
  }
}

class ReceiptDetailsPage extends StatefulWidget {
  const ReceiptDetailsPage({super.key});

  @override
  State<ReceiptDetailsPage> createState() => _ReceiptDetailsPageState();
}

class _ReceiptDetailsPageState extends State<ReceiptDetailsPage> {
  List<DocumentSnapshot> _allDetails = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final storePath = prefs.getString('store_ref');
    if (storePath == null || storePath.isEmpty) return;

    final storeRef = FirebaseFirestore.instance.doc(storePath);
    final receipts = await FirebaseFirestore.instance
        .collection('purchaseGoodsReceipts')
        .where('store_ref', isEqualTo: storeRef)
        .get();

    List<DocumentSnapshot> details = [];
    for (var receipt in receipts.docs) {
      final snapshot = await receipt.reference.collection('details').get();
      details.addAll(snapshot.docs);
    }

    setState(() {
      _allDetails = details;
      _loading = false;
    });
  }

  Widget _buildDetailCard(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Product Ref: ${data['product_ref'].path}"),
            Text("Qty: ${data['qty']}"),
            Text("Unit: ${data['unit_name']}"),
            Text("Price: ${data['price']}"),
            Text("Subtotal: ${data['subtotal']}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allDetails.isEmpty
              ? const Center(child: Text('Tidak ada detail produk.'))
              : ListView(children: _allDetails.map(_buildDetailCard).toList()),
    );
  }
}
