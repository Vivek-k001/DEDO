import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/models/category_model.dart';
import 'package:dedo/screens/category/widgets/category_item.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/button.dart';
import 'package:dedo/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameController = TextEditingController();

  Color _selectedColor = DColors.categoryColors.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryError) {
          DHelperFunctions.showSnackBar(
            title: "Error",
            message: state.message,
            icon: Icons.error,
            context: context,
            bgColor: Colors.red,
          );
        } else if (state is CategorySuccess) {
          DHelperFunctions.showSnackBar(
            title: "Success",
            message: state.message,
            icon: Icons.check_circle,
            context: context,
            bgColor: Colors.green,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(DSizes.md),
          child: Column(
            children: [
              DTextFormField(
                title: "Title",
                hintText: "Enter your title",
                prefixIcon: Icons.title,
                controller: _nameController,
                suffixIcon: Icons.clear,
                onIconPressed: () {
                  _nameController.clear();
                  setState(() => _selectedColor = DColors.categoryColors.first);
                },
              ),

              const SizedBox(height: DSizes.spaceBtwItems),

              const Text('Select Color:'),

              const SizedBox(height: DSizes.sm),

              Wrap(
                spacing: 8,
                children:
                    DColors.categoryColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border:
                                _selectedColor == color
                                    ? Border.all(color: Colors.black, width: 2)
                                    : null,
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: DSizes.spaceBtwSections),

              Center(
                child: DButton(
                  btnTitle: 'Add Category',
                  width: 140,
                  height: 50,
                  onTap: () => _addCategory(),
                ),
              ),

              const SizedBox(height: DSizes.spaceBtwSections),

              const Text(
                'Your Categories:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: DSizes.sm),

              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CategoryLoaded ||
                        state is CategorySuccess) {
                      final categories =
                          (state is CategoryLoaded)
                              ? state.categories
                              : (state as CategorySuccess).categories;

                      if (categories.isEmpty) {
                        return const Center(
                          child: Text('No categories added yet'),
                        );
                      }

                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryItem(
                            category: category,
                            onDelete: () {
                              context.read<CategoryBloc>().add(
                                DeleteCategory(category.id),
                              );
                            },
                          );
                        },
                      );
                    } else if (state is CategoryError) {
                      return Center(child: Text(state.message));
                    } else {
                      return const Center(child: Text('No categories found'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addCategory() {
    if (_nameController.text.isEmpty) {
      DHelperFunctions.showSnackBar(
        title: "Error",
        message: "Category name is required",
        icon: Icons.error,
        context: context,
        bgColor: Colors.red,
      );
      return;
    }

    final category = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      color: _selectedColor.value,
    );

    context.read<CategoryBloc>().add(AddCategory(category));
  }
}
