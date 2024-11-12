import 'package:flutter/material.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Add this model class for customers
class Customer {
  String id;
  String name;
  String address;
  String phone;
  String email;
  String status;

  Customer({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'status': status,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      status: json['status'],
    );
  }
}

class CustomerStorage {
  static const String _key = 'customers';

  // Save customers to local storage
  static Future<void> saveCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      customers.map((customer) => customer.toJson()).toList(),
    );
    await prefs.setString(_key, encodedData);
  }

  // Load customers from local storage
  static Future<List<Customer>> loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_key);

    if (encodedData == null) return [];

    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData
        .map((item) => Customer.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

// Modify the ManagerDashboard class
class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await CustomerStorage.loadCustomers();
    setState(() {
      _customers = customers;
    });
  }

  Future<void> _addCustomer(Customer customer) async {
    setState(() {
      _customers.add(customer);
    });
    await CustomerStorage.saveCustomers(_customers);
  }

  Future<void> _updateCustomer(Customer updatedCustomer) async {
    setState(() {
      final index = _customers.indexWhere((c) => c.id == updatedCustomer.id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }
    });
    await CustomerStorage.saveCustomers(_customers);
  }

  Future<void> _deleteCustomer(String customerId) async {
    setState(() {
      _customers.removeWhere((customer) => customer.id == customerId);
    });
    await CustomerStorage.saveCustomers(_customers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 35),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Manager',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Customers'),
              onTap: () {
                print('Calling Customers');
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerListPage(
                      customers: _customers,
                      onDelete: _deleteCustomer,
                      onUpdate: _updateCustomer,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Technicians'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            icon: Icons.business,
            title: 'Customers',
            subtitle: '${_customers.length} Active',
            color: Colors.blue,
            onTap: () {
              print('Called on tap');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerListPage(
                    customers: _customers,
                    onDelete: _deleteCustomer,
                    onUpdate: _updateCustomer,
                  ),
                ),
              );
            },
          ),
          _buildDashboardCard(
            icon: Icons.people,
            title: 'Technicians',
            subtitle: '5 Active',
            color: Colors.green,
            onTap: () {},
          ),
          _buildDashboardCard(
            icon: Icons.pending_actions,
            title: 'Pending Tasks',
            subtitle: '8 Tasks',
            color: Colors.orange,
            onTap: () {},
          ),
          _buildDashboardCard(
            icon: Icons.check_circle,
            title: 'Completed',
            subtitle: '24 Tasks',
            color: Colors.purple,
            onTap: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerFormPage(
                onSave: _addCustomer,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Add CustomerListPage
class CustomerListPage extends StatelessWidget {
  final List<Customer> customers;
  final Function(String) onDelete;
  final Function(Customer) onUpdate;

  const CustomerListPage({
    super.key,
    required this.customers,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.business),
              ),
              title: Text(customer.name),
              subtitle: Text(customer.email),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerFormPage(
                          customer: customer,
                          onSave: onUpdate,
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Customer'),
                        content: const Text(
                          'Are you sure you want to delete this customer?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              onDelete(customer.id);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CustomerDetailPage(customer: customer),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerFormPage(
                onSave: (Customer customer) {
                  // Handle save in a real app
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Add CustomerFormPage
class CustomerFormPage extends StatefulWidget {
  final Customer? customer;
  final Function(Customer) onSave;

  const CustomerFormPage({super.key, this.customer, required this.onSave});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _addressController =
        TextEditingController(text: widget.customer?.address ?? '');
    _phoneController =
        TextEditingController(text: widget.customer?.phone ?? '');
    _emailController =
        TextEditingController(text: widget.customer?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter company name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final customer = Customer(
                    id: widget.customer?.id ?? DateTime.now().toString(),
                    name: _nameController.text,
                    address: _addressController.text,
                    phone: _phoneController.text,
                    email: _emailController.text,
                    status: 'Active',
                  );
                  widget.onSave(customer);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                widget.customer == null ? 'Add Customer' : 'Save Changes',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add CustomerDetailPage
class CustomerDetailPage extends StatelessWidget {
  final Customer customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.business, size: 40),
            ),
            const SizedBox(height: 16),
            _buildDetailItem('Company Name', customer.name),
            _buildDetailItem('Address', customer.address),
            _buildDetailItem('Phone', customer.phone),
            _buildDetailItem('Email', customer.email),
            _buildDetailItem('Status', customer.status),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
