part of 'category_bloc.dart';

/// Base class for all possible states emitted by the CategoryBloc.
/// Extending Equatable ensures efficient state comparison.
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => []; // Subclasses override this with relevant data
}

/// State indicating that a category-related operation is currently in progress.
/// Used to show loaders or disable UI interactions temporarily.
class CategoryLoading extends CategoryState {}

/// State representing successful loading of all categories.
/// Typically used to display the list in the UI.
class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;

  const CategoryLoaded(this.categories);

  @override
  List<Object> get props => [categories]; // Enables efficient UI updates when list changes
}

/// State indicating that a category was successfully added, updated, or deleted.
/// Includes the updated category list and a success message for user feedback.
class CategorySuccess extends CategoryState {
  final List<CategoryModel> categories;
  final String message;

  const CategorySuccess({required this.categories, required this.message});

  @override
  List<Object> get props => [categories, message]; // Triggers rebuilds when message/list changes
}

/// State representing a failure in a category operation (e.g., network error, DB failure).
/// Includes a descriptive error message for debugging or user display.
class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message]; // Ensures distinct errors trigger proper UI updates
}
