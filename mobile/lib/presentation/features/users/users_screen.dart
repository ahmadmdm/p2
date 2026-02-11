import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'users_controller.dart';
import '../../../domain/entities/user.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.staffManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUserDialog(context, ref),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text('${user.role} - ${user.email}'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit)),
                    PopupMenuItem(
                        value: 'delete',
                        child: Text(AppLocalizations.of(context)!.delete)),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditUserDialog(context, ref, user);
                    } else if (value == 'delete') {
                      _confirmDelete(context, ref, user);
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $err')),
      ),
    );
  }

  Future<void> _showAddUserDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => const UserDialog(),
    );
  }

  Future<void> _showEditUserDialog(
      BuildContext context, WidgetRef ref, User user) async {
    await showDialog(
      context: context,
      builder: (context) => UserDialog(user: user),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteUser),
        content: Text(
            AppLocalizations.of(context)!.deleteUserConfirmation(user.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.delete,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(usersControllerProvider.notifier).deleteUser(user.id);
    }
  }
}

class UserDialog extends ConsumerStatefulWidget {
  final User? user;

  const UserDialog({super.key, this.user});

  @override
  ConsumerState<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends ConsumerState<UserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  String _role = 'cashier';

  final List<String> _roles = [
    'admin',
    'manager',
    'cashier',
    'waiter',
    'kitchen',
    'driver'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _role = widget.user!.role;
      _pinController.text = widget.user!.pinCode ?? '';
      // Password not shown
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return AlertDialog(
      title: Text(isEditing
          ? AppLocalizations.of(context)!.editUser
          : AppLocalizations.of(context)!.addUser),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name),
                validator: (v) => v == null || v.isEmpty
                    ? AppLocalizations.of(context)!.required
                    : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email),
                validator: (v) => v == null || v.isEmpty
                    ? AppLocalizations.of(context)!.required
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: isEditing
                        ? AppLocalizations.of(context)!.passwordEditPlaceholder
                        : AppLocalizations.of(context)!.passwordPlaceholder),
                obscureText: true,
                validator: (v) {
                  if (!isEditing && (v == null || v.isEmpty))
                    return AppLocalizations.of(context)!.required;
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.role),
                items: _roles
                    .map((r) => DropdownMenuItem(
                        value: r, child: Text(r.toUpperCase())))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _role = val);
                },
              ),
              TextFormField(
                controller: _pinController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.pinCode),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel)),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (isEditing) {
                ref.read(usersControllerProvider.notifier).updateUser(
                      widget.user!.id,
                      name: _nameController.text,
                      email: _emailController.text,
                      password: _passwordController.text.isEmpty
                          ? null
                          : _passwordController.text,
                      role: _role,
                      pinCode: _pinController.text.isEmpty
                          ? null
                          : _pinController.text,
                    );
              } else {
                ref.read(usersControllerProvider.notifier).addUser(
                      name: _nameController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                      role: _role,
                      pinCode: _pinController.text.isEmpty
                          ? null
                          : _pinController.text,
                    );
              }
              Navigator.pop(context);
            }
          },
          child: Text(isEditing
              ? AppLocalizations.of(context)!.save
              : AppLocalizations.of(context)!.add),
        ),
      ],
    );
  }
}
