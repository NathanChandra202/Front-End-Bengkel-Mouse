import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StockItem {
  String id;
  String name;
  String category;
  int quantity;
  double price;

  StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }
}

class TransactionItem {
  String id;
  String customerName;
  DateTime date;
  String serviceType;
  double totalAmount;
  String status;
  String paymentProof;

  TransactionItem({
    required this.id,
    required this.customerName,
    required this.date,
    required this.serviceType,
    required this.totalAmount,
    required this.status,
    required this.paymentProof,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      customerName: json['user']['name'] ?? 'Unknown',
      date: DateTime.parse(json['createdAt']),
      serviceType: (json['categories'] as List).join(', '),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'],
      paymentProof: json['paymentProofUrl'] ?? '',
    );
  }
}

class AdminProvider extends ChangeNotifier {
  List<StockItem> _stocks = [];
  List<TransactionItem> _transactions = [];
  bool _isLoading = false;

  List<StockItem> get stocks => _stocks;
  List<TransactionItem> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> fetchStocks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getStocks();
      _stocks = data.map((e) => StockItem.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching stocks: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStock(String name, String category, int qty, double price) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiService.createStock({
        'name': name,
        'category': category,
        'quantity': qty,
        'price': price,
      });
      await fetchStocks();
    } catch (e) {
      debugPrint('Error adding stock: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStock(String id, String name, String category, int qty, double price) async {
    await ApiService.updateStock(id, {
      'name': name,
      'category': category,
      'quantity': qty,
      'price': price,
    });
    await fetchStocks();
  }

  Future<void> deleteStock(String id) async {
    await ApiService.deleteStock(id);
    await fetchStocks();
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getAllBookings();
      _transactions = data.map((e) => TransactionItem.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTransactionStatus(String id, String newStatus) async {
    await ApiService.updateBookingStatus(id, newStatus);
    await fetchTransactions();
  }
}
