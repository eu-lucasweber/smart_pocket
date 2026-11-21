import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pocket/repositories/user_profile_repository.dart';
import 'package:smart_pocket/controllers/app_controller.dart';

import '../models/user_profile.dart';
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
  final _userProfileRepository = UserProfileRepository();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await _userProfileRepository.getUserProfile();

    if (!mounted) return;

    setState(() {
      _profile = profile;
      _nameController.text = profile?.name ?? '';
      _emailController.text = profile?.email ?? '';
      _isLoading = false;
    });
  }

  void _saveProfile() {
    final profile = _profile;
    if (profile == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _profile = profile.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  Future<void> _updateCurrency(String currency) async {
    final profile = _profile;
    if (profile == null) return;

    final updated = profile.copyWith(currency: currency);

    try {
      await _userProfileRepository.updateCurrency(updated);
    } catch (e) {
      debugPrint('Erro ao atualizar moeda: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar a moeda.')),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _profile = updated;
    });

    // faz as outras telas usarem a nova moeda
    context.read<AppController>().load();
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = _profile;
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Não foi possível carregar o perfil.')),
      );
    }

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
                  profile: profile,
                  nameController: _nameController,
                  emailController: _emailController,
                  onSave: _saveProfile,
                ),
              ),
              const SizedBox(height: 20),
              AppSettingsCard(
                selectedCurrency: profile.currency,
                onCurrencyChanged: _updateCurrency,
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
