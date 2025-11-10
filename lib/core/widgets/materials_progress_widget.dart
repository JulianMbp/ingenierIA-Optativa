import 'package:flutter/material.dart';

import '../models/material.dart' as material_model;

/// Widget that displays materials progress for a project
/// Shows overall availability percentage and breakdown by status
class MaterialsProgressWidget extends StatelessWidget {
  final List<material_model.Material> materials;
  final bool isLoading;

  const MaterialsProgressWidget({
    super.key,
    required this.materials,
    this.isLoading = false,
  });

  /// Calculate overall materials availability percentage based on status
  /// Returns percentage of materials that are "disponible" (available)
  double get availableMaterialsPercentage {
    if (materials.isEmpty) return 0.0;
    
    final availableCount = materials.where((m) => m.status == 'disponible').length;
    return (availableCount / materials.length) * 100;
  }

  /// Calculate overall materials availability percentage based on quantity tracking
  double get overallProgress {
    if (materials.isEmpty) return 0.0;
    
    // Filter materials that have tracking data (requiredQuantity > 0)
    final trackedMaterials = materials.where((material_model.Material m) => 
      m.requiredQuantity != null && m.requiredQuantity! > 0
    ).toList();
    
    if (trackedMaterials.isEmpty) return 0.0;
    
    // Calculate average availability percentage
    final totalPercentage = trackedMaterials.fold<double>(
      0.0,
      (sum, material) => sum + material.availabilityPercentage,
    );
    
    return totalPercentage / trackedMaterials.length;
  }

  /// Get materials statistics
  Map<String, int> get statistics {
    final stats = <String, int>{
      'total': materials.length,
      'pending': 0,
      'purchased': 0,
      'inTransit': 0,
      'available': 0,
      'tracked': 0,
    };

    for (final material in materials) {
      // Count by status
      switch (material.status) {
        case 'pendiente':
          stats['pending'] = (stats['pending'] ?? 0) + 1;
          break;
        case 'comprado':
          stats['purchased'] = (stats['purchased'] ?? 0) + 1;
          break;
        case 'en_transito':
          stats['inTransit'] = (stats['inTransit'] ?? 0) + 1;
          break;
        case 'disponible':
          stats['available'] = (stats['available'] ?? 0) + 1;
          break;
      }

      // Count tracked materials (with requiredQuantity)
      if (material.requiredQuantity != null && material.requiredQuantity! > 0) {
        stats['tracked'] = (stats['tracked'] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// Get progress color based on percentage
  Color getProgressColor(double percentage) {
    if (percentage < 30) return Colors.red;
    if (percentage < 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (materials.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, 
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Materials Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'No materials registered',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final stats = statistics;
    final availablePercentage = availableMaterialsPercentage;
    final progressColor = getProgressColor(availablePercentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Materials Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${availablePercentage.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),

          // Key Statistics - Available and Pending
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Available',
                  value: '${stats['available']}',
                  total: '${stats['total']}',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Pending',
                  value: '${stats['pending']}',
                  total: '${stats['total']}',
                  color: Colors.orange,
                  icon: Icons.pending,
                ),
              ),
            ],
          ),

          // Progress bar for available materials
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Materials',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${stats['available']}/${stats['total']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: availablePercentage / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),

          // All status breakdown
          if (stats['purchased']! > 0 || stats['inTransit']! > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (stats['purchased']! > 0)
                  _StatusChip(
                    label: 'Purchased',
                    count: stats['purchased']!,
                    color: Colors.blue,
                  ),
                if (stats['inTransit']! > 0)
                  _StatusChip(
                    label: 'In Transit',
                    count: stats['inTransit']!,
                    color: Colors.purple,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper widget for status chips
class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget for displaying key statistics
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String total;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'of $total total',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

