import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../configs/app/app_globals.dart';
import '../../configs/app/theme/app_colors.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/shell/app_drawer_item.dart';
import '../scan/scan_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  AppDrawerItem _selected = AppDrawerItem.hostelMess;

  @override
  Widget build(BuildContext context) {
    final AuthState authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final List<AppDrawerItem> items = AppDrawerItem.forRole(user.role);
    if (!items.contains(_selected)) {
      _selected = items.first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_selected.title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        surfaceTintColor: AppColors.surface,
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  user.name,
                  style: TextStyle(
                    fontSize: AppGlobals.dts.h2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                subtitle: Text(
                  user.role.label,
                  style: TextStyle(
                    fontSize: AppGlobals.dts.small,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    for (final AppDrawerItem item in items)
                      ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.title),
                        selected: item == _selected,
                        onTap: () {
                          setState(() => _selected = item);
                          Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<AuthCubit>().logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: ScanPage(
        title: _selected.title,
        endpoint: _selected.endpoint,
      ),
    );
  }
}

