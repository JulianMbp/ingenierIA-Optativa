import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/supabase_material_repository.dart';
import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';
import 'auth_provider.dart';
import 'service_providers.dart';

/// Provider for MaterialRepository
final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider).client;
  return SupabaseMaterialRepository(supabase);
});

/// Stream provider for materials with real-time updates
final materialsStreamProvider =
    StreamProvider.autoDispose.family<List<Material>, String>((ref, obraId) {
  final repository = ref.watch(materialRepositoryProvider);
  return repository.watchMaterialsByObra(obraId);
});

/// Provider to get materials for current obra
final currentObraMaterialsProvider =
    StreamProvider.autoDispose<List<Material>>((ref) {
  final authState = ref.watch(authProvider);
  final obraId = authState.user?.obraId;

  if (obraId == null || obraId.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(materialRepositoryProvider);
  return repository.watchMaterialsByObra(obraId);
});

/// Provider for low stock materials
final lowStockMaterialsProvider =
    FutureProvider.autoDispose<List<Material>>((ref) async {
  final authState = ref.watch(authProvider);
  final obraId = authState.user?.obraId;

  if (obraId == null || obraId.isEmpty) {
    return [];
  }

  final repository = ref.watch(materialRepositoryProvider);
  return repository.getLowStockMaterials(obraId);
});

/// State class for material operations
class MaterialState {
  final bool isLoading;
  final String? error;
  final Material? selectedMaterial;

  const MaterialState({
    this.isLoading = false,
    this.error,
    this.selectedMaterial,
  });

  MaterialState copyWith({
    bool? isLoading,
    String? error,
    Material? selectedMaterial,
  }) {
    return MaterialState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedMaterial: selectedMaterial ?? this.selectedMaterial,
    );
  }
}

/// Notifier for material operations
class MaterialNotifier extends StateNotifier<MaterialState> {
  final MaterialRepository _repository;

  MaterialNotifier(this._repository) : super(const MaterialState());

  /// Create a new material
  Future<void> createMaterial(Material material) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createMaterial(material);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update an existing material
  Future<void> updateMaterial(Material material) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateMaterial(material);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete a material
  Future<void> deleteMaterial(String materialId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteMaterial(materialId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Select a material for viewing/editing
  void selectMaterial(Material? material) {
    state = state.copyWith(selectedMaterial: material);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for material operations
final materialNotifierProvider =
    StateNotifierProvider<MaterialNotifier, MaterialState>((ref) {
  final repository = ref.watch(materialRepositoryProvider);
  return MaterialNotifier(repository);
});
