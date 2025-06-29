import 'package:flutter/material.dart';
import 'api_keys.dart';
import 'model.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String token;

  CustomerDetailsPage({required this.token});

  @override
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  late Future<List<Customer>> customerList;
  late CustomerService customerService;
  Set<String> selectedCustomers = {};
  Map<String, bool> editingStates = {};
  Map<String, Map<String, TextEditingController>> controllers = {};

  @override
  void initState() {
    super.initState();
    customerService = CustomerService(token: widget.token);
    customerList = customerService.fetchCustomerData();
  }

  void toggleSelection(String cuscode) {
    setState(() {
      if (selectedCustomers.contains(cuscode)) {
        selectedCustomers.remove(cuscode);
      } else {
        selectedCustomers.add(cuscode);
      }
    });
  }

  void deleteSelectedCustomers() async {
    for (String cuscode in selectedCustomers) {
      await customerService.deleteCustomer(cuscode);
    }
    setState(() {
      selectedCustomers.clear();
      customerList = customerService.fetchCustomerData();
    });
  }

  void toggleEdit(String cuscode) {
    setState(() {
      editingStates[cuscode] = !(editingStates[cuscode] ?? false);
    });
  }

  void showAddCustomerDialog() {
    final controllers = {
      'cuscode': TextEditingController(),
      'cusname': TextEditingController(),
      'add1': TextEditingController(),
      'add2': TextEditingController(),
      'add3': TextEditingController(),
      'add4': TextEditingController(),
      'phone': TextEditingController(),
      'email': TextEditingController(),
      'homepage': TextEditingController(),
      'country': TextEditingController(),
      'status': TextEditingController(),
      'vatno': TextEditingController(),
    };

    final fieldDetails = {
      'cuscode': 10,
      'cusname': 70,
      'add1': 50,
      'add2': 50,
      'add3': 50,
      'add4': 50,
      'phone': 20,
      'email': 50,
      'homepage': 50,
      'country': 2,
      'status': 1,
      'vatno': 20,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            children: controllers.entries.map((entry) {
              return _buildTextField(
                  entry.key, entry.value, fieldDetails[entry.key]!);
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final Map<String, String> newCustomerData = {
                'cuscode': controllers['cuscode']!.text,
                'cusname': controllers['cusname']!.text,
                'add1': controllers['add1']!.text,
                'add2': controllers['add2']!.text,
                'add3': controllers['add3']!.text,
                'add4': controllers['add4']!.text,
                'phone': controllers['phone']!.text,
                'email': controllers['email']!.text,
                'web': controllers['homepage']!.text,
                'country': controllers['country']!.text,
                'status': controllers['status']!.text,
                'vatno': controllers['vatno']!.text,
              };

              await CustomerService(token: widget.token)
                  .addNewCustomer(newCustomerData);

              final updatedCustomers =
                  await CustomerService(token: widget.token)
                      .fetchCustomerData();

              setState(() {
                customerList =
                    Future.value(updatedCustomers); // ✅ Correct conversion
              });
              Navigator.pop(context);
            },
            child: Text('Submit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, int maxLength) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        maxLength: maxLength,
      ),
    );
  }

  Future<void> updateCustomerData(Customer customer,
      Map<String, Map<String, TextEditingController>> controllers) async {
    final updatedData = {
      'cusname': controllers[customer.cuscode]?['cusname']?.text ?? '',
      'add1': controllers[customer.cuscode]?['add1']?.text ?? '',
      'add2': controllers[customer.cuscode]?['add2']?.text ?? '',
      'add3': controllers[customer.cuscode]?['add3']?.text ?? '',
      'add4': controllers[customer.cuscode]?['add4']?.text ?? '',
      'phone': controllers[customer.cuscode]?['phone']?.text ?? '',
      'email': controllers[customer.cuscode]?['email']?.text ?? '',
      'web': controllers[customer.cuscode]?['web']?.text ?? '',
      'country': controllers[customer.cuscode]?['country']?.text ?? '',
      'status': controllers[customer.cuscode]?['status']?.text ?? '',
    };

    await customerService.updateCustomerData(customer, updatedData);

    setState(() {
      customerList = customerService.fetchCustomerData();
      editingStates[customer.cuscode] = false;
      selectedCustomers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCustomers.isEmpty
            ? 'Customer Details'
            : '${selectedCustomers.length} Selected'),
        actions: selectedCustomers.isNotEmpty
            ? [
                IconButton(
                  icon: Icon(editingStates[selectedCustomers.first] ?? false
                      ? Icons.check
                      : Icons.edit),
                  onPressed: () {
                    if (selectedCustomers.length == 1) {
                      final selectedCuscode = selectedCustomers.first;
                      if (editingStates[selectedCuscode] ?? false) {
                        customerList.then((customers) {
                          final customer = customers
                              .firstWhere((c) => c.cuscode == selectedCuscode);
                          updateCustomerData(customer, controllers).then((_) {
                            setState(() {
                              selectedCustomers
                                  .clear(); // ✅ Clear selection after saving
                              editingStates[selectedCuscode] =
                                  false; // ✅ Exit edit mode
                            });
                          });
                        });
                      } else {
                        toggleEdit(selectedCuscode);
                      }
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: deleteSelectedCustomers,
                ),
              ]
            : null,
      ),
      body: FutureBuilder<List<Customer>>(
        future: customerList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No customer details available.'));
          }

          final customers = snapshot.data!;
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              final isSelected = selectedCustomers.contains(customer.cuscode);
              final isEditing = editingStates[customer.cuscode] ?? false;

              controllers.putIfAbsent(
                customer.cuscode,
                () => {
                  'cusname': TextEditingController(text: customer.cusname),
                  'add1': TextEditingController(text: customer.add1),
                  'add2': TextEditingController(text: customer.add2),
                  'add3': TextEditingController(text: customer.add3),
                  'add4': TextEditingController(text: customer.add4),
                  'phone': TextEditingController(text: customer.phone),
                  'email': TextEditingController(text: customer.email),
                  'web': TextEditingController(text: customer.web),
                  'country': TextEditingController(text: customer.country),
                  'status': TextEditingController(text: customer.status),
                },
              );

              return GestureDetector(
                onLongPress: () => toggleSelection(customer.cuscode),
                onTap: selectedCustomers.isNotEmpty
                    ? () => toggleSelection(customer.cuscode)
                    : null,
                child: Card(
                  color: isSelected ? Colors.blue[50] : null,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isEditing)
                          Column(
                            children: controllers[customer.cuscode]!
                                .entries
                                .map((entry) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextField(
                                  controller: entry.value,
                                  decoration:
                                      InputDecoration(labelText: entry.key),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${customer.cuscode}\n${customer.cusname}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${customer.add1}, ${customer.add2}, ${customer.add3}, ${customer.add4}',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Divider(thickness: 1, height: 20),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 18),
                                  const SizedBox(width: 8),
                                  Text(customer.phone,
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.email, size: 18),
                                  const SizedBox(width: 8),
                                  Text(customer.email,
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.public, size: 18),
                                  const SizedBox(width: 8),
                                  Text(customer.web,
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCustomerDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
