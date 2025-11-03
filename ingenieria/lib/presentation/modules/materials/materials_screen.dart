import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/role_theme.dart';
import '../../../domain/entities/material.dart' as entities;
import '../../providers/auth_provider.dart';
import '../../providers/material_provider.dart';
import '../../widgets/glass_card.dart';
import 'material_form_sheet.dart';

/// Materials management screen with glassmorphism UI
class MaterialsScreen extends ConsumerWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(currentObraMaterialsProvider);
    final authState = ref.watch(authProvider);
    final role = authState.user?.role;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Materials'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              role?.accentColor.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
              Colors.transparent,
              role?.accentColor.withOpacity(0.05) ?? Colors.blue.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: materialsAsync.when(
            data: (materials) => _buildMaterialsList(context, ref, materials, role),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(context, error.toString()),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMaterialSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Material'),
        backgroundColor: role?.accentColor,
      ),
    );
  }

  Widget _buildMaterialsList(
    BuildContext context,
    WidgetRef ref,
    List<entities.Material> materials,
    dynamic role,
  ) {
    if (materials.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentObraMaterialsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          return _buildMaterialCard(context, ref, material, role);
        },
      ),
    );
  }

  Widget _buildMaterialCard(
    BuildContext context,
    WidgetRef ref,
    entities.Material material,
    dynamic role,
  ) {
    final isLowStock = material.isLowStock;
    final totalValue = material.totalCost ?? 0;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      gradientColors: isLowStock
          ? [
              Colors.red.withOpacity(0.15),
              Colors.red.withOpacity(0.05),
            ]
          : role?.gradientColors,
      onTap: () => _showMaterialDetail(context, ref, material),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: role?.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: role?.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            material.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 14,
                                  color: Colors.red[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Low Stock',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${material.quantity} ${material.unit}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (material.description != null) ...[
            const SizedBox(height: 12),
            Text(
              material.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                context,
                Icons.attach_money,
                '\$${totalValue.toStringAsFixed(2)}',
              ),
              const SizedBox(width: 8),
              if (material.supplier != null)
                _buildInfoChip(
                  context,
                  Icons.business,
                  material.supplier!,
                ),
              const Spacer(),
              _buildStatusChip(context, material.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color statusColor;
    String statusLabel;

    switch (status.toLowerCase()) {
      case 'received':
        statusColor = Colors.green;
        statusLabel = 'Received';
        break;
      case 'ordered':
        statusColor = Colors.orange;
        statusLabel = 'Ordered';
        break;
      case 'in_use':
        statusColor = Colors.blue;
        statusLabel = 'In Use';
        break;
      case 'depleted':
        statusColor = Colors.red;
        statusLabel = 'Depleted';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          fontSize: 12,
          color: statusColor.withOpacity(0.9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No materials yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first material',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading materials',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMaterialSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MaterialFormSheet(),
    );
  }

  void _showMaterialDetail(
    BuildContext context,
    WidgetRef ref,
    entities.Material material,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaterialFormSheet(material: material),
    );
  }
}
