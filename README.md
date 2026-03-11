<p align="center">
  <img src="https://raw.githubusercontent.com/Masum-MSNR/flutter_pagination_pro/main/images/logo.png" alt="Flutter Pagination Pro" width="120"/>
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_pagination_pro"><img src="https://img.shields.io/pub/v/flutter_pagination_pro.svg" alt="pub package"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter" alt="Flutter 3.0+"></a>
  <a href="https://masum-fpp.web.app"><img src="https://img.shields.io/badge/Live_Demo-masum--fpp.web.app-FF6F00?logo=firebase" alt="Live Demo"></a>
</p>

<p align="center">
A production-ready, zero-dependency Flutter pagination package with support for infinite scroll, grids, slivers, bidirectional lists, skeleton loading, and more.
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Masum-MSNR/flutter_pagination_pro/main/images/preview.png" alt="Preview" width="720"/>
</p>

---

## Features

| Feature | Widget / API |
|---------|-------------|
| Infinite Scroll | `PagedListView` |
| Load More Button | `PaginationType.loadMore` |
| Grid View | `PagedGridView` |
| Slivers | `SliverPagedList` / `SliverPagedGrid` |
| Numbered Pages | `NumberedPagination` |
| Bidirectional Scroll | `BidirectionalPagedListView` |
| Animated List | `AnimatedPagedListView` |
| Skeleton Loading | `placeholderItem` + `SkeletonConfig` |
| Cursor / Offset Keys | `PaginationListView<String, T>` |
| Controlled Mode | `.controlled()` constructor |
| Auto-Retry | `RetryPolicy` |
| Keyboard Navigation | `PaginationKeyboardHandler` |

---

## Installation

```yaml
dependencies:
  flutter_pagination_pro: ^latest
```

---

## Quick Start

```dart
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
)
```

> `PagedListView<T>` is a convenience alias for `PaginationListView<int, T>` with `initialPageKey: 1`. The same pattern applies to `PagedGridView`, `PagedController`, `SliverPagedList`, `SliverPagedGrid`.

---

## Examples

### Grid View

```dart
PagedGridView<Photo>(
  fetchPage: (page) => api.getPhotos(page: page),
  itemBuilder: (ctx, photo, i) => PhotoCard(photo: photo),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
)
```

### Load More Button

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (ctx, user, i) => UserTile(user: user),
  paginationType: PaginationType.loadMore,
)
```

### Cursor-Based Pagination

```dart
PaginationListView<String, User>(
  fetchPage: (cursor) => api.getUsers(cursor: cursor),
  initialPageKey: '',
  nextPageKeyBuilder: (_, items) => items.last.cursor,
  itemBuilder: (ctx, user, i) => ListTile(title: Text(user.name)),
)
```

### Controlled Mode

```dart
PaginationListView<int, User>.controlled(
  items: users,
  status: PaginationStatus.loaded,
  onLoadMore: () => bloc.add(LoadNextPage()),
  itemBuilder: (ctx, user, i) => UserTile(user: user),
)
```

### Bidirectional Scroll

```dart
BidirectionalPagedListView<Message>(
  fetchPage: (page) => api.getMessages(page: page),
  fetchPreviousPage: (page) => api.getOlder(before: page),
  initialPageKey: 10,
  itemBuilder: (ctx, msg, i) => MessageBubble(msg),
)
```

### Slivers

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(title: Text('Users')),
    SliverPaginatedList<int, User>(
      controller: controller,
      scrollController: scrollController,
      itemBuilder: (ctx, user, i) => ListTile(title: Text(user.name)),
    ),
  ],
)
```

### Animated List

```dart
AnimatedPagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  plainItemBuilder: (ctx, user, i) => UserTile(user: user),
  staggerDelay: Duration(milliseconds: 50),
)
```

### Numbered Pagination

```dart
NumberedPagination(
  totalPages: 20,
  currentPage: _page,
  onPageChanged: (p) => setState(() => _page = p),
)
```

### Skeleton Loading

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (ctx, user, i) => UserTile(user: user),
  placeholderItem: User.placeholder(),
  placeholderCount: 8,
  skeletonConfig: SkeletonConfig(borderRadius: 6),
)
```

### Keyboard Navigation

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

### Auto-Retry

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (ctx, user, i) => UserTile(user: user),
  config: PaginationConfig(
    retryPolicy: RetryPolicy(maxRetries: 3, initialDelay: Duration(seconds: 1)),
  ),
)
```

### Full Customization

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (ctx, user, i) => UserTile(user: user),
  firstPageLoadingBuilder: (ctx) => MyShimmer(),
  firstPageErrorBuilder: (ctx, err, retry) => ErrorWidget(err, retry),
  emptyBuilder: (ctx) => EmptyState(),
  endOfListBuilder: (ctx) => Text('All caught up!'),
  enablePullToRefresh: true,
  header: Text('Header'),
  footer: Text('Footer'),
  separatorBuilder: (ctx, i) => Divider(),
)
```

---

## Controller API

```dart
final controller = PagedController<User>(
  fetchPage: (page) => api.getUsers(page: page),
  config: PaginationConfig(pageSize: 20),
);
```

### Methods

| Method | Description |
|--------|-------------|
| `refresh()` | Reload from first page (keeps items visible) |
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

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `items` | `List<T>` | Currently loaded items |
| `status` | `PaginationStatus` | Current state enum |
| `hasMorePages` | `bool` | Whether more pages remain |
| `currentPageKey` | `K?` | Last loaded page key |

### BidirectionalPaginationController

| Method | Description |
|--------|-------------|
| `loadInitialPage()` | Load anchor page |
| `loadNextPage()` / `loadPreviousPage()` | Load forward / backward |
| `refresh()` | Reload from anchor |
| `retry()` | Retry last failed direction |
| `reset()` | Clear to initial state |

---

## Configuration

### PaginationConfig

| Param | Default | Description |
|-------|---------|-------------|
| `scrollThreshold` | `200.0` | Pixels from bottom to trigger next load |
| `autoLoadFirstPage` | `true` | Auto-load on widget build |
| `pageSize` | `null` | Items per page (auto-detects last page) |
| `retryPolicy` | `null` | Auto-retry configuration |

### RetryPolicy

| Param | Default | Description |
|-------|---------|-------------|
| `maxRetries` | `3` | Maximum retry attempts |
| `initialDelay` | `1s` | First retry delay |
| `backoffMultiplier` | `2.0` | Delay multiplier (1s → 2s → 4s) |
| `retryOn` | `null` | Error predicate filter |
| `retryFirstPage` | `false` | Also retry first-page errors |

### SkeletonConfig

| Param | Default | Description |
|-------|---------|-------------|
| `overlayColor` | theme grey | Base colour for skeleton bones |
| `borderRadius` | `4.0` | Corner radius for skeleton shapes |
| `shimmerDuration` | `1500ms` | Shimmer animation sweep duration |

### NumberedPaginationConfig

| Param | Default | Description |
|-------|---------|-------------|
| `buttonSize` | `40` | Page button size |
| `spacing` | `4` | Button spacing |
| `borderRadius` | `8` | Corner radius |
| `showFirstLastButtons` | `true` | Show ⏮ ⏭ buttons |
| `showNavigationButtons` | `true` | Show ◀ ▶ buttons |
| `selectedButtonColor` | primary | Active page colour |

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Page Down / Up | Scroll one viewport |
| Home / End | Jump to top / bottom |
| Arrow ↑ / ↓ | Scroll 50px |

---

## Example App

Try the [live demo](https://masum-fpp.web.app) or browse the [source code](example/).

## License

MIT — see [LICENSE](LICENSE).
