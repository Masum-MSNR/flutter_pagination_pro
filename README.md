<p align="center">
  <img src="https://raw.githubusercontent.com/Masum-MSNR/flutter_pagination_pro/main/images/logo.png" alt="Flutter Pagination Pro" width="120"/>
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_pagination_pro"><img src="https://img.shields.io/pub/v/flutter_pagination_pro" alt="Pub Version"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter" alt="Flutter"></a>
</p>

<p align="center">
A lightweight, zero-dependency Flutter pagination package.<br/>
Infinite scroll · load more · grid · slivers · numbered pages · bidirectional — all in one.
</p>

## Install

```yaml
dependencies:
  flutter_pagination_pro: ^1.0.0
```

## Quick Start

```dart
// Infinite scroll list — handles loading, errors, empty state automatically
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
)
```

> **Typedefs:** `PagedListView<T>` = `PaginationListView<int, T>` (initialPageKey defaults to `1`). Same for `PagedGridView`, `PagedController`, `SliverPagedList`, `SliverPagedGrid`.

## Usage

### Grid

```dart
PagedGridView<Photo>(
  fetchPage: (page) => api.getPhotos(page: page),
  itemBuilder: (context, photo, index) => PhotoCard(photo: photo),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
)
```

### Load More Button

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserCard(user: user),
  paginationType: PaginationType.loadMore,
)
```

### Cursor-Based (Firestore, GraphQL)

```dart
PaginationListView<String, User>(
  fetchPage: (cursor) => api.getUsers(cursor: cursor),
  initialPageKey: '',
  nextPageKeyBuilder: (_, items) => items.last.cursor,
  itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
)
```

### Controlled Mode (BYO State)

```dart
PaginationListView<int, User>.controlled(
  items: users,
  status: PaginationStatus.loaded,
  onLoadMore: () => bloc.add(LoadNextPage()),
  itemBuilder: (context, user, index) => UserCard(user: user),
)
```

### Bidirectional (Two-Way) Scroll

```dart
BidirectionalPagedListView<Message>(
  fetchPage: (page) => api.getMessages(page: page),
  fetchPreviousPage: (page) => api.getOlderMessages(before: page),
  initialPageKey: 10,
  itemBuilder: (context, msg, index) => MessageBubble(msg),
)
```

### Slivers

```dart
CustomScrollView(
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

### Animated List

```dart
AnimatedPagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  plainItemBuilder: (context, user, index) => UserTile(user: user),
  staggerDelay: Duration(milliseconds: 50),
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

### Skeleton Loading

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  placeholderItem: User(name: '', email: ''),
  placeholderCount: 8,
)
```

### Keyboard Navigation (Desktop/Web)

```dart
PaginationKeyboardHandler(
  scrollController: scrollController,
  onEndReached: controller.loadNextPage,
  child: PagedListView<User>.withController(
    controller: controller,
    scrollController: scrollController,
    itemBuilder: (ctx, user, i) => UserTile(user: user),
  ),
)
```

### Auto-Retry with Backoff

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  config: PaginationConfig(
    retryPolicy: RetryPolicy(maxRetries: 3, initialDelay: Duration(seconds: 1)),
  ),
)
```

### Customization

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  firstPageLoadingBuilder: (context) => MyShimmer(),
  firstPageErrorBuilder: (context, error, retry) => MyErrorWidget(error, retry),
  emptyBuilder: (context) => MyEmptyState(),
  loadMoreErrorBuilder: (context, error, retry) => MyRetryBar(error, retry),
  endOfListBuilder: (context) => Text('All caught up!'),
  enablePullToRefresh: true,
  header: Text('Header'),
  footer: Text('Footer'),
  separatorBuilder: (context, index) => Divider(),
)
```

## Controller API

```dart
final controller = PagedController<User>(
  fetchPage: (page) => api.getUsers(page: page),
  config: PaginationConfig(pageSize: 20),
  initialItems: cachedUsers,
);
```

