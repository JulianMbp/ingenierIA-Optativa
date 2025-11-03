class JwtPayload {
  final String sub;
  final String email;
  final String role;
  final int iat;
  final int exp;

  JwtPayload({
    required this.sub,
    required this.email,
    required this.role,
    required this.iat,
    required this.exp,
  });

  factory JwtPayload.fromJson(Map<String, dynamic> json) {
    return JwtPayload(
      sub: json['sub'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      iat: json['iat'] ?? 0,
      exp: json['exp'] ?? 0,
    );
  }

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= exp;
  }

  DateTime get expirationDate {
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  DateTime get issuedAtDate {
    return DateTime.fromMillisecondsSinceEpoch(iat * 1000);
  }
}
