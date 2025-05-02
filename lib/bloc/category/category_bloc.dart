import 'package:dedo/models/category_model.dart';
import 'package:dedo/repositories/category_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepo;

  CategoryBloc(this.categoryRepo) : super(CategoryLoading()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);

    add(LoadCategories());
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await categoryRepo.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await categoryRepo.insertCategory(event.category);
      final categories = await categoryRepo.getAllCategories();
      emit(
        CategorySuccess(
          categories: categories,
          message: 'Category added successfully',
        ),
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await categoryRepo.updateCategory(event.category);
      final categories = await categoryRepo.getAllCategories();
      emit(
        CategorySuccess(
          categories: categories,
          message: 'Category updated successfully',
        ),
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await categoryRepo.deleteCategory(event.categoryId);
      final categories = await categoryRepo.getAllCategories();
      emit(
        CategorySuccess(
          categories: categories,
          message: 'Category deleted successfully',
        ),
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
