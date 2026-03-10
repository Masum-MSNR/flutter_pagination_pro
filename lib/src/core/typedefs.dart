/// Type definitions for Flutter Pagination Pro
library;

import 'dart:async';
import 'package:flutter/widgets.dart';

/// Callback to fetch a page of items.
///
/// [pageKey] identifies the page to fetch. For integer-based pagination this
/// is the page number (e.g. 1, 2, 3). For cursor-based APIs it might be a
/// String token or document snapshot.
///
/// Returns a [FutureOr] of list of items for that page.
/// Return an empty list to indicate end of data.
typedef FetchPage<K, T> = FutureOr<List<T>> Function(K pageKey);

/// Computes the next page key from the current key and loaded items.
///
/// Used by [PaginationController] to determine the next page to fetch.
///
/// Examples:
/// - Integer pages: `(page, _) => page + 1`
/// - Offset-based: `(offset, items) => offset + items.length`
/// - Cursor-based: `(_, items) => items.last.cursor`
typedef NextPageKeyBuilder<K, T> = K Function(K currentKey, List<T> items);

/// Callback to build an item widget.
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

/// Callback for building a loading indicator widget.
typedef LoadingBuilder = Widget Function(BuildContext context);

/// Callback for building an error widget with retry functionality.
typedef ErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  VoidCallback retry,
);

/// Callback for building an empty state widget.
typedef EmptyBuilder = Widget Function(BuildContext context);

/// Callback for building an end of list widget.
typedef EndOfListBuilder = Widget Function(BuildContext context);

/// Callback for building a load more button.
typedef LoadMoreBuilder = Widget Function(
  BuildContext context,
  VoidCallback loadMore,
  bool isLoading,
);

/// Callback when a page is successfully loaded.
///
/// [pageKey] is the key of the page that was loaded.
/// [items] contains only the **new** items loaded on that page,
/// not the full accumulated list.
typedef OnPageLoaded<K, T> = void Function(K pageKey, List<T> items);

/// Callback when an error occurs.
typedef OnError = void Function(Object error);

/// Callback when page changes (for numbered pagination).
typedef OnPageChanged = void Function(int page);

/// Callback for building a separator between items.
typedef SeparatorBuilder = Widget Function(BuildContext context, int index);
