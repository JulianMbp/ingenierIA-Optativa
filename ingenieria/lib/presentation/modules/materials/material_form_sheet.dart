import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/material.dart' as entities;
import '../../providers/auth_provider.dart';
import '../../providers/material_provider.dart';

/// Glass-style modal sheet for adding/editing materials
class MaterialFormSheet extends ConsumerStatefulWidget {
  final entities.Material? material;

  const MaterialFormSheet({
    super.key,
    this.material,
  });

  @override
  ConsumerState<MaterialFormSheet> createState() => _MaterialFormSheetState();
}

class _MaterialFormSheetState extends ConsumerState<MaterialFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _supplierController;

  String _selectedStatus = 'ordered';
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'ordered',
    'received',
    'in_use',
    'depleted',
  ];

  final List<String> _unitOptions = [
    'kg',
    'm3',
    'm2',
    'm',
    'units',
    'bags',
    'boxes',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.material?.description ?? '');
    _quantityController =
        TextEditingController(text: widget.material?.quantity.toString() ?? '');
    _unitController = TextEditingController(text: widget.material?.unit ?? 'units');
    _unitPriceController =
        TextEditingController(text: widget.material?.unitPrice?.toString() ?? '');
    _supplierController =
        TextEditingController(text: widget.material?.supplier ?? '');
    _selectedStatus = widget.material?.status ?? 'ordered';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _unitPriceController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.material != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.9),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          isEditing ? 'Edit Material' : 'Add Material',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        if (isEditing)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: AppTheme.errorColor,
                            onPressed: _confirmDelete,
                          ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Form
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Material Name',
                            hint: 'e.g., Cement, Steel bars',
                            icon: Icons.label_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter material name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Description (Optional)',
                            hint: 'Add details about the material',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _quantityController,
                                  label: 'Quantity',
                                  hint: '0',
                                  icon: Icons.inventory_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildUnitDropdown(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _unitPriceController,
                            label: 'Unit Price (Optional)',
                            hint: '0.00',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _supplierController,
                            label: 'Supplier (Optional)',
                            hint: 'Supplier name',
                            icon: Icons.business_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildStatusDropdown(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(isEditing),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _unitOptions.contains(_unitController.text)
          ? _unitController.text
          : 'units',
      decoration: InputDecoration(
        labelText: 'Unit',
        prefixIcon: const Icon(Icons.straighten),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      isExpanded: true, // Fix overflow issue
      items: _unitOptions
          .map((unit) => DropdownMenuItem(
                value: unit,
                child: Text(unit),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          _unitController.text = value;
        }
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        prefixIcon: const Icon(Icons.info_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      items: _statusOptions
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.replaceAll('_', ' ').toUpperCase()),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator()
          : Text(
              isEditing ? 'Update Material' : 'Add Material',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      final obraId = authState.user?.obraId;
      final userId = authState.user?.id;

      if (obraId == null) {
        throw Exception('No obra selected');
      }

      final material = entities.Material(
        id: widget.material?.id ?? const Uuid().v4(),
        projectId: obraId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        unit: _unitController.text,
        quantity: double.parse(_quantityController.text),
        unitPrice: _unitPriceController.text.isEmpty
            ? null
            : double.parse(_unitPriceController.text),
        supplier: _supplierController.text.trim().isEmpty
            ? null
            : _supplierController.text.trim(),
        registrationDate: widget.material?.registrationDate ?? DateTime.now(),
        registeredBy: widget.material?.registeredBy ?? userId,
        status: _selectedStatus,
        updatedAt: DateTime.now(),
      );

      final notifier = ref.read(materialNotifierProvider.notifier);

      if (widget.material != null) {
        await notifier.updateMaterial(material);
      } else {
        await notifier.createMaterial(material);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.material != null
                  ? 'Material updated successfully'
                  : 'Material added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content:
            const Text('Are you sure you want to delete this material?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.material != null) {
      await _deleteMaterial();
    }
  }

  Future<void> _deleteMaterial() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(materialNotifierProvider.notifier);
      await notifier.deleteMaterial(widget.material!.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting material: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
