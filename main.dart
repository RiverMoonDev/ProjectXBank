import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'backend.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() {
  runApp(const ProjectXApp());
}

class ProjectXApp extends StatelessWidget {
  const ProjectXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AccountProvider()..loadAccounts(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blueAccent,
          scaffoldBackgroundColor: Colors.black,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        ),
        home: PasswordScreen(),
      ),
    );
  }
}

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final String correctPassword = "project30a";
  bool _isPasswordVisible = false;
  String? _errorMessage;

  void _validatePassword() {
    setState(() {
      if (_passwordController.text == correctPassword) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavigationPage()),
        );
      } else {
        _errorMessage = "Helytelen jelszó! Próbálkozzon újra!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Project X Bank belépés",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    cursorColor: Colors.blueAccent,
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      labelText: "Jelszó",
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _validatePassword,
                    child: Text(
                      "Belépés",
                      style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AccountsPage(),
    AnalyticsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Számlák',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Elemzések',
          ),
        ],
      ),
    );
  }
}

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project X Bank - Számlák',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const AddAccountDialog(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    account.name[0],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  account.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Egyenleg: ${account.balance.toStringAsFixed(2)} XCoin',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                  onPressed: () => _showDeleteConfirmationDialog(context, account),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountDetailsPage(account: account),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Törlés megerősítése',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            'Biztosan törölni szeretné a(z) "${account.name}" számlát?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mégse', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                context.read<AccountProvider>().deleteAccount(account);
                Navigator.of(context).pop();
              },
              child: const Text('Törlés', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final totalBalance =
        accounts.fold(0.0, (sum, account) => sum + account.balance);
    final averageBalance =
        accounts.isNotEmpty ? totalBalance / accounts.length : 0;
    final todayTransactions = accounts
        .expand((account) => account.history)
        .where((entry) => DateTime.now().difference(entry.date).inDays == 0)
        .toList();
    final categorySpending = _calculateCategorySpending(accounts);
    final highestBalanceAccount = accounts.isNotEmpty
        ? accounts.reduce((a, b) => a.balance > b.balance ? a : b)
        : null;
    final lowestBalanceAccount = accounts.isNotEmpty
        ? accounts.reduce((a, b) => a.balance < b.balance ? a : b)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project X Bank - Elemzések', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatTile('Összesített egyenleg',
                '${totalBalance.toStringAsFixed(2)} XCoin', Icons.account_balance),
            _buildStatTile('Átlagos egyenleg',
                '${averageBalance.toStringAsFixed(2)} XCoin', Icons.equalizer),
            _buildStatTile('Számlák száma', '${accounts.length}', Icons.list),
            _buildStatTile('Mai tranzakciók', '${todayTransactions.length}', Icons.today),
            if (highestBalanceAccount != null)
              _buildStatTile(
                  'Legmagasabb egyenlegű számla',
                  '${highestBalanceAccount.name}: ${highestBalanceAccount.balance.toStringAsFixed(2)} XCoin',
                  Icons.trending_up),
            if (lowestBalanceAccount != null)
              _buildStatTile(
                  'Legalacsonyabb egyenlegű számla',
                  '${lowestBalanceAccount.name}: ${lowestBalanceAccount.balance.toStringAsFixed(2)} XCoin',
                  Icons.trending_down),
            const SizedBox(height: 20),
            Text('Kategória szerinti költés:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SizedBox(height: 200, child: _buildSpendingChart(categorySpending)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Map<String, double> _calculateCategorySpending(List<Account> accounts) {
    final Map<String, double> spending = {};
    for (var account in accounts) {
      for (var entry in account.history) {
        if (entry.amount < 0) {
          spending[entry.description] =
              (spending[entry.description] ?? 0) + entry.amount.abs();
        }
      }
    }
    return spending;
  }

  Widget _buildSpendingChart(Map<String, double> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: data.entries.map((entry) {
          return BarChartGroupData(
            x: data.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(toY: entry.value, color: Colors.blueAccent),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class AddAccountDialog extends StatelessWidget {
  const AddAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text(
        'Új számla hozzáadása',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: nameController,
          cursorColor: Colors.blueAccent,
          decoration: InputDecoration(
            hintText: 'Számla neve',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Mégse',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              context.read<AccountProvider>().addAccount(nameController.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Hozzáadás'),
        ),
      ],
    );
  }
}

class AccountDetailsPage extends StatefulWidget {
  final Account account;

  const AccountDetailsPage({super.key, required this.account});

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.account.name} számlatörténete', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<AccountProvider>(
          builder: (context, provider, child) {
            final account = provider.accounts.firstWhere((a) => a.name == widget.account.name, orElse: () => widget.account);
            
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: account.history.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final entry = account.history[index];
                      return ListTile(
                        leading: Icon(
                          entry.amount > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          color: entry.amount > 0 ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          entry.description,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${entry.amount > 0 ? 'Befizetés' : 'Kivétel'}: ${entry.amount.toStringAsFixed(2)} XCoin\n'
                          'Dátum: ${DateFormat('yyyy-MM-dd HH:mm').format(entry.date)}',
                        ),
                        trailing: Text(
                          '${entry.amount.toStringAsFixed(2)} XCoin',
                          style: TextStyle(
                            color: entry.amount > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          builder: (context) => AccountActionsDialog(account: widget.account),
        ),
        icon: const Icon(Icons.settings),
        label: const Text('Műveletek'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class AccountActionsDialog extends StatelessWidget {
  final Account account;

  const AccountActionsDialog({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final recipientController = TextEditingController();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${account.name} műveletek',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              cursorColor: Colors.blueAccent,
              decoration: const InputDecoration(
                labelText: 'Összeg',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                labelStyle: const TextStyle(color: Colors.white), border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              cursorColor: Colors.blueAccent,
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Leírás',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                labelStyle: const TextStyle(color: Colors.white), border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              cursorColor: Colors.blueAccent,
              controller: recipientController,
              decoration: const InputDecoration(
                labelText: 'Címzett számla neve',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                labelStyle: const TextStyle(color: Colors.white), border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mégse', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    final description = descriptionController.text;
                    if (amount > 0) {
                      context.read<AccountProvider>().deposit(account, amount, description);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Befizetés', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    final description = descriptionController.text;
                    if (amount > 0) {
                      context.read<AccountProvider>().withdraw(account, amount, description);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Kivétel', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    final description = descriptionController.text;
                    final recipientName = recipientController.text;
                    if (amount > 0 && recipientName.isNotEmpty) {
                      context.read<AccountProvider>().transfer(account, recipientName, amount, description);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Átutalás', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
