/// Flutter Pagination Pro
///
/// A simple yet powerful Flutter pagination package supporting infinite scroll,
/// load more button, and numbered pagination with zero dependencies.
///
/// ## Quick Start
///
/// ### Infinite Scroll
/// ```dart
/// PaginationListView<User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
/// )
/// ```
///
/// ### Load More Button
/// ```dart
/// PaginationListView<User>(
///   paginationType: PaginationType.loadMore,
///   fetchPage: (page) => api.getUsers(page: page),
///   itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
/// )
/// ```
///
/// ### Numbered Pagination
/// ```dart
/// NumberedPaginationView<Product>(
///   totalPages: 50,
///   fetchPage: (page) => api.getProducts(page: page),
///   itemBuilder: (context, product, index) => ProductCard(product: product),
/// )
/// ```
library flutter_pagination_pro;

// TODO: Exports will be added as components are implemented
