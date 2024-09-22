import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Invoice {
  final String invoice;
  final String paymentStatus;
  final String totalAmount;
  final String paymentMethod;

  Invoice({
    required this.invoice,
    required this.paymentStatus,
    required this.totalAmount,
    required this.paymentMethod,
  });
}

final List<Invoice> invoices = [
  Invoice(
    invoice: "INV001",
    paymentStatus: "Paid",
    totalAmount: r"$250.00",
    paymentMethod: "Credit Card",
  ),
  Invoice(
    invoice: "INV002",
    paymentStatus: "Pending",
    totalAmount: r"$150.00",
    paymentMethod: "PayPal",
  ),
  // ... Add the rest of the invoices here ...
];

void main() {
  runApp(const MaterialApp(home: ViewUserPage()));
}

class ViewUserPage extends StatefulWidget {
  const ViewUserPage({super.key});

  @override
  _ViewUserPageState createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Table')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 450,
          ),
          child: Table(
            border: TableBorder.all(),
            children: [
              const TableRow(
                children: [
                  TableCell(child: Text('Invoice')),
                  TableCell(child: Text('Status')),
                  TableCell(child: Text('Method')),
                  TableCell(child: Text('Amount')),
                ],
              ),
              ...invoices.map(
                (invoice) => TableRow(
                  children: [
                    TableCell(child: Text(invoice.invoice)),
                    TableCell(child: Text(invoice.paymentStatus)),
                    TableCell(child: Text(invoice.paymentMethod)),
                    TableCell(child: Text(invoice.totalAmount)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}