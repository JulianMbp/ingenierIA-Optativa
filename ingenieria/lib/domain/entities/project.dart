import 'package:equatable/equatable.dart';

/// Entity representing a construction project (obra).
class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final String address;
  final String? city;
  final String? country;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // 'active', 'paused', 'completed'
  final double? budget;
  final String? managerId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.city,
    this.country,
    required this.startDate,
    this.endDate,
    required this.status,
    this.budget,
    this.managerId,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        city,
        country,
        startDate,
        endDate,
        status,
        budget,
        managerId,
        createdAt,
        updatedAt,
      ];

  /// Check if project is currently active
  bool get isActive => status == 'active';

  /// Check if project is completed
  bool get isCompleted => status == 'completed';

  /// Get project duration in days
  int? get durationInDays {
    if (endDate == null) return null;
    return endDate!.difference(startDate).inDays;
  }

  /// Create a copy with updated fields
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? budget,
    String? managerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      managerId: managerId ?? this.managerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
