<p align="center">
  <img src="https://raw.githubusercontent.com/Masum-MSNR/flutter_pagination_pro/main/images/logo.png" alt="Flutter Pagination Pro" width="100"/>
</p>

<h1 align="center">Flutter Pagination Pro</h1>

<p align="center">
  <a href="https://pub.dev/packages/flutter_pagination_pro"><img src="https://img.shields.io/pub/v/flutter_pagination_pro" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/flutter_pagination_pro/score"><img src="https://img.shields.io/pub/points/flutter_pagination_pro" alt="Pub Points"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter" alt="Flutter 3.0+"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart" alt="Dart 3.0+"></a>
</p>

<p align="center">
  <b>A lightweight, zero-dependency pagination toolkit for Flutter.</b><br/>
  Infinite scroll · Load more · Grid · Slivers · Numbered pages · Bidirectional · Animated lists · Skeleton loading · Keyboard nav — all in one package.
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Masum-MSNR/flutter_pagination_pro/main/images/preview.png" alt="Preview" width="720"/>
</p>

---

## Features

| Feature | Widget / API | Description |
|---------|-------------|-------------|
| **Infinite Scroll** | `PagedListView` | Auto-loads next page on scroll threshold |
| **Load More Button** | `paginationType: .loadMore` | Manual "load more" trigger |
| **Grid View** | `PagedGridView` | Paginated grid with any `SliverGridDelegate` |
| **Slivers** | `SliverPagedList` / `SliverPagedGrid` | Composable inside `CustomScrollView` |
| **Numbered Pages** | `NumberedPagination` | Classic page-number navigation bar |
| **Bidirectional** | `BidirectionalPagedListView` | Two-way scroll for chats, timelines |
| **Animated List** | `AnimatedPagedListView` | Staggered insert/remove animations |
| **Skeleton Loading** | `placeholderItem` + `SkeletonConfig` | Auto-generated shimmer from your item builder |
| **Cursor / Offset Keys** | `PaginationListView<String, T>` | Generic page keys — int, cursor, offset |
| **Controlled Mode** | `.controlled()` constructor | BYO state (Bloc, Riverpod, etc.) |
| **Search / Filter** | `updateFetchPage()` | Swap data source & reload instantly |
| **Auto-Retry** | `RetryPolicy` | Exponential backoff on failures |
| **Keyboard Nav** | `PaginationKeyboardHandler` | Page Up/Down, Home/End for desktop & web |
| **Pull to Refresh** | `enablePullToRefresh: true` | Built-in refresh indicator |
| **Header / Footer** | `header` / `footer` params | Scrollable header & footer widgets |
| **Testing Utilities** | `package:.../testing.dart` | Pre-seeded controllers & custom matchers |

**Zero external dependencies** · **297 tests** · **Fully type-safe**

---

## Installation

```yaml
dependencies:
  flutter_pagination_pro: ^1.0.0
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

---

## Migrating from `infinite_scroll_pagination`

| Before (`infinite_scroll_pagination`) | After (`flutter_pagination_pro`) |
|---------------------------------------|-----------------------------------|
| `PagedListView<int, T>` | `PagedListView<T>` |
| `PagingController<int, T>` | `PagedController<T>` |
| `PagedChildBuilderDelegate` | Pass builders directly to widget |
| `controller.appendPage(items, key)` | Return `List<T>` from `fetchPage` |
| `controller.appendLastPage(items)` | Return fewer than `pageSize` → auto-detected |
| No bidirectional support | `BidirectionalPagedListView` |
| No animated lists | `AnimatedPagedListView` |
| No keyboard nav | `PaginationKeyboardHandler` |
| No auto-retry | `RetryPolicy` on `PaginationConfig` |
| No skeleton loading | `placeholderItem` + `SkeletonConfig` |
| No numbered pagination | `NumberedPagination` |

---

## Example App

See the full [example app](example/) with demos for every feature.

## License

MIT — see [LICENSE](LICENSE).
