import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import '../model/parcel.dart';
import 'dart:math';

class ParcelManagementPage extends StatefulWidget {
  const ParcelManagementPage({super.key});

  @override
  State<ParcelManagementPage> createState() => _ParcelManagementPageState();
}

class _ParcelManagementPageState extends State<ParcelManagementPage> {
  final _senderController = TextEditingController();
  final _recipientController = TextEditingController();
  final _statusController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Box<Parcel> parcelBox;

  @override
  void initState() {
    super.initState();
    parcelBox = Hive.box<Parcel>('parcels');
  }

  String _generateTrackingNumber() {
    var rand = Random();
    return 'PK${rand.nextInt(99999).toString().padLeft(5, '0')}';
  }

  void _addParcel() async {
    if (!_formKey.currentState!.validate()) return;

    final newParcel = Parcel(
      trackingNumber: _generateTrackingNumber(),
      sender: _senderController.text,
      recipient: _recipientController.text,
      status: _statusController.text,
      history: [],
    );

    await parcelBox.add(newParcel);

    setState(() {
      _senderController.clear();
      _recipientController.clear();
      _statusController.clear();
    });
  }

  void _deleteParcel(int index) async {
    await parcelBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Parcel Management')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _senderController,
                        decoration: const InputDecoration(labelText: 'Sender'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter sender' : null,
                      ),
                      TextFormField(
                        controller: _recipientController,
                        decoration:
                            const InputDecoration(labelText: 'Recipient'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter recipient' : null,
                      ),
                      TextFormField(
                        controller: _statusController,
                        decoration: const InputDecoration(labelText: 'Status'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter status' : null,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: _addParcel, child: const Text('Add Parcel'))
                    ],
                  )),
            ),
            Expanded(
  child: ValueListenableBuilder<Box<Parcel>>(
    valueListenable: parcelBox.listenable(),
    builder: (context, box, _) {
      if (box.isEmpty) {
        return const Center(child: Text("No parcels added yet."));
      }

      return ListView.builder(
        itemCount: box.length,
        itemBuilder: (context, index) {
          final parcel = box.getAt(index)!;

          return Card(
            child: ListTile(
              title: Text(parcel.trackingNumber),
              subtitle: Text(
                'From: ${parcel.sender} To: ${parcel.recipient}\nStatus: ${parcel.status}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteParcel(index),
              ),
            ),
          );
        },
      );  
    },
  ),
)
          ],
        ));
  }
}
