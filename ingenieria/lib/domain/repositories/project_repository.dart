import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/project.dart';

/// Repository interface for project operations.
abstract class ProjectRepository {
  /// Get all projects
  Future<Either<Failure, List<Project>>> getProjects();

  /// Get a specific project by ID
  Future<Either<Failure, Project>> getProjectById(String id);

  /// Get projects assigned to the current user
  Future<Either<Failure, List<Project>>> getUserProjects();

  /// Create a new project
  Future<Either<Failure, Project>> createProject(Project project);

  /// Update a project
  Future<Either<Failure, Project>> updateProject(Project project);

  /// Delete a project
  Future<Either<Failure, void>> deleteProject(String id);
}
