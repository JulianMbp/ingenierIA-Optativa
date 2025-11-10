import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../core/models/material.dart' as model;
import '../../../core/models/role.dart';
import '../../../core/services/material_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/materials_progress_widget.dart';
import '../../auth/auth_provider.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  List<model.Material> materials = [];
  bool isLoading = true;
  String? errorMessage;
  String? statusFilter; // null = all, 'pendiente', 'disponible', etc.

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  List<model.Material> get _filteredMaterials {
    if (statusFilter == null) return materials;
    return materials.where((m) => m.status == statusFilter).toList();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;

      if (projectId == null) {
        setState(() {
          errorMessage = 'No project selected';
          isLoading = false;
        });
        return;
      }

      final materialService = ref.read(materialServiceProvider);
      final result = await materialService.getMaterials(projectId);

      setState(() {
        materials = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading materials: $e';
        isLoading = false;
      });
    }
  }

  bool _canEdit() {
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role.type;
    // Admin General and Admin Obra can create/edit/delete
    return userRole == RoleType.adminGeneral || userRole == RoleType.adminObra;
  }

  Future<void> _showMaterialDialog({model.Material? material}) async {
    final isEdit = material != null;
    final nameController = TextEditingController(text: material?.name ?? '');
    final categoryController = TextEditingController(text: material?.category ?? '');
    final quantityController = TextEditingController(text: material?.quantity ?? '');
    final unitController = TextEditingController(text: material?.unit ?? '');
    final supplierController = TextEditingController(text: material?.supplier ?? '');
    
    // New fields controllers
    final availableQuantityController = TextEditingController(
      text: material?.availableQuantity?.toString() ?? ''
    );
    final requiredQuantityController = TextEditingController(
      text: material?.requiredQuantity?.toString() ?? material?.quantity ?? ''
    );
    String? selectedStatus = material?.status;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: Text(isEdit ? 'Edit Material' : 'New Material'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity (legacy)'),
                  keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit (e.g: m3, kg, unit)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: supplierController,
                decoration: const InputDecoration(labelText: 'Supplier'),
              ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Material Tracking (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: requiredQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Required Quantity',
                    hintText: 'Total quantity needed',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: availableQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Available Quantity',
                    hintText: 'Current available quantity',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 'pendiente', child: Text('Pending')),
                    DropdownMenuItem(value: 'comprado', child: Text('Purchased')),
                    DropdownMenuItem(value: 'en_transito', child: Text('In Transit')),
                    DropdownMenuItem(value: 'disponible', child: Text('Available')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedStatus = value;
                    });
                  },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final authState = ref.read(authProvider);
                final projectId = authState.currentProject?.id;

                if (projectId == null) return;

                final materialService = ref.read(materialServiceProvider);
                  final data = <String, dynamic>{
                  'nombre': nameController.text, // Keep backend field name
                  };

                  // Optional fields
                  if (categoryController.text.isNotEmpty) {
                    data['categoria'] = categoryController.text;
                  }
                  if (quantityController.text.isNotEmpty) {
                    data['cantidad'] = quantityController.text;
                  }
                  if (unitController.text.isNotEmpty) {
                    data['unidad'] = unitController.text;
                  }
                  if (supplierController.text.isNotEmpty) {
                    data['proveedor'] = supplierController.text;
                  }

                  // New tracking fields
                  if (requiredQuantityController.text.isNotEmpty) {
                    final required = double.tryParse(requiredQuantityController.text);
                    if (required != null) {
                      data['cantidad_requerida'] = required;
                    }
                  }
                  if (availableQuantityController.text.isNotEmpty) {
                    final available = double.tryParse(availableQuantityController.text);
                    if (available != null) {
                      data['cantidad_disponible'] = available;
                    }
                  }
                  if (selectedStatus != null && selectedStatus!.isNotEmpty) {
                    data['estado'] = selectedStatus;
                  }

                if (isEdit) {
                  await materialService.updateMaterial(
                    projectId,
                    material.id,
                    data,
                  );
                } else {
                  await materialService.createMaterial(projectId, data);
                }

                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
        ),
      ),
    );

    if (result == true) {
      _loadMaterials();
    }
  }

  Future<void> _updateMaterialStatus(model.Material material, String newStatus) async {
    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;

      if (projectId == null) return;

      final materialService = ref.read(materialServiceProvider);
      await materialService.updateMaterial(
        projectId,
        material.id,
        {'estado': newStatus},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Material status updated to ${_getStatusDisplay(newStatus)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      _loadMaterials();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  String _getStatusDisplay(String? status) {
    switch (status) {
      case 'pendiente':
        return 'Pending';
      case 'comprado':
        return 'Purchased';
      case 'en_transito':
        return 'In Transit';
      case 'disponible':
        return 'Available';
      default:
        return 'None';
    }
  }

  Future<void> _deleteMaterial(model.Material material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: Text('Delete "${material.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authState = ref.read(authProvider);
        final projectId = authState.currentProject?.id;

        if (projectId == null) return;

        final materialService = ref.read(materialServiceProvider);
        await materialService.deleteMaterial(projectId, material.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material deleted')),
          );
        }

        _loadMaterials();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _canEdit();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials'),
        backgroundColor: AppTheme.iosBlue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FB),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMaterials,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Materials Progress Widget
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: MaterialsProgressWidget(
                            materials: materials,
                            isLoading: false,
                          ),
                        ),
                        // Status Filters
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('All', null),
                                const SizedBox(width: 8),
                                _buildFilterChip('Pending', 'pendiente'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Available', 'disponible'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Purchased', 'comprado'),
                                const SizedBox(width: 8),
                                _buildFilterChip('In Transit', 'en_transito'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Materials List
                        Expanded(
                          child: _filteredMaterials.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.inventory_2_outlined,
                                          size: 64, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        statusFilter == null
                                            ? 'No materials registered'
                                            : 'No materials with status "${_getStatusDisplay(statusFilter)}"',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadMaterials,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _filteredMaterials.length,
                                    itemBuilder: (context, index) {
                                      final material = _filteredMaterials[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: GlassContainer(
                                          blur: 15,
                                          opacity: 0.2,
                                          borderRadius: BorderRadius.circular(16),
                                          padding: const EdgeInsets.all(0),
                                          child: ExpansionTile(
                                            title: Text(
                                              material.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (material.status != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: material.statusColor.withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: material.statusColor,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            material.statusDisplay,
                                                            style: TextStyle(
                                                              color: material.statusColor,
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Quick action buttons for status
                                                if (canEdit) ...[
                                                  if (material.status != 'disponible')
                                                    IconButton(
                                                      icon: const Icon(Icons.check_circle,
                                                          color: Colors.green, size: 24),
                                                      tooltip: 'Mark as Available',
                                                      onPressed: () =>
                                                          _updateMaterialStatus(material, 'disponible'),
                                                    ),
                                                  if (material.status != 'pendiente')
                                                    IconButton(
                                                      icon: const Icon(Icons.pending,
                                                          color: Colors.orange, size: 24),
                                                      tooltip: 'Mark as Pending',
                                                      onPressed: () =>
                                                          _updateMaterialStatus(material, 'pendiente'),
                                                    ),
                                                ],
                                                // Menu for edit/delete
                                                if (canEdit)
                                                  PopupMenuButton<String>(
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _showMaterialDialog(material: material);
                                                      } else if (value == 'delete') {
                                                        _deleteMaterial(material);
                                                      } else if (value == 'available') {
                                                        _updateMaterialStatus(material, 'disponible');
                                                      } else if (value == 'pending') {
                                                        _updateMaterialStatus(material, 'pendiente');
                                                      } else if (value == 'purchased') {
                                                        _updateMaterialStatus(material, 'comprado');
                                                      } else if (value == 'transit') {
                                                        _updateMaterialStatus(material, 'en_transito');
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit, size: 20),
                                                            SizedBox(width: 8),
                                                            Text('Edit'),
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuDivider(),
                                                      const PopupMenuItem(
                                                        value: 'available',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.check_circle,
                                                                color: Colors.green, size: 20),
                                                            SizedBox(width: 8),
                                                            Text('Mark as Available'),
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'pending',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.pending,
                                                                color: Colors.orange, size: 20),
                                                            SizedBox(width: 8),
                                                            Text('Mark as Pending'),
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'purchased',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.shopping_cart,
                                                                color: Colors.blue, size: 20),
                                                            SizedBox(width: 8),
                                                            Text('Mark as Purchased'),
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'transit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.local_shipping,
                                                                color: Colors.purple, size: 20),
                                                            SizedBox(width: 8),
                                                            Text('Mark as In Transit'),
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuDivider(),
                                                      const PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete,
                                                                color: Colors.red, size: 20),
                                                            SizedBox(width: 8),
                                                            Text('Delete'),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Basic information
                                                    if (material.category != null) ...[
                                                      _buildInfoRow('Category', material.category!),
                                                    ],
                                                    if (material.quantity != null && material.unit != null)
                                                      _buildInfoRow(
                                                        'Quantity',
                                                        '${material.quantity} ${material.unit}',
                                                      ),
                                                    if (material.supplier != null)
                                                      _buildInfoRow(
                                                        'Supplier',
                                                        material.supplier!,
                                                        color: Colors.blue.shade700,
                                                      ),

                                                    // Tracking information
                                                    if (material.requiredQuantity != null ||
                                                        material.availableQuantity != null) ...[
                                                      const Divider(),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'Tracking Information',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      if (material.requiredQuantity != null)
                                                        _buildInfoRow(
                                                          'Required',
                                                          '${material.requiredQuantity!.toStringAsFixed(2)} ${material.unit ?? ''}',
                                                        ),
                                                      if (material.availableQuantity != null)
                                                        _buildInfoRow(
                                                          'Available',
                                                          '${material.availableQuantity!.toStringAsFixed(2)} ${material.unit ?? ''}',
                                                        ),
                                                      if (material.missingQuantity > 0)
                                                        _buildInfoRow(
                                                          'Missing',
                                                          '${material.missingQuantity.toStringAsFixed(2)} ${material.unit ?? ''}',
                                                          color: Colors.red,
                                                          isWarning: true,
                                                        ),
                                                      
                                                      // Progress bar
                                                      if (material.requiredQuantity != null &&
                                                          material.requiredQuantity! > 0) ...[
                                                        const SizedBox(height: 12),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    'Availability: ${material.availabilityPercentage.toStringAsFixed(1)}%',
                                                                    style: const TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 4),
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.circular(4),
                                                                    child: LinearProgressIndicator(
                                                                      value: material.availabilityPercentage / 100,
                                                                      minHeight: 8,
                                                                      backgroundColor: Colors.grey[300],
                                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                                        material.availabilityPercentage < 30
                                                                            ? Colors.red
                                                                            : material.availabilityPercentage < 70
                                                                                ? Colors.orange
                                                                                : Colors.green,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    ),
        ),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => _showMaterialDialog(),
              backgroundColor: AppTheme.iosBlue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color, bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black87,
                fontSize: 13,
                fontWeight: isWarning ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = statusFilter == status;
    Color chipColor;
    IconData? icon;

    switch (status) {
      case 'pendiente':
        chipColor = Colors.orange;
        icon = Icons.pending;
        break;
      case 'disponible':
        chipColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'comprado':
        chipColor = Colors.blue;
        icon = Icons.shopping_cart;
        break;
      case 'en_transito':
        chipColor = Colors.purple;
        icon = Icons.local_shipping;
        break;
      default:
        chipColor = Colors.grey;
        icon = Icons.all_inclusive;
    }

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : chipColor),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          statusFilter = selected ? status : null;
        });
      },
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : chipColor.withOpacity(0.5),
        width: 1.5,
      ),
    );
  }
}

