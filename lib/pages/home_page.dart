import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uangkoo_fwz/models/database.dart';
import 'package:uangkoo_fwz/models/transaction_with_category.dart';
import 'package:uangkoo_fwz/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase database = AppDatabase();
  late double totalIncome =
      0.0; // Inisialisasi totalIncome dengan nilai awal 0.0
  late double totalExpense =
      0.0; // Inisialisasi totalExpense dengan nilai awal 0.0

  @override
  void initState() {
    super.initState();
    // Menginisialisasi nilai totalIncome dan totalExpense
    totalIncome = 0.0;
    totalExpense = 0.0;
    calculateTotalIncomeAndExpense(widget.selectedDate);
  }

  void calculateTotalIncomeAndExpense(DateTime selectedDate) async {
    // Menghitung tanggal awal dan akhir bulan
    DateTime firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);
    DateTime lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);

    // Mengambil transaksi berdasarkan bulan yang dipilih
    List<TransactionWithCategory> transactions = await database
        .getTransactionByDateRangeRepo(firstDayOfMonth, lastDayOfMonth);

    double income = 0;
    double expense = 0;

    // Menghitung total income dan expense
    transactions.forEach((transaction) {
      if (transaction.category.type == 1) {
        income += transaction.transaction.amount.toDouble();
      } else {
        expense += transaction.transaction.amount.toDouble();
      }
    });

    setState(() {
      totalIncome = income;
      totalExpense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard total income dan expense
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Icon(
                            Icons.download,
                            color: Colors.green,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Income",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Rp. ${totalIncome.toStringAsFixed(2)}",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          child: Icon(
                            Icons.upload,
                            color: Colors.red,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expense",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Rp. ${totalExpense.toStringAsFixed(2)}",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // Text transaction
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Transactions",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // StreamBuilder untuk menampilkan daftar transaksi
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        await database.deleteTransactionRepo(
                                            snapshot
                                                .data![index].transaction.id);
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionPage(
                                              transactionWithCategory:
                                                  snapshot.data![index],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                title: Text(
                                  "Rp. ${snapshot.data![index].transaction.amount.toString()}",
                                ),
                                subtitle: Text(
                                  "${snapshot.data![index].category.name} (${snapshot.data![index].transaction.name})",
                                ),
                                leading: Container(
                                  child: (snapshot.data![index].category.type ==
                                          2)
                                      ? Icon(Icons.upload, color: Colors.red)
                                      : Icon(Icons.download,
                                          color: Colors.green),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text("Data transaksi masih kosong"),
                      );
                    }
                  } else {
                    return Center(
                      child: Text("Tidak ada data"),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
