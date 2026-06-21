import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'payment': 'Payment',
      'transaction': 'Transaction',
      'wallet': 'Wallet',
      'history': 'History',
      'amount': 'Amount',
      'method': 'Method',
      'status': 'Status',
      'date': 'Date',
      'pending': 'Pending',
      'completed': 'Completed',
      'failed': 'Failed',
      'refunded': 'Refunded',
      'processing': 'Processing',
      'cancelled': 'Cancelled',
      'bkash': 'bKash',
      'nagad': 'Nagad',
      'rocket': 'Rocket',
      'card': 'Card',
      'flutterwave': 'Flutterwave',
      'select_payment_method': 'Select Payment Method',
      'payment_summary': 'Payment Summary',
      'confirm_payment': 'Confirm Payment',
      'pay_now': 'Pay Now',
      'processing_payment': 'Processing Payment...',
      'payment_successful': 'Payment Successful!',
      'payment_failed': 'Payment Failed',
      'try_again': 'Try Again',
      'wallet_balance': 'Wallet Balance',
      'transaction_history': 'Transaction History',
      'payment_history': 'Payment History',
      'no_transactions': 'No transactions yet',
      'no_payments': 'No payments made yet',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'close': 'Close',
      'cancel': 'Cancel',
      'total_amount': 'Total Amount',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'email_address': 'Email Address',
      'order_id': 'Order ID',
      'purpose': 'Purpose',
      'description': 'Description',
      'details': 'Details',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'credit': 'Credit',
      'debit': 'Debit',
      'refund': 'Refund',
    },
    'bn': {
      'payment': 'পেমেন্ট',
      'transaction': 'লেনদেন',
      'wallet': 'ওয়ালেট',
      'history': 'ইতিহাস',
      'amount': 'পরিমাণ',
      'method': 'পদ্ধতি',
      'status': 'স্ট্যাটাস',
      'date': 'তারিখ',
      'pending': 'অপেক্ষায়',
      'completed': 'সম্পন্ন',
      'failed': 'ব্যর্থ',
      'refunded': 'ফেরত দেওয়া',
      'processing': 'প্রসেসিং',
      'cancelled': 'বাতিল',
      'bkash': 'বিকাশ',
      'nagad': 'নগদ',
      'rocket': 'রকেট',
      'card': 'কার্ড',
      'flutterwave': 'ফ্লাটারওয়েভ',
      'select_payment_method': 'পেমেন্ট পদ্ধতি নির্বাচন করুন',
      'payment_summary': 'পেমেন্ট সারসংক্ষেপ',
      'confirm_payment': 'পেমেন্ট নিশ্চিত করুন',
      'pay_now': 'এখনই পেমেন্ট করুন',
      'processing_payment': 'পেমেন্ট প্রক্রিয়াকরণ...',
      'payment_successful': 'পেমেন্ট সফল!',
      'payment_failed': 'পেমেন্ট ব্যর্থ',
      'try_again': 'আবার চেষ্টা করুন',
      'wallet_balance': 'ওয়ালেট ব্যালেন্স',
      'transaction_history': 'লেনদেনের ইতিহাস',
      'payment_history': 'পেমেন্টের ইতিহাস',
      'no_transactions': 'কোন লেনদেন নেই',
      'no_payments': 'কোন পেমেন্ট করা হয়নি',
      'error': 'ত্রুটি',
      'success': 'সফল',
      'loading': 'লোডিং...',
      'close': 'বন্ধ করুন',
      'cancel': 'বাতিল করুন',
      'total_amount': 'মোট পরিমাণ',
      'full_name': 'সম্পূর্ণ নাম',
      'phone_number': 'ফোন নম্বর',
      'email_address': 'ইমেল ঠিকানা',
      'order_id': 'অর্ডার আইডি',
      'purpose': 'উদ্দেশ্য',
      'description': 'বর্ণনা',
      'details': 'বিবরণ',
      'edit': 'সম্পাদনা করুন',
      'delete': 'মুছুন',
      'save': 'সংরক্ষণ করুন',
      'credit': 'জমা',
      'debit': 'উত্তোলন',
      'refund': 'রিফান্ড',
    },
  };

  final String locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations('en');
  }

  String translate(String key) {
    return _localizedStrings[locale]?[key] ?? key;
  }

  String formatCurrency(double amount, {String? currencySymbol}) {
    final currency = currencySymbol ?? 'Tk';
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a', locale).format(date);
  }

  String formatShortDate(DateTime date) {
    return DateFormat('dd MMM yyyy', locale).format(date);
  }

  bool isRTL() => locale == 'bn';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'bn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale.languageCode));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
