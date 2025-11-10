import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../core/models/material.dart' as model;
import '../../../core/models/role.dart';
import '../../../core/services/material_service.dart';
import '../../../core/widgets/glass_container.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMaterials();
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

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
                decoration: const InputDecoration(labelText: 'Quantity'),
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
                final data = {
                  'nombre': nameController.text, // Keep backend field name
                  'categoria': categoryController.text.isNotEmpty ? categoryController.text : null,
                  'cantidad': quantityController.text.isNotEmpty ? quantityController.text : null,
                  'unidad': unitController.text.isNotEmpty ? unitController.text : null,
                  'proveedor': supplierController.text.isNotEmpty ? supplierController.text : null,
                };

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
    );

    if (result == true) {
      _loadMaterials();
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
                  : materials.isEmpty
                      ? const Center(
                          child: Text('No materials registered'),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadMaterials,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: materials.length,
                            itemBuilder: (context, index) {
                              final material = materials[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassContainer(
                                  blur: 15,
                                  opacity: 0.2,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.all(0),
                                  child: ListTile(
                                    title: Text(
                                      material.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (material.category != null)
                                          Text(
                                            'Category: ${material.category}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        if (material.quantity != null && material.unit != null)
                                          Text(
                                            'Quantity: ${material.quantity} ${material.unit}',
                                          ),
                                        if (material.supplier != null)
                                          Text(
                                            'Supplier: ${material.supplier}',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: canEdit
                                        ? PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showMaterialDialog(material: material);
                                              } else if (value == 'delete') {
                                                _deleteMaterial(material);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
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
}

