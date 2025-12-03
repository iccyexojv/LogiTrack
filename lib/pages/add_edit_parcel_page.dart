import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/parcel.dart';
import '../model/user.dart'; // Import User model to fetch customers
import 'dart:math';

class AddEditParcelPage extends StatefulWidget {
  final bool isEdit;
  final Parcel? parcel;

  const AddEditParcelPage({super.key, required this.isEdit, this.parcel});

  @override
  State<AddEditParcelPage> createState() => _AddEditParcelPageState();
}

class _AddEditParcelPageState extends State<AddEditParcelPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _senderCtrl;
  late TextEditingController _fromCtrl;
  late TextEditingController _toCtrl;
  late TextEditingController _hubCtrl;
  
  // State variables
  String? _selectedRecipient; // Changed from Controller to String for Dropdown
  String _status = 'Pending';
  String _token = '';
  List<String> _registeredCustomers = []; // To store valid users

  final List<String> _statuses = ['Pending', 'In Transit', 'Out for Delivery', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadCustomers();

    // Initialize Controllers
    _senderCtrl = TextEditingController(text: widget.parcel?.sender ?? 'LogiTrack Admin');
    _fromCtrl = TextEditingController(text: widget.parcel?.fromLocation ?? '');
    _toCtrl = TextEditingController(text: widget.parcel?.toLocation ?? '');
    _hubCtrl = TextEditingController();
    
    // Initialize Status and Token
    if (widget.isEdit && widget.parcel != null) {
      _status = widget.parcel!.status;
      _token = widget.parcel!.trackingNumber;
      _selectedRecipient = widget.parcel!.recipient;
    } else {
      _token = "TRK-${Random().nextInt(9000)+1000}-${Random().nextInt(9000)+1000}";
    }
  }

  // 1. Fetch only registered customers from Hive
  void _loadCustomers() {
    final userBox = Hive.box<User>('users');
    setState(() {
      _registeredCustomers = userBox.values
          .where((u) => u.role == 'customer')
          .map((u) => u.username)
          .toList();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate Recipient Selection
    if (_selectedRecipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a registered recipient")));
      return;
    }

    final box = Hive.box<Parcel>('parcels');

    if (widget.isEdit && widget.parcel != null) {
      // EDIT MODE
      widget.parcel!.sender = _senderCtrl.text;
      widget.parcel!.recipient = _selectedRecipient!; // Use dropdown value
      widget.parcel!.fromLocation = _fromCtrl.text;
      widget.parcel!.toLocation = _toCtrl.text;
      widget.parcel!.status = _status;
      
      if (_hubCtrl.text.isNotEmpty) {
        widget.parcel!.history.add(TrackingEvent(
          location: _hubCtrl.text, 
          description: "Arrived at Hub - Status: $_status", 
          timestamp: DateTime.now()
        ));
      }
      widget.parcel!.save();
    } else {
      // CREATE MODE
      final newParcel = Parcel(
        trackingNumber: _token,
        sender: _senderCtrl.text,
        recipient: _selectedRecipient!, // Use dropdown value
        status: _status,
        fromLocation: _fromCtrl.text,
        toLocation: _toCtrl.text,
        createdAt: DateTime.now(),
        history: [
           TrackingEvent(location: _fromCtrl.text, description: "Shipment Created", timestamp: DateTime.now())
        ],
        contactNumber: '', 
      );
      box.add(newParcel);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Update Parcel' : 'Create Parcel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Token Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    const Text("TRACKING TOKEN", style: TextStyle(fontSize: 10, letterSpacing: 1.2)),
                    Text(_token, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.deepPurple)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _senderCtrl, 
                decoration: const InputDecoration(labelText: 'Sender (Admin Name)'), 
                validator: (v)=>v!.isEmpty?'Required':null
              ),
              const SizedBox(height: 12),
              
              // 2. REPLACED Text Field with Dropdown for strict User connection
              DropdownButtonFormField<String>(
                value: _registeredCustomers.contains(_selectedRecipient) ? _selectedRecipient : null,
                decoration: const InputDecoration(
                  labelText: 'Recipient (Registered Customer)',
                  prefixIcon: Icon(Icons.person_search),
                ),
                items: _registeredCustomers.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRecipient = val),
                validator: (v) => v == null ? 'Select a customer' : null,
                hint: const Text("Select Customer"),
              ),
              if (_registeredCustomers.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 5, left: 10),
                  child: Text("No customers found. Create a customer account first.", style: TextStyle(color: Colors.red, fontSize: 12)),
                ),

              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(controller: _fromCtrl, decoration: const InputDecoration(labelText: 'Origin City'), validator: (v)=>v!.isEmpty?'Required':null)),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _toCtrl, decoration: const InputDecoration(labelText: 'Dest City'), validator: (v)=>v!.isEmpty?'Required':null)),
              ]),
              
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              
              DropdownButtonFormField(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val.toString()),
              ),
              
              if(widget.isEdit) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hubCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Current Location Update (Hub)', 
                    prefixIcon: Icon(Icons.add_location_alt),
                    helperText: "Enter new location to add to history map"
                  ),
                ),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), foregroundColor: Colors.white),
                  onPressed: _save,
                  child: Text(widget.isEdit ? "UPDATE" : "CREATE"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}