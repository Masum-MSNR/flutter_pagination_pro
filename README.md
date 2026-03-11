<p align="center">
  <img src="https://raw.githubusercontent.com/Masum-MSNR/flutter_pagination_pro/main/images/logo.png" alt="Flutter Pagination Pro" width="120"/>
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_pagination_pro"><img src="https://img.shields.io/pub/v/flutter_pagination_pro" alt="Pub Version"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter" alt="Flutter"></a>
</p>

<p align="center">
A lightweight Flutter pagination package.<br/>
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
| Bidirectional (two-way) scroll | ✅ | ❌ |
| Controlled mode (BYO state) | ✅ `.controlled()` | ❌ |
| `updateFetchPage` (search/filter) | ✅ | ❌ |
| Pull-to-refresh | ✅ built-in | Manual |
| `initialItems` (cache-first) | ✅ | ❌ |
| `pageSize` auto last-page | ✅ | ❌ |
| `totalItems` tracking | ✅ | ❌ |
| Auto-retry with backoff | ✅ | ❌ |
| Animated item insert/remove | ✅ | ❌ |
| Keyboard navigation (desktop/web) | ✅ | ❌ |
| `findChildIndexCallback` | ✅ | ✅ |
| Header / Footer params | ✅ | ❌ |
| Skeleton loading builder | ✅ | ❌ |
| Testing utilities & matchers | ✅ | ❌ |
| Separator support | ✅ | ✅ |
| Item mutation helpers | ✅ (`updateItems`, `removeWhere`, `insertItem`) | ❌ |
| Type-safe generics | ✅ | ✅ |
| Accessibility (semantics) | ✅ | Partial |

## Quick Start

```yaml
dependencies:
  flutter_pagination_pro: ^1.0.0
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

## Bidirectional (Two-Way) Pagination

Load items in both directions — ideal for chat apps, timelines, and log viewers.
Uses `CustomScrollView(center:)` so backward items grow upward without
disturbing scroll position.

```dart
// Chat-style: start at page 10, load older (backward) and newer (forward)
BidirectionalPagedListView<Message>(
  fetchPage: (page) => api.getMessages(page: page),
  fetchPreviousPage: (page) => api.getOlderMessages(before: page),
  initialPageKey: 10,
  itemBuilder: (context, msg, index) => MessageBubble(msg),
)
```

### With Controller

```dart
final controller = BidirectionalPagedController<Message>(
  fetchPage: (page) => api.getMessages(page: page),
  fetchPreviousPage: (page) => api.getOlderMessages(before: page),
  initialPageKey: 10,
);

BidirectionalPagedListView<Message>.withController(
  controller: controller,
  itemBuilder: (context, msg, index) => MessageBubble(msg),
)
```

### Cursor-Based Bidirectional

```dart
BidirectionalPaginationListView<String, Message>(
  fetchPage: (cursor) => api.getNewerMessages(after: cursor),
  fetchPreviousPage: (cursor) => api.getOlderMessages(before: cursor),
  initialPageKey: latestCursor,
  nextPageKeyBuilder: (_, items) => items.last.cursor,
  previousPageKeyBuilder: (_, items) => items.first.cursor,
  itemBuilder: (context, msg, index) => MessageBubble(msg),
)
```

| Controller Method | Description |
|-------------------|-------------|
| `loadInitialPage()` | Load the anchor page |
| `loadNextPage()` | Load next forward page |
| `loadPreviousPage()` | Load next backward page |
| `refresh()` | Cancel all, reload from anchor |
| `retry()` | Retry the last failed direction |
| `reset()` | Clear to initial state |
| `items` | All items: `[...backward, ...forward]` |

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

## Header & Footer

Add a header or footer that scrolls with the items — no need to switch to
`CustomScrollView` yourself:

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  header: Padding(
    padding: EdgeInsets.all(16),
    child: Text('All Users', style: TextStyle(fontSize: 24)),
  ),
  footer: Center(child: Text('End of list')),
)
```

Available on both `PaginationListView` and `PaginationGridView` (all constructors).

## Animated List

Animate item insertions and removals with `AnimatedPaginationListView`.
New pages slide+fade in with stagger; removed items fade+shrink out.

```dart
// Zero-config default animations
AnimatedPagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  plainItemBuilder: (context, user, index) => UserTile(user: user),
  staggerDelay: Duration(milliseconds: 50),
)

// Custom animation control
AnimatedPaginationListView<int, User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index, animation) => SizeTransition(
    sizeFactor: animation,
    child: FadeTransition(opacity: animation, child: UserTile(user: user)),
  ),
  removeItemBuilder: (context, user, index, animation) => FadeTransition(
    opacity: animation,
    child: UserTile(user: user),
  ),
)
```

Works with controller mutations — `insertItem()`, `removeItemAt()`, `removeWhere()` all trigger animations automatically.

## Skeleton / Shimmer Loading

### Zero-config (recommended)

