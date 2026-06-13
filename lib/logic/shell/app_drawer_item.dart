import 'package:flutter/material.dart';

import '../../configs/app/remote/api/api_endpoints.dart';
import '../auth/user_role.dart';

enum AppDrawerItem {
  hostelMess(
    title: 'Hostel - Mess',
    icon: Icons.qr_code_scanner,
    endpoint: XEndpoint.scanHostelMessEndpoint,
  ),
  hostelGatepass(
    title: 'Hostel - Gatepass',
    icon: Icons.qr_code_2,
    endpoint: XEndpoint.scanGatepassEndpoint,
  ),
  hostelResidency(
    title: 'Hostel - Residency',
    icon: Icons.inventory_2_outlined,
    endpoint: XEndpoint.scanHostelResidencyEndpoint,
  ),
  gatepass(
    title: 'Gatepass',
    icon: Icons.verified_user_outlined,
    endpoint: XEndpoint.scanGatepassEndpoint,
  ),
  transportBus(
    title: 'Transport - Bus',
    icon: Icons.directions_bus_outlined,
    endpoint: XEndpoint.scanTransportBusEndpoint,
  ),
  transportGatepass(
    title: 'Transport - Gatepass',
    icon: Icons.local_shipping_outlined,
    endpoint: XEndpoint.scanGatepassEndpoint,
  );

  const AppDrawerItem({
    required this.title,
    required this.icon,
    required this.endpoint,
  });

  final String title;
  final IconData icon;
  final String endpoint;

  static List<AppDrawerItem> forRole(UserRole role) {
    return switch (role) {
      UserRole.hostel => <AppDrawerItem>[
          hostelMess,
          hostelGatepass,
          hostelResidency,
        ],
      UserRole.gate => <AppDrawerItem>[gatepass],
      UserRole.transport => <AppDrawerItem>[transportBus, transportGatepass],
    };
  }
}

