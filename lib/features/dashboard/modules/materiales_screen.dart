import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../core/models/material.dart' as model;
import '../../../core/models/role.dart';
import '../../../core/services/material_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/auth_provider.dart';

class MaterialesScreen extends ConsumerStatefulWidget {
  const MaterialesScreen({super.key});

  @override
  ConsumerState<MaterialesScreen> createState() => _MaterialesScreenState();
}

class _MaterialesScreenState extends ConsumerState<MaterialesScreen> {
  List<model.Material> materiales = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMateriales();
  }

  Future<void> _loadMateriales() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      final obraId = authState.obraActual?.id;

      if (obraId == null) {
        setState(() {
          errorMessage = 'No hay obra seleccionada';
          isLoading = false;
        });
        return;
      }

      final materialService = ref.read(materialServiceProvider);
      final result = await materialService.getMateriales(obraId);

      setState(() {
        materiales = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar materiales: $e';
        isLoading = false;
      });
    }
  }

  bool _canEdit() {
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role.type;
    // Admin General y Admin Obra pueden crear/editar/eliminar
    return userRole == RoleType.adminGeneral || userRole == RoleType.adminObra;
  }

  Future<void> _showMaterialDialog({model.Material? material}) async {
    final isEdit = material != null;
    final nombreController = TextEditingController(text: material?.nombre ?? '');
    final categoriaController = TextEditingController(text: material?.categoria ?? '');
    final cantidadController = TextEditingController(text: material?.cantidad ?? '');
    final unidadController = TextEditingController(text: material?.unidad ?? '');
    final proveedorController = TextEditingController(text: material?.proveedor ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Editar Material' : 'Nuevo Material'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoriaController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unidadController,
                decoration: const InputDecoration(labelText: 'Unidad (ej: m3, kg, unidad)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: proveedorController,
                decoration: const InputDecoration(labelText: 'Proveedor'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final authState = ref.read(authProvider);
                final obraId = authState.obraActual?.id;

                if (obraId == null) return;

                final materialService = ref.read(materialServiceProvider);
                final data = {
                  'nombre': nombreController.text,
                  'categoria': categoriaController.text.isNotEmpty ? categoriaController.text : null,
                  'cantidad': cantidadController.text.isNotEmpty ? cantidadController.text : null,
                  'unidad': unidadController.text.isNotEmpty ? unidadController.text : null,
                  'proveedor': proveedorController.text.isNotEmpty ? proveedorController.text : null,
                };

                if (isEdit) {
                  await materialService.updateMaterial(
                    obraId,
                    material.id,
                    data,
                  );
                } else {
                  await materialService.createMaterial(obraId, data);
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
            child: Text(isEdit ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadMateriales();
    }
  }

  Future<void> _deleteMaterial(model.Material material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar "${material.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authState = ref.read(authProvider);
        final obraId = authState.obraActual?.id;

        if (obraId == null) return;

        final materialService = ref.read(materialServiceProvider);
        await materialService.deleteMaterial(obraId, material.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material eliminado')),
          );
        }

        _loadMateriales();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
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
        title: const Text('Materiales'),
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
                            onPressed: _loadMateriales,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : materiales.isEmpty
                      ? const Center(
                          child: Text('No hay materiales registrados'),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadMateriales,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: materiales.length,
                            itemBuilder: (context, index) {
                              final material = materiales[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassContainer(
                                  blur: 15,
                                  opacity: 0.2,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.all(0),
                                  child: ListTile(
                                    title: Text(
                                      material.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (material.categoria != null)
                                          Text(
                                            'Categoría: ${material.categoria}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        if (material.cantidad != null && material.unidad != null)
                                          Text(
                                            'Cantidad: ${material.cantidad} ${material.unidad}',
                                          ),
                                        if (material.proveedor != null)
                                          Text(
                                            'Proveedor: ${material.proveedor}',
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
                                                child: Text('Editar'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Eliminar'),
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
