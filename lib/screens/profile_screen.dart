import 'package:flutter/material.dart';
import 'package:smart_pocket/widgets/profile/budgets_card.dart';

import '../models/user_profile.dart';
import '../mocks/user_profile_mock.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/profile/app_settings_card.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/user_data_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late UserProfile _profile;

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _profile = UserProfileMock.profile;

    _nameController = TextEditingController(text: _profile.name);

    _emailController = TextEditingController(text: _profile.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _profile = _profile.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  void _updateCurrency(String currency) {
    setState(() {
      _profile = _profile.copyWith(currency: currency);
    });
  }

  void _updateMonthlyLimit(double limit) {
    setState(() {
      _profile = _profile.copyWith(monthlySpendingLimit: limit);
    });
  }

  Future<void> _confirmClearTransactions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar transações'),
        content: const Text(
          'Deseja realmente excluir todas as transações? '
          'Essa ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    // Os mocks são constantes e não podem ser apagados diretamente.
    // A exclusão real será implementada quando houver persistência.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A exclusão das transações será implementada com o banco de dados.',
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeader(),

              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: UserDataCard(
                  profile: _profile,
                  nameController: _nameController,
                  emailController: _emailController,
                  onSave: _saveProfile,
                ),
              ),

              const SizedBox(height: 20),

              BudgetsCard(
                onTap: () {
                  Navigator.pushNamed(context, '/budgets');
                },
              ),

              const SizedBox(height: 20),

              AppSettingsCard(
                selectedCurrency: _profile.currency,
                onCurrencyChanged: _updateCurrency,
                monthlySpendingLimit: _profile.monthlySpendingLimit,
                onMonthlyLimitChanged: _updateMonthlyLimit,
                onClearTransactions: _confirmClearTransactions,
                onLogout: _logout,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
    );
  }
}
