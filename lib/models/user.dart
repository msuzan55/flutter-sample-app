class PosUser {
  const PosUser({
    required this.id,
    this.username,
    this.email,
    this.fullName,
    this.businessId,
    this.branchId,
    this.branchName,
    this.role,
  });

  final int id;
  final String? username;
  final String? email;
  final String? fullName;
  final int? businessId;
  final int? branchId;
  final String? branchName;
  final String? role;

  String get displayName =>
      fullName?.trim().isNotEmpty == true
          ? fullName!
          : (username ?? email ?? 'User');

  bool get needsSetup => businessId == null || branchId == null;

  factory PosUser.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw is int
        ? idRaw
        : int.tryParse(idRaw?.toString() ?? '') ?? 0;

    return PosUser(
      id: id,
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      fullName: json['full_name']?.toString(),
      businessId: _optionalInt(json['business_id']),
      branchId: _optionalInt(json['branch_id']),
      branchName: json['branch_name']?.toString(),
      role: json['role']?.toString(),
    );
  }

  static int? _optionalInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'full_name': fullName,
        'business_id': businessId,
        'branch_id': branchId,
        'branch_name': branchName,
        'role': role,
      };
}
