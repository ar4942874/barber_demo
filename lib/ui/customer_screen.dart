// import 'package:flutter/material.dart';
// import '../data/database_helper.dart';

// class CustomerScreen extends StatefulWidget {
//   const CustomerScreen({super.key});

//   @override
//   State<CustomerScreen> createState() => _CustomerScreenState();
// }

// class _CustomerScreenState extends State<CustomerScreen> {
//   final TextEditingController _controller = TextEditingController();
//   List<Map<String, dynamic>> customers = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCustomers();
//   }

//   Future<void> _loadCustomers() async {
//     final data = await DatabaseHelper.instance.getCustomers();
//     setState(() => customers = data);
//   }

//   Future<void> _addCustomer() async {
//     if (_controller.text.isEmpty) return;

//     await DatabaseHelper.instance.insertCustomer(_controller.text);
//     _controller.clear();
//     _loadCustomers();
//   }

//   Future<void> _deleteCustomer(int id) async {
//     await DatabaseHelper.instance.deleteCustomer(id);
//     _loadCustomers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('SQLite Windows Demo')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       labelText: 'Customer Name',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: _addCustomer,
//                   child: const Text('Add'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: customers.length,
//                 itemBuilder: (context, index) {
//                   final customer = customers[index];
//                   return Card(
//                     child: ListTile(
//                       title: Text(customer['name']),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.delete),
//                         onPressed: () => _deleteCustomer(customer['id']),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
