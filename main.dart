import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ParkItApp());
}

class ParkItApp extends StatelessWidget {
  const ParkItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkIt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> imgList = [
    'assets/images/image1.png',
    'assets/images/image2.png',
    'assets/images/image3.png',
  ];

  final int userCount = 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkIt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertPage()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'new_user') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewUserPage()),
                );
              } else if (result == 'alerts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlertPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'new_user',
                child: Text('New User'),
              ),
              const PopupMenuItem<String>(
                value: 'active_users',
                child: Text('Active Users'),
              ),
              const PopupMenuItem<String>(
                value: 'alerts',
                child: Text('Alerts'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 9 / 16,
                viewportFraction: 1.0,
                autoPlayInterval: const Duration(seconds: 3),
              ),
              items: imgList.map((item) => Image.asset(
                item,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )).toList(),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Users',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$userCount',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final List<Map<String, String>> _alerts = [
    {"time": "Today", "message": "Parking full in Zone A"},
    {"time": "Yesterday", "message": "Unauthorized vehicle detected"},
    {"time": "Last Week", "message": "New user registered"},
  ];

  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredAlerts = _selectedFilter == "All"
        ? _alerts
        : _alerts.where((alert) => alert["time"] == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedFilter,
              items: ["All", "Today", "Yesterday", "Last Week"]
                  .map((filter) => DropdownMenuItem(
                value: filter,
                child: Text(filter),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredAlerts.length,
              itemBuilder: (context, index) {
                final alert = filteredAlerts[index];
                return ListTile(
                  title: Text(alert["message"]!),
                  subtitle: Text(alert["time"]!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});

  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false; // To show/hide loading indicator

  void _saveUser() {
    String name = _nameController.text;
    String vehicleNumber = _vehicleController.text;
    String phone = _phoneController.text;
    String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Validation for empty fields
    if (name.isEmpty || vehicleNumber.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading indicator
    });

    // Saving user data to Firestore
    FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'vehicleNumber': vehicleNumber,
      'phone': phone,
      'dateTime': dateTime,
    }).then((_) {
      setState(() {
        _isLoading = false; // Stop loading indicator
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User added successfully!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      setState(() {
        _isLoading = false; // Stop loading indicator
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _vehicleController,
              decoration: const InputDecoration(labelText: 'Vehicle Number'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone, // Numeric input
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator() // Loading indicator
                : ElevatedButton(
              onPressed: _saveUser,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