| Method | Description |
|--------|-------------|
| `refresh()` | Reload from first page |
| `retry()` | Retry last failed request |
| `reset()` | Clear to initial state |
| `loadNextPage()` | Trigger next page manually |
| `updateFetchPage(fn)` | Swap data source + reload (search/filter) |
| `setTotalItems(n)` | Set total count, auto-completes when reached |
| `updateItems(fn)` | Transform items in-place |
| `removeWhere(fn)` | Remove matching items |
| `insertItem(i, item)` | Insert at index |
| `removeItemAt(i)` | Remove at index |
| `updateItemAt(i, item)` | Replace at index |

| Property | Type | Description |
|----------|------|-------------|
| `items` | `List<T>` | Loaded items |
| `status` | `PaginationStatus` | Current state |
| `hasMorePages` | `bool` | More pages? |
| `currentPageKey` | `K?` | Last page key |
| `state.totalItems` | `int?` | Total (if set) |
| `state.retryCount` | `int` | Auto-retry attempts |

### BidirectionalPaginationController

| Method | Description |
|--------|-------------|
| `loadInitialPage()` | Load anchor page |
| `loadNextPage()` | Load forward |
| `loadPreviousPage()` | Load backward |
| `refresh()` | Reload from anchor |
| `retry()` | Retry last failed direction |
| `reset()` | Clear to initial |
| `items` | `[...backward, ...forward]` |

## Config Reference

### PaginationConfig

| Param | Default | Description |
|-------|---------|-------------|
| `scrollThreshold` | `200.0` | Pixels from bottom to trigger load |
| `autoLoadFirstPage` | `true` | Auto-load on build |
| `pageSize` | `null` | Items/page (auto-detects last page) |
| `retryPolicy` | `null` | Auto-retry config |

### RetryPolicy

| Param | Default | Description |
|-------|---------|-------------|
| `maxRetries` | `3` | Max attempts |
| `initialDelay` | `1s` | First retry delay |
| `backoffMultiplier` | `2.0` | Delay multiplier (1s → 2s → 4s) |
| `retryOn` | `null` | Error predicate filter |
| `retryFirstPage` | `false` | Retry first-page errors too |

### NumberedPaginationConfig

| Param | Default | Description |
|-------|---------|-------------|
| `buttonSize` | `40` | Page button size |
| `spacing` | `4` | Button spacing |
| `borderRadius` | `8` | Corner radius |
| `showFirstLastButtons` | `true` | ⏮ ⏭ buttons |
| `showNavigationButtons` | `true` | ◀ ▶ buttons |
| `selectedButtonColor` | `primary` | Active page color |

### Keyboard Handler

| Key | Action |
|-----|--------|
| Page Down/Up | Scroll one viewport |
| Home/End | Jump to top/bottom |
| Arrow ↑/↓ | Scroll 50px |

## Testing

```dart
import 'package:flutter_pagination_pro/testing.dart';

final controller = testPaginationController<int, User>(
  items: [user1, user2],
  status: PaginationStatus.loaded,
);

expect(controller, hasItemCount(2));
expect(controller, hasStatus(PaginationStatus.loaded));
expect(controller, isPaginationCompleted);
expect(controller, isPaginationEmpty);
expect(controller, hasPaginationError());
```

## Migration from infinite_scroll_pagination

| Before | After |
|--------|-------|
| `PagedListView<int, T>` | `PagedListView<T>` |
| `PagingController<int, T>` | `PagedController<T>` |
| `PagedChildBuilderDelegate` | Pass builders directly |
| `controller.appendPage(items, nextKey)` | Return `List<T>` from `fetchPage` |
| `controller.appendLastPage(items)` | Return fewer items than `pageSize` |

## Example

See the [example](example/) app for demos of every feature.

## License

MIT — see [LICENSE](LICENSE).