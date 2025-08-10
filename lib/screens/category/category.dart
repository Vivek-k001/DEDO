import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/models/category_model.dart';
import 'package:dedo/screens/category/widgets/all_category_list_section.dart';
import 'package:dedo/utils/constants/colors.dart';
import 'package:dedo/utils/constants/sizes.dart';
import 'package:dedo/utils/helper_functions.dart';
import 'package:dedo/widgets/appbar.dart';
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
  // Controller for the category name input field
  final _nameController = TextEditingController();

  // Initially selected color for the category, default to first color
  Color _selectedColor = DColors.categoryColors.first;

  @override
  void initState() {
    super.initState();
    // Load existing categories when screen initializes
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    // Dispose the controller to free resources
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        // Show snackbar on error state
        if (state is CategoryError) {
          DHelperFunctions.showSnackBar(
            title: "Error",
            message: state.message,
            icon: Icons.error,
            context: context,
            bgColor: Colors.red,
          );
        }
        // Show snackbar on success state
        if (state is CategorySuccess) {
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
        // Custom app bar with back arrow and title
        appBar: DAppBar(
          showBackArrow: true,
          title: Text(
            'Categories',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(DSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input field for category title
              DTextFormField(
                title: "Title",
                hintText: "Enter your title",
                prefixIcon: Icons.title,
                controller: _nameController,
                suffixIcon:
                    _nameController.text.isNotEmpty ? Icons.clear : null,
                onIconPressed: () {
                  // Clear input and reset color selection when suffix icon pressed
                  _nameController.clear();
                  setState(() => _selectedColor = DColors.categoryColors.first);
                },
              ),

              const SizedBox(height: DSizes.spaceBtwItems),

              // Label for color selection
              Text(
                'Color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: DSizes.sm),

              // Color options displayed as selectable circles
              Wrap(
                spacing: 8,
                children:
                    DColors.categoryColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          // Update selected color on tap
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: DSizes.sm),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: color,
                            // Show check icon if this color is selected
                            child:
                                _selectedColor.toARGB32() == color.toARGB32()
                                    ? Icon(
                                      Icons.done,
                                      color: Colors.black,
                                      size: DSizes.iconSm,
                                    )
                                    : null,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: DSizes.spaceBtwSections),

              // Button to add a new category
              Center(
                child: DButton(
                  btnTitle: 'Add Category',
                  width: 160,
                  height: 50,
                  onTap: () => _addCategory(),
                ),
              ),
              const SizedBox(height: DSizes.spaceBtwSections),

              // Header for the categories list
              Center(
                child: const Text(
                  'Your Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: DSizes.sm),

              // Expanded widget to hold the categories list
              DAllCategoryListSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Function to add a new category after validating input
  void _addCategory() {
    // Show error snackbar if category name is empty
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

    // Create new category model
    final category = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      color: _selectedColor.toARGB32(),
    );

    // Dispatch event to add category
    context.read<CategoryBloc>().add(AddCategory(category));

    // Clear the input field after adding
    _nameController.clear();
  }
}
