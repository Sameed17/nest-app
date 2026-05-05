enum UserRole {
  hostel(label: 'Hostel'),
  gate(label: 'Gate'),
  transport(label: 'Transport');

  const UserRole({required this.label});

  final String label;

  static UserRole? tryParse(String? value) {
    if (value == null) {
      return null;
    }
    for (final UserRole role in UserRole.values) {
      if (role.name == value) {
        return role;
      }
    }
    return null;
  }
}

