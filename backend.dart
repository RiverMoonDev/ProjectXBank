import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AccountProvider extends ChangeNotifier {
  final List<Account> accounts = [];

  Future<void> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsData = prefs.getString('accounts');
    if (accountsData != null) {
      final List<dynamic> decoded = jsonDecode(accountsData);
      accounts.clear();
      accounts.addAll(decoded.map((data) => Account.fromJson(data)));
      notifyListeners();
    }
  }

  Future<void> saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsData = jsonEncode(accounts.map((account) => account.toJson()).toList());
    await prefs.setString('accounts', accountsData);
  }

  void addAccount(String name) {
    accounts.add(Account(name: name, balance: 0, history: []));
    saveAccounts();
    notifyListeners();
  }

  void deleteAccount(Account account) {
    accounts.remove(account);
    saveAccounts();
    notifyListeners();
  }

  void deposit(Account account, double amount, String description) {
    account.balance += amount;
    account.history.add(HistoryEntry(
      amount: amount,
      description: description,
      date: DateTime.now(),
    ));
    saveAccounts();
    notifyListeners();
  }

  void withdraw(Account account, double amount, String description) {
    account.balance -= amount;
    account.history.add(HistoryEntry(
      amount: -amount,
      description: description,
      date: DateTime.now(),
    ));
    saveAccounts();
    notifyListeners();
  }


  void transfer(Account sender, String recipientName, double amount, String description) {
    final recipient = accounts.firstWhere(
      (acc) => acc.name == recipientName,
      orElse: () => Account(name: 'Unknown', balance: 0.0, history: []),
    );

    if (recipient.name != 'Unknown') {
      sender.balance -= amount;
      recipient.balance += amount;

      DateTime now = DateTime.now();

      sender.history.add(HistoryEntry(
        amount: -amount,
        description: 'Átutalás: $description -> ${recipient.name}',
        date: now,
      ));

      recipient.history.add(HistoryEntry(
        amount: amount,
        description: 'Átutalás: $description <- ${sender.name}',
        date: now,
      ));

      saveAccounts();
      notifyListeners();
    }
  }

}

class Account {
  String name;
  double balance;
  List<HistoryEntry> history;

  Account({required this.name, required this.balance, required this.history});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      name: json['name'],
      balance: json['balance'],
      history: (json['history'] as List<dynamic>)
          .map((entry) => HistoryEntry.fromJson(entry))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
      'history': history.map((entry) => entry.toJson()).toList(),
    };
  }
}

class HistoryEntry {
  double amount;
  String description;
  DateTime date;

  HistoryEntry({required this.amount, required this.description, DateTime? date})
      : date = date ?? DateTime.now();

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      amount: json['amount'],
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}