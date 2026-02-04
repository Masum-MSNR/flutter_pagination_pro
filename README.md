# Flutter Pagination Pro

A lightweight Flutter pagination package with **zero dependencies**. Supports infinite scroll, load more button, and numbered pagination.

## Installation

```yaml
dependencies:
  flutter_pagination_pro: ^0.0.1
```

## Quick Start

### Infinite Scroll

```dart
PaginationListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
)
```

### Load More Button

```dart
PaginationListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
  paginationType: PaginationType.loadMore,
)
```

### Grid View

```dart
PaginationGridView<Photo>(
  fetchPage: (page) => api.getPhotos(page: page),
  itemBuilder: (context, photo, index) => PhotoCard(photo: photo),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
)
```

### Numbered Pagination

```dart
NumberedPagination(
  totalPages: 20,
  currentPage: _page,
  onPageChanged: (page) => setState(() => _page = page),
)
```

## Using Controller

For programmatic control (refresh, retry, access state):

```dart
final controller = PaginationController<User>(
  fetchPage: (page) => api.getUsers(page: page),
);

// In widget
PaginationListView<User>.withController(
  controller: controller,
  itemBuilder: (context, user, index) => UserTile(user: user),
)

// Programmatic control
controller.refresh();
controller.retry();
controller.reset();

// Don't forget to dispose
controller.dispose();
```

## Parameters

### PaginationListView / PaginationGridView

| Parameter | Type | Description |
|-----------|------|-------------|
| `fetchPage` | `FetchPage<T>` | Function to fetch items for a page (required) |
| `itemBuilder` | `ItemBuilder<T>` | Builds widget for each item (required) |
| `paginationType` | `PaginationType` | `infiniteScroll` (default) or `loadMore` |
| `config` | `PaginationConfig` | Pagination settings |
| `separatorBuilder` | `SeparatorBuilder?` | Separator between items (ListView only) |
| `scrollController` | `ScrollController?` | Custom scroll controller |
| `firstPageLoadingBuilder` | `LoadingBuilder?` | Custom first page loading widget |
| `loadMoreLoadingBuilder` | `LoadingBuilder?` | Custom load more indicator |
| `firstPageErrorBuilder` | `ErrorBuilder?` | Custom first page error widget |
| `loadMoreErrorBuilder` | `ErrorBuilder?` | Custom load more error widget |
| `emptyBuilder` | `EmptyBuilder?` | Custom empty state widget |
| `endOfListBuilder` | `EndOfListBuilder?` | Custom end of list widget |
| `loadMoreButtonBuilder` | `LoadMoreBuilder?` | Custom load more button |
| `onPageLoaded` | `OnPageLoaded<T>?` | Callback when page loads |
| `onError` | `OnError?` | Callback on error |

### PaginationConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pageSize` | `int` | `20` | Items per page |
| `firstPage` | `int` | `1` | First page number |
| `invisibleItemsThreshold` | `int` | `3` | Items before end to trigger load |
| `autoLoadFirstPage` | `bool` | `true` | Auto load first page on init |

### NumberedPagination

| Parameter | Type | Description |
|-----------|------|-------------|
| `totalPages` | `int` | Total number of pages (required) |
| `currentPage` | `int` | Current active page (required) |
| `onPageChanged` | `OnPageChanged` | Callback when page changes (required) |
| `visiblePages` | `int` | Number of visible page buttons (default: 5) |
| `showFirstLastButtons` | `bool` | Show first/last buttons (default: true) |
| `showPrevNextButtons` | `bool` | Show prev/next buttons (default: true) |

### PaginationController

| Method | Description |
|--------|-------------|
| `loadFirstPage()` | Load the first page |
| `loadNextPage()` | Load the next page |
| `refresh()` | Reload from first page |
| `retry()` | Retry failed request |
| `reset()` | Reset to initial state |

| Property | Type | Description |
|----------|------|-------------|
| `state` | `PaginationState<T>` | Current pagination state |
| `items` | `List<T>` | Loaded items |
| `status` | `PaginationStatus` | Current status |
| `hasMorePages` | `bool` | Whether more pages exist |
| `currentPage` | `int` | Current page number |

## Customization

```dart
PaginationListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  
  // Custom loading
  firstPageLoadingBuilder: (context) => Center(child: MyLoader()),
  loadMoreLoadingBuilder: (context) => MySmallLoader(),
  
  // Custom error handling
  firstPageErrorBuilder: (context, error, retry) => Column(
    children: [
      Text('Error: $error'),
      ElevatedButton(onPressed: retry, child: Text('Retry')),
    ],
  ),
  
  // Custom empty state
  emptyBuilder: (context) => Center(child: Text('No items found')),
  
  // Custom load more button
  loadMoreButtonBuilder: (context, loadMore, isLoading) => ElevatedButton(
    onPressed: isLoading ? null : loadMore,
    child: Text(isLoading ? 'Loading...' : 'Load More'),
  ),
)
```

## License

MIT License - see [LICENSE](LICENSE) for details.
