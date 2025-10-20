import 'package:clean_architecture/domain/entities/role.dart';
import 'package:clean_architecture/domain/entities/user.dart';
import 'package:clean_architecture/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<String, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Intentando iniciar sesión para: $email');
      
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('📧 Respuesta de login: ${response.user?.id}');
      print('📧 Sesión: ${response.session?.accessToken != null ? "Creada" : "No creada"}');

      if (response.user == null) {
        return const Left('Error al iniciar sesión - Usuario no encontrado');
      }

      final user = await _getUserProfile(response.user!.id);
      return user.fold(
        (error) {
          print('❌ Error al obtener perfil: $error');
          return Left(error);
        },
        (userProfile) {
          print('✅ Login exitoso: ${userProfile.fullName}');
          return Right(userProfile);
        },
      );
    } on AuthException catch (e) {
      print('❌ Error de autenticación: ${e.message}');
      print('❌ Código de error: ${e.statusCode}');
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      print('❌ Error inesperado: ${e.toString()}');
      return Left('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, User>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? roleId,
  }) async {
    try {
      print('🔐 Intentando crear cuenta para: $email');
      
      // Registro sin confirmación de email
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role_id': roleId,
        },
        emailRedirectTo: null, // No redirigir para confirmación
      );

      print('📧 Respuesta de Supabase: ${response.user?.id}');
      
      if (response.user == null) {
        return const Left('Error al crear la cuenta - Usuario no creado');
      }

      print('👤 Usuario creado, procediendo con el perfil...');

      // Crear perfil directamente sin esperar confirmación
      final profileResult = await _createUserProfileDirectly(
        response.user!.id, 
        email, 
        fullName, 
        phone, 
        roleId
      );

      if (!profileResult) {
        return const Left('Error al crear el perfil de usuario');
      }

      // Esperar un momento para que la base de datos se actualice
      await Future.delayed(const Duration(milliseconds: 500));

      final user = await _getUserProfile(response.user!.id);
      return user.fold(
        (error) {
          print('❌ Error al obtener perfil: $error');
          return Left(error);
        },
        (userProfile) {
          print('✅ Usuario creado exitosamente: ${userProfile.fullName}');
          return Right(userProfile);
        },
      );
    } on AuthException catch (e) {
      print('❌ Error de autenticación: ${e.message}');
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      print('❌ Error inesperado: ${e.toString()}');
      return Left('Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left('Error al cerrar sesión: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, User?>> getCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      if (session?.user == null) {
        return const Right(null);
      }

      final user = await _getUserProfile(session!.user.id);
      return user.fold(
        (error) => Left(error),
        (userProfile) => Right(userProfile),
      );
    } catch (e) {
      return Left('Error al obtener usuario actual: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(_getAuthErrorMessage(e.message));
    } catch (e) {
      return Left('Error al enviar email de recuperación: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, User>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? roleId,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (roleId != null) updates['role_id'] = roleId;

      final response = await _supabaseClient
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return Right(User.fromJson(response));
    } catch (e) {
      return Left('Error al actualizar perfil: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Role>>> getRoles() async {
    try {
      final response = await _supabaseClient
          .from('roles')
          .select()
          .order('name');

      final roles = response
          .map<Role>((json) => Role.fromJson(json))
          .toList();

      return Right(roles);
    } catch (e) {
      return Left('Error al obtener roles: ${e.toString()}');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((data) {
      if (data.session?.user == null) return null;
      
      // Aquí podrías cargar el perfil completo del usuario
      // Por simplicidad, retornamos null por ahora
      return null;
    });
  }

  Future<Either<String, User>> _getUserProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select('''
            *,
            roles:role_id(name)
          ''')
          .eq('id', userId)
          .single();

      final userData = response;
      if (userData['roles'] != null) {
        userData['role_name'] = userData['roles']['name'];
      }

      return Right(User.fromJson(userData));
    } catch (e) {
      return Left('Error al obtener perfil de usuario: ${e.toString()}');
    }
  }

  Future<bool> _createUserProfileDirectly(String userId, String email, String fullName, String? phone, String? roleId) async {
    try {
      print('👤 Creando perfil directamente para: $userId');
      
      // Si roleId es null o vacío, usar 'administrador' por defecto
      String roleToUse = roleId ?? 'administrador';
      
      // Si roleId es un nombre de rol, obtener el UUID
      if (!roleToUse.contains('-')) { // Si no es un UUID, es un nombre
        final roleResponse = await _supabaseClient
            .from('roles')
            .select('id')
            .eq('name', roleToUse)
            .single();
        
        roleToUse = roleResponse['id'] as String;
        print('🔍 Usando rol: $roleId con ID: $roleToUse');
      }
      
      await _supabaseClient
          .from('profiles')
          .insert({
            'id': userId,
            'email': email,
            'full_name': fullName,
            'phone': phone,
            'role_id': roleToUse,
            'is_active': true,
          });
      
      print('✅ Perfil creado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error al crear perfil: ${e.toString()}');
      return false;
    }
  }

  String _getAuthErrorMessage(String message) {
    // Traducir mensajes de error de Supabase a español
    switch (message.toLowerCase()) {
      case 'invalid login credentials':
        return 'Credenciales de inicio de sesión inválidas';
      case 'email not confirmed':
        return 'Email no confirmado. Revisa tu bandeja de entrada';
      case 'user already registered':
        return 'El usuario ya está registrado';
      case 'password should be at least 6 characters':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'invalid email':
        return 'Email inválido';
      case 'signup is disabled':
        return 'El registro está deshabilitado. Contacta al administrador';
      case 'email address not authorized':
        return 'Esta dirección de email no está autorizada';
      case 'user not found':
        return 'Usuario no encontrado. Verifica tu email';
      case 'invalid password':
        return 'Contraseña incorrecta';
      default:
        return 'Error de autenticación: $message';
    }
  }
}
