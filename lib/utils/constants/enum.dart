// Enum to filter tasks based on their status
enum TaskFilter {
  all,        // Show all tasks
  pending,    // Show only tasks that are not completed
  completed   // Show only tasks that are completed
}

// Enum to define sorting options for task list
enum SortOption {
  newest,     // Sort by newest first
  oldest,     // Sort by oldest first
  titleAsc,   // Sort by title in ascending order (A-Z)
  titleDesc   // Sort by title in descending order (Z-A)
}
