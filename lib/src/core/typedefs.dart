/// Type definitions for Flutter Pagination Pro
library;

import 'dart:async';
import 'package:flutter/widgets.dart';

/// Callback to fetch a page of items.
///
/// [page] is the page number (1-indexed).
/// Returns a [FutureOr] of list of items for that page.
/// Return an empty list to indicate end of data.
typedef FetchPage<T> = FutureOr<List<T>> Function(int page);

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
typedef OnPageLoaded<T> = void Function(int page, List<T> items);

/// Callback when an error occurs.
typedef OnError = void Function(Object error);

/// Callback when page changes (for numbered pagination).
typedef OnPageChanged = void Function(int page);

/// Callback for building a separator between items.
typedef SeparatorBuilder = Widget Function(BuildContext context, int index);
