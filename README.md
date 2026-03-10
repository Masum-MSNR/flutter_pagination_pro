<p align="center">
  <img src="https://raw.githubusercontent.com/Masum-MSNR/flutter_pagination_pro/main/images/logo.png" alt="Flutter Pagination Pro" width="120"/>
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_pagination_pro"><img src="https://img.shields.io/pub/v/flutter_pagination_pro" alt="Pub Version"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter" alt="Flutter"></a>
</p>

<p align="center">
A lightweight, <b>zero-dependency</b> Flutter pagination package.<br/>
Infinite scroll, load more, grid, slivers, numbered pages — all in one.
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Masum-MSNR/flutter_pagination_pro/main/images/preview.png" alt="Flutter Pagination Pro Preview" width="700"/>
</p>

## Why This Package?

| Feature | flutter_pagination_pro | infinite_scroll_pagination |
|---------|:---------------------:|:--------------------------:|
| Zero dependencies | ✅ | ❌ (sliver_tools) |
| Generic page keys (int/cursor/offset) | ✅ | ✅ |
| ListView + GridView | ✅ | ✅ |
| Sliver variants | ✅ | ✅ |
| Numbered pagination | ✅ | ❌ |
| Load more button mode | ✅ | ❌ |
| Controlled mode (BYO state) | ✅ `.controlled()` | ❌ |
| `updateFetchPage` (search/filter) | ✅ | ❌ |
| Pull-to-refresh | ✅ built-in | Manual |
| `initialItems` (cache-first) | ✅ | ❌ |
| `pageSize` auto last-page | ✅ | ❌ |
| `totalItems` tracking | ✅ | ❌ |
| `findChildIndexCallback` | ✅ | ✅ |
| Separator support | ✅ | ✅ |
| Item mutation helpers | ✅ (`updateItems`, `removeWhere`, `insertItem`) | ❌ |
| Type-safe generics | ✅ | ✅ |
| Accessibility (semantics) | ✅ | Partial |

## Quick Start

```yaml
dependencies:
  flutter_pagination_pro: ^0.3.0
```

### 4 Lines to Paginated List

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
)
```

That's it. No `initialPageKey`, no extra type parameter. Handles loading, errors, empty state, and infinite scroll automatically.

> `PagedListView<T>` is a shorthand for `PaginationListView<int, T>` with `initialPageKey` defaulting to `1`. Same for `PagedGridView<T>`, `PagedController<T>`, `SliverPagedList<T>`, `SliverPagedGrid<T>`.

### Cursor-Based (e.g. Firestore, GraphQL)

```dart
PaginationListView<String, User>(
  fetchPage: (cursor) => api.getUsers(cursor: cursor),
  initialPageKey: '',
  nextPageKeyBuilder: (_, items) => items.last.cursor,
  itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
)
```

## All Modes

```dart
// Grid
PagedGridView<Photo>(
  fetchPage: (page) => api.getPhotos(page: page),
  itemBuilder: (context, photo, index) => PhotoCard(photo: photo),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
)

// Load More Button
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserCard(user: user),
  paginationType: PaginationType.loadMore,
)

// Controlled Mode (BYO state)
PaginationListView<int, User>.controlled(
  items: users,
  status: PaginationStatus.loaded,
  onLoadMore: () => bloc.add(LoadNextPage()),
  itemBuilder: (context, user, index) => UserCard(user: user),
)

// Numbered Pagination
NumberedPagination(
  totalPages: 20,
  currentPage: _page,
  onPageChanged: (page) => setState(() => _page = page),
)
```

## Slivers (CustomScrollView)

```dart
CustomScrollView(
  controller: scrollController,
  slivers: [
    SliverAppBar(title: Text('Users'), floating: true),
    SliverPaginatedList<int, User>(
      controller: controller,
      scrollController: scrollController,
      itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
    ),
  ],
)
```

`SliverPaginatedGrid` works the same way — just add a `gridDelegate`.

## Controller

```dart
final controller = PagedController<User>(
  fetchPage: (page) => api.getUsers(page: page),
  config: PaginationConfig(pageSize: 20),  // auto-detects last page
  initialItems: cachedUsers,                // show cached data instantly
);

// Use with widget
PagedListView<User>.withController(
  controller: controller,
  itemBuilder: (context, user, index) => UserTile(user: user),
)

// Search / filter: swap the data source at runtime
controller.updateFetchPage(
  (page) => api.searchUsers(page: page, query: 'john'),
);
```

| Method | Description |
|--------|-------------|
| `refresh()` | Reload from first page (items stay visible) |
| `retry()` | Retry last failed request |
| `reset()` | Clear everything to initial state |
| `loadNextPage()` | Manually trigger next page |
| `updateFetchPage(fn)` | Replace data source + reload (search/filter) |
| `setTotalItems(n)` | Set total for "Showing X of Y" + auto-complete |
| `updateItems(fn)` | Transform items in-place |
| `removeWhere(fn)` | Remove matching items |
| `insertItem(i, item)` | Insert at index |
| `removeItemAt(i)` | Remove at index |
| `updateItemAt(i, item)` | Replace item at index |

| Property | Type | Description |
|----------|------|-------------|
| `items` | `List<T>` | All loaded items |
| `currentPageKey` | `K?` | Last loaded page key |
| `initialPageKey` | `K` | First page key |
| `status` | `PaginationStatus` | Current state |
| `hasMorePages` | `bool` | More pages available? |
| `state.totalItems` | `int?` | Total from API (if set) |

## Customization

Override any state widget:

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  firstPageLoadingBuilder: (context) => MyShimmer(),
  firstPageErrorBuilder: (context, error, retry) => MyErrorWidget(error, retry),
  emptyBuilder: (context) => MyEmptyState(),
  loadMoreLoadingBuilder: (context) => MyLoadingSpinner(),
  loadMoreErrorBuilder: (context, error, retry) => MyRetryBar(error, retry),
  endOfListBuilder: (context) => Text('All caught up!'),
  enablePullToRefresh: true,
  separatorBuilder: (context, index) => Divider(),
)
```

## Configuration

### PaginationConfig

| Param | Default | Description |
|-------|---------|-------------|
| `scrollThreshold` | `200.0` | Pixels from bottom to trigger load |
| `autoLoadFirstPage` | `true` | Auto-load on build |
| `pageSize` | `null` | Items per page — auto-detects last page |

### NumberedPaginationConfig

| Param | Default | Description |
|-------|---------|-------------|
| `buttonSize` | `40` | Page button size |
| `spacing` | `4` | Button spacing |
| `borderRadius` | `8` | Button border radius |
| `showFirstLastButtons` | `true` | Show ⏮ ⏭ buttons |
| `showNavigationButtons` | `true` | Show ◀ ▶ buttons |
| `selectedButtonColor` | `primary` | Active page color |

## Example

See the [example](example/) app for a complete demo with all modes.

## License

MIT — see [LICENSE](LICENSE).