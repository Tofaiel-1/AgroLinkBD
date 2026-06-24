import 'package:flutter/material.dart';

class CompanyContract {
  final String id;
  final String farmerName;
  final String crop;
  final String quantity;
  final String startDate;
  final String endDate;
  String status; // 'active', 'completed', 'cancelled'
  final int progress;

  CompanyContract({
    required this.id,
    required this.farmerName,
    required this.crop,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.progress,
  });
}

class CompanyOrder {
  final String id;
  final String farmerName;
  final String items;
  final String amount;
  String status; // 'active', 'delivered', 'cancelled'
  final String date;

  CompanyOrder({
    required this.id,
    required this.farmerName,
    required this.items,
    required this.amount,
    required this.status,
    required this.date,
  });
}

class CompanyTransaction {
  final String title;
  final String date;
  final String amount;
  final bool isCredit;
  final String status;

  CompanyTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.status,
  });
}

class CompanyProvider extends ChangeNotifier {
  // Dummy Data State
  List<CompanyContract> _contracts = [];
  List<CompanyOrder> _orders = [];
  List<CompanyTransaction> _transactions = [];

  // Budget
  final double _totalBudget = 1000000; // 10 Lakh
  double _usedBudget = 545000; // 5.45 Lakh

  CompanyProvider() {
    _initializeDummyData();
  }

  List<CompanyContract> get contracts => _contracts;
  List<CompanyOrder> get orders => _orders;
  List<CompanyTransaction> get transactions => _transactions;
  
  double get totalBudget => _totalBudget;
  double get usedBudget => _usedBudget;
  
  int get activeContractsCount => _contracts.where((c) => c.status == 'active').length;
  int get pendingOrdersCount => _orders.where((o) => o.status == 'active').length;
  int get monthlyOrdersCount => _orders.length;

  void completeOrder(String id) {
    final order = _orders.firstWhere((o) => o.id == id);
    if (order.status == 'active') {
      order.status = 'delivered';
      // Record transaction
      _transactions.insert(0, CompanyTransaction(
        title: 'অর্ডার পেমেন্ট - ${order.id}',
        date: 'এইমাত্র',
        amount: order.amount,
        isCredit: false,
        status: 'Completed'
      ));
      notifyListeners();
    }
  }

  void completeContract(String id) {
    final contract = _contracts.firstWhere((c) => c.id == id);
    if (contract.status == 'active') {
      contract.status = 'completed';
      notifyListeners();
    }
  }

  void _initializeDummyData() {
    _contracts = [
      CompanyContract(id: 'CF-2024-1001', farmerName: 'রহিম ফার্ম', crop: 'ধান', quantity: '১০০ মেট্রিক টন', startDate: '১ জানুয়ারি ২০২৪', endDate: '৩০ জুন ২০২৪', status: 'active', progress: 45),
      CompanyContract(id: 'CF-2024-1002', farmerName: 'করিম এগ্রো', crop: 'গম', quantity: '৫০ মেট্রিক টন', startDate: '১৫ ফেব্রুয়ারি ২০২৪', endDate: '১৫ জুলাই ২০২৪', status: 'completed', progress: 100),
      CompanyContract(id: 'CF-2024-1003', farmerName: 'জামান সীডস', crop: 'ভুট্টা', quantity: '২০০ মেট্রিক টন', startDate: '১ মার্চ ২০২৪', endDate: '৩০ আগস্ট ২০২৪', status: 'active', progress: 20),
      CompanyContract(id: 'CF-2024-1004', farmerName: 'সবুজ বাংলা খামার', crop: 'আলু', quantity: '৩০০ মেট্রিক টন', startDate: '১০ ডিসেম্বর ২০২৩', endDate: '১০ মে ২০২৪', status: 'cancelled', progress: 0),
    ];

    _orders = [
      CompanyOrder(id: 'ORD-2024-5001', farmerName: 'রহিম ফার্ম', items: 'চাল (মিনিকেট)', amount: '৳ ১,২০,০০০', status: 'active', date: 'আজ'),
      CompanyOrder(id: 'ORD-2024-5002', farmerName: 'করিম এগ্রো', items: 'গম', amount: '৳ ৪৫,০০০', status: 'delivered', date: 'গতকাল'),
      CompanyOrder(id: 'ORD-2024-5003', farmerName: 'সবুজ বাংলা খামার', items: 'আলু', amount: '৳ ৮০,০০০', status: 'active', date: '২ দিন আগে'),
      CompanyOrder(id: 'ORD-2024-5004', farmerName: 'জামান সীডস', items: 'ভুট্টা বীজ', amount: '৳ ২৫,০০০', status: 'cancelled', date: '৫ দিন আগে'),
      CompanyOrder(id: 'ORD-2024-5005', farmerName: 'রহিম ফার্ম', items: 'চাল (নাজিরশাইল)', amount: '৳ ৯০,০০০', status: 'delivered', date: '১ সপ্তাহ আগে'),
    ];

    _transactions = [
      CompanyTransaction(title: 'খামার-A চুক্তি অগ্রিম', date: 'আজ, সকাল ৯:১৫', amount: '৳ 50,000', isCredit: false, status: 'Completed'),
      CompanyTransaction(title: 'ডেলিভারি পেমেন্ট (ORD-5002)', date: 'গতকাল, বিকেল ৫:৩০', amount: '৳ 45,000', isCredit: false, status: 'Completed'),
      CompanyTransaction(title: 'রিফান্ড (ORD-5004)', date: '৫ দিন আগে', amount: '৳ 25,000', isCredit: true, status: 'Completed'),
    ];
  }
}