Add `placeholderItem` to your widget — it reuses your existing `itemBuilder` with a grey overlay:

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  placeholderItem: User(name: '', email: ''),  // just add this!
  placeholderCount: 8,                          // optional, default 6
  skeletonOverlayColor: Colors.grey.shade200,   // optional
)
```

Available on all four widget types: `PaginationListView`, `PaginationGridView`, `SliverPaginatedList`, and `SliverPaginatedGrid`.

### Custom skeleton builder

For full control, use `DefaultFirstPageLoading.builder()`:

```dart
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  firstPageLoadingBuilder: (context) => DefaultFirstPageLoading.builder(
    itemBuilder: (context, index) => ShimmerUserTile(),
    itemCount: 10,
    separatorBuilder: (context, index) => Divider(height: 1),
  ),
)
```

Pair with the [`shimmer`](https://pub.dev/packages/shimmer) package for
animated shimmer effects — this package stays lightweight.

## Testing Utilities

Import `testing.dart` for pre-built test helpers and matchers:

```dart
import 'package:flutter_pagination_pro/testing.dart';

final controller = testPaginationController<int, User>(
  items: [user1, user2, user3],
  status: PaginationStatus.loaded,
  currentPageKey: 1,
);

expect(controller, hasItemCount(3));
expect(controller, isOnPage(1));
expect(controller, hasStatus(PaginationStatus.loaded));
expect(controller, isPaginationCompleted);  // status + hasMorePages
expect(controller, hasPaginationError());   // any error status
expect(controller, isPaginationEmpty);      // empty status + no items
```

## Configuration

### PaginationConfig

| Param | Default | Description |
|-------|---------|-------------|
| `scrollThreshold` | `200.0` | Pixels from bottom to trigger load |
| `autoLoadFirstPage` | `true` | Auto-load on build |
| `pageSize` | `null` | Items per page — auto-detects last page |
| `retryPolicy` | `null` | Auto-retry failed fetches with backoff |

## Auto-Retry with Exponential Backoff

Automatically retry failed page loads with configurable backoff:

```dart
PaginationListView<int, User>(
  fetchPage: (page) => api.getUsers(page),
  config: PaginationConfig(
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
      backoffMultiplier: 2.0, // 1s → 2s → 4s
    ),
  ),
  itemBuilder: (context, user, index) => UserTile(user: user),
)
```

| RetryPolicy Param | Default | Description |
|-------------------|---------|-------------|
| `maxRetries` | `3` | Max retry attempts before giving up |
| `initialDelay` | `1s` | Delay before the first retry |
| `backoffMultiplier` | `2.0` | Multiplier for each subsequent delay |
| `retryOn` | `null` | Optional predicate — only retry matching errors |
| `retryFirstPage` | `false` | Also retry first-page errors |

Access `state.retryCount` to show retry progress in your UI.

## Keyboard Navigation (Desktop & Web)

Wrap any paginated list with `PaginationKeyboardHandler` to add keyboard scrolling:

```dart
final scrollController = ScrollController();

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

| Key | Action |
|-----|--------|
| Page Down | Scroll one viewport height down |
| Page Up | Scroll one viewport height up |
| Home | Scroll to top |
| End | Scroll to bottom + trigger `onEndReached` |
| Arrow Down | Scroll down by `arrowScrollAmount` (default 50px) |
| Arrow Up | Scroll up by `arrowScrollAmount` |

| Param | Default | Description |
|-------|---------|-------------|
| `scrollController` | **required** | Same controller used by child list |
| `onEndReached` | `null` | Called on End key or Page Down at bottom |
| `autofocus` | `true` | Auto-request keyboard focus |
| `arrowScrollAmount` | `50.0` | Pixels per arrow key press |
| `scrollAnimationDuration` | `200ms` | Scroll animation length |
| `scrollAnimationCurve` | `easeInOut` | Scroll animation curve |
| `enabled` | `true` | Toggle keyboard handling on/off |

### NumberedPaginationConfig

| Param | Default | Description |
|-------|---------|-------------|
| `buttonSize` | `40` | Page button size |
| `spacing` | `4` | Button spacing |
| `borderRadius` | `8` | Button border radius |
| `showFirstLastButtons` | `true` | Show ⏮ ⏭ buttons |
| `showNavigationButtons` | `true` | Show ◀ ▶ buttons |
| `selectedButtonColor` | `primary` | Active page color |

## Migrating from `infinite_scroll_pagination`

| infinite_scroll_pagination | flutter_pagination_pro |
|---|---|
| `PagedListView<int, T>` | `PagedListView<T>` |
| `PagingController<int, T>` | `PagedController<T>` |
| `PagedChildBuilderDelegate` | Pass builders directly to widget |
| `controller.appendPage(items, nextKey)` | Return `List<T>` from `fetchPage` |
| `controller.appendLastPage(items)` | Return fewer items than `pageSize` |

```dart
// Before (infinite_scroll_pagination)
final controller = PagingController<int, User>(firstPageKey: 1);
controller.addPageRequestListener((page) async {
  final items = await api.getUsers(page);
  if (items.length < 20) {
    controller.appendLastPage(items);
  } else {
    controller.appendPage(items, page + 1);
  }
});

// After (flutter_pagination_pro)
PagedListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
)
```

## Example

See the [example](example/) app for a complete demo with all modes.

## License

MIT — see [LICENSE](LICENSE).