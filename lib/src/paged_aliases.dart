/// Convenience typedefs for the common int-key (page-number) case.
///
/// These let you write `PagedListView<User>` instead of
/// `PaginationListView<int, User>` — less typing for the 80 % use-case.
library;

import '../flutter_pagination_pro.dart';

/// Shorthand for `PaginationController<int, T>` — page-number pagination.
typedef PagedController<T> = PaginationController<int, T>;

/// Shorthand for `PaginationListView<int, T>` — page-number pagination.
typedef PagedListView<T> = PaginationListView<int, T>;

/// Shorthand for `PaginationGridView<int, T>` — page-number pagination.
typedef PagedGridView<T> = PaginationGridView<int, T>;

/// Shorthand for `SliverPaginatedList<int, T>` — page-number pagination.
typedef SliverPagedList<T> = SliverPaginatedList<int, T>;

/// Shorthand for `SliverPaginatedGrid<int, T>` — page-number pagination.
typedef SliverPagedGrid<T> = SliverPaginatedGrid<int, T>;
