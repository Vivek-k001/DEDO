import 'package:dedo/bloc/categories/categories_bloc.dart';
import 'package:dedo/bloc/categories/categories_event.dart';
import 'package:dedo/bloc/categories/categories_state.dart';
import 'package:dedo/models/category_model.dart';
import 'package:dedo/screens/category/widgets/category_item.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = DColors.categoryColors.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addCategory() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name is required')),
      );
      return;
    }

    final category = Category(
      id: DateTime.now().toString(),
      name: _nameController.text,
      color: _selectedColor.value,
    );

    context.read<CategoryBloc>().add(AddCategory(category));
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Color:'),
            const SizedBox(height: 8),
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
            const SizedBox(height: 16),
            Center(
              child: DButton(
                btnTitle: 'Add Category',
                width: 140,
                height: 50,
                onTap: () => _addCategory(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Your Categories:'),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CategoryLoaded) {
                    return ListView.builder(
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
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
                    return const Center(child: Text('Unexpected state'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
