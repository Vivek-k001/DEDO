part of 'category_bloc.dart';

/// Base class for all category-related events in the BLoC.
/// Using Equatable allows efficient comparison of event instances.
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => []; // Default empty props — overridden by subclasses
}

/// Event to trigger loading all categories from the repository.
/// Typically dispatched when initializing the category view.
class LoadCategories extends CategoryEvent {}

/// Event to trigger insertion of a new category.
/// Carries the [CategoryModel] object to be added.
class AddCategory extends CategoryEvent {
  final CategoryModel category;

  const AddCategory(this.category);

  @override
  List<Object> get props => [category]; // Enables value comparison for deduplication
}

/// Event to update an existing category with new data.
/// Expects the complete updated [CategoryModel] object.
class UpdateCategory extends CategoryEvent {
  final CategoryModel category;

  const UpdateCategory(this.category);

  @override
  List<Object> get props => [category]; // Ensures updates trigger state change when needed
}

/// Event to delete a category based on its unique [categoryId].
/// Only the ID is required, not the full model.
class DeleteCategory extends CategoryEvent {
  final String categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId]; // Tracks the specific item to remove
}
