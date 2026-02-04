/// Flutter Pagination Pro - A comprehensive pagination package for Flutter
///
/// Supports three pagination modes:
/// - **Infinite Scroll**: Automatically loads more when scrolling near the end
/// - **Load More Button**: Shows a button to manually load more items
/// - **Numbered Pagination**: Traditional page number navigation
///
/// ## Quick Start
///
/// ### Infinite Scroll (default)
///
/// ```dart
/// import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';
///
/// PaginationListView<User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
/// )
/// ```
///
/// ### Load More Button
///
/// ```dart
/// PaginationListView<Product>(
///   fetchPage: (page) => api.getProducts(page: page),
///   itemBuilder: (context, product, index) => ProductCard(product: product),
///   paginationType: PaginationType.loadMore,
/// )
/// ```
///
/// ### Grid View
///
/// ```dart
/// PaginationGridView<Photo>(
///   fetchPage: (page) => api.getPhotos(page: page),
///   itemBuilder: (context, photo, index) => PhotoTile(photo: photo),
///   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
/// )
/// ```
///
/// ### Numbered Pagination
///
/// ```dart
/// NumberedPagination(
///   totalPages: 20,
///   currentPage: _currentPage,
///   onPageChanged: (page) => setState(() => _currentPage = page),
/// )
/// ```
///
/// ## Features
///
/// - **Zero dependencies** - Pure Flutter implementation
/// - **Simple API** - Easy to use with sensible defaults
/// - **Fully customizable** - Override any widget
/// - **Type-safe** - Generic type support
/// - **Robust** - Handles loading, errors, empty states
/// - **Programmatic control** - Use controller for refresh, retry, etc.
library;

// Core
export 'src/core/pagination_controller.dart';
export 'src/core/pagination_config.dart';
export 'src/core/pagination_state.dart';
export 'src/core/pagination_status.dart';
export 'src/core/typedefs.dart';

// Scroll-based pagination
export 'src/scroll/pagination_list_view.dart';
export 'src/scroll/pagination_grid_view.dart';

// Numbered pagination
export 'src/numbered/numbered_pagination.dart';

// Default widgets (for customization reference)
export 'src/widgets/default_loading.dart';
export 'src/widgets/default_error.dart';
export 'src/widgets/default_empty.dart';
export 'src/widgets/default_end_of_list.dart';
export 'src/widgets/default_load_more.dart';
