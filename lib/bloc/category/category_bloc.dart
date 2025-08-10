// Importing necessary modules
import 'package:dedo/models/category_model.dart'; // Data model for Category
import 'package:dedo/repositories/category_repository.dart'; // Handles DB operations for categories
import 'package:equatable/equatable.dart'; // Provides value equality for objects
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC (Business Logic Component) package for state management

// Separating the event and state definitions into different parts of the file
part 'category_event.dart';
part 'category_state.dart';

/// CategoryBloc manages category-related states and events using the BLoC pattern.
/// It responds to category events by fetching, adding, updating, or deleting categories.
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository
  categoryRepo; // Dependency to interact with data source

  /// Constructor initializes the bloc with a default state and registers event handlers.
  CategoryBloc(this.categoryRepo) : super(CategoryLoading()) {
    // Register event handlers with corresponding methods
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  /// Handles LoadCategories event.
  /// Purpose: Fetches all categories from the repository.
  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading()); // Emit loading state to show progress
    try {
      final categories =
          await categoryRepo.getAllCategories(); // Fetch categories
      emit(
        CategoryLoaded(categories),
      ); // Emit loaded state with fetched categories
    } catch (e) {
      emit(CategoryError(e.toString())); // Emit error state on failure
    }
  }

  /// Handles AddCategory event.
  /// Purpose: Inserts a new category and then emits the updated list.
  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading()); // Start with loading state
    try {
      await categoryRepo.insertCategory(event.category); // Insert new category
      final categories =
          await categoryRepo.getAllCategories(); // Re-fetch updated list
      emit(
        CategorySuccess(
          categories: categories,
          message: 'Category added successfully', // Helpful user message
        ),
      );
    } catch (e) {
      emit(CategoryError(e.toString())); // Emit error with exception details
    }
  }

  /// Handles UpdateCategory event.
  /// Purpose: Updates an existing category and emits the updated list.
  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading()); // Indicate loading
    try {
      await categoryRepo.updateCategory(event.category); // Update the category
      final categories =
          await categoryRepo.getAllCategories(); // Fetch updated categories
      emit(
        CategorySuccess(
          categories: categories,
          message: 'Category updated successfully',
        ),
      );
    } catch (e) {
      emit(CategoryError(e.toString())); // Handle and emit error
    }
  }

  /// Handles DeleteCategory event.
  /// Purpose: Deletes a category by its ID and emits the updated list.
  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading()); // Start with loading state
    try {
      await categoryRepo.deleteCategory(
        event.categoryId,
      ); // Delete category by ID
      final categories =
          await categoryRepo.getAllCategories(); // Re-fetch updated list
      emit(
        CategorySuccess(
          categories: categories,
          message: 'Category deleted successfully',
        ),
      );
    } catch (e) {
      emit(CategoryError(e.toString())); // Emit error on failure
    }
  }
}
