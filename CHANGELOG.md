# Changelog

## 1.0.2

- Add CI workflow for Firebase Hosting deployment of example app
- Live demo at [masum-fpp.web.app](https://masum-fpp.web.app)
- Polish README: professional description, compact feature table

## 1.0.1

- Shorten pubspec description to meet pub.dev guidelines (60–180 chars)
- Polish README: compact header, feature table, shorter examples
- Remove migration and testing sections from README

## 1.0.0

**Stable release** — all features implemented, 297 tests passing.

### Highlights

- Skeleton loading with true rounded corners (render-tree bone painting)
- `SkeletonConfig`: `borderRadius`, `overlayColor`, `shimmerDuration`
- Full codebase cleanup, formatting, and lint fixes

### All Features (cumulative)

| Version | Feature |
|---------|---------|
| 0.0.1 | `PaginationListView`, `PaginationGridView`, `NumberedPagination`, `PaginationController` |
| 0.1.0 | Slivers (`SliverPaginatedList`, `SliverPaginatedGrid`), pull-to-refresh, accessibility |
| 0.2.0 | `pageSize` auto last-page detection, `initialItems`, `totalItems`, `findChildIndexCallback` |
| 0.3.0 | Generic page keys (`K`), cursor/offset pagination, controlled mode, `updateFetchPage()`, convenience typedefs |
| 0.4.0 | Skeleton/shimmer loading (`placeholderItem`), header/footer, testing utilities |
| 0.5.0 | Auto-retry with exponential backoff (`RetryPolicy`), empty state refresh |
| 0.6.0 | Bidirectional pagination (`BidirectionalPaginationListView`) |
| 0.7.0 | Animated item insert/remove (`AnimatedPaginationListView`) |
| 0.8.0 | Keyboard navigation (`PaginationKeyboardHandler`) |
| 1.0.0 | Skeleton render-tree bone painting, `SkeletonConfig`, stable release |

### Migration from `infinite_scroll_pagination`

| Before | After |
|--------|-------|
| `PagedListView<int, T>` | `PagedListView<T>` |
| `PagingController<int, T>` | `PagedController<T>` |
| `PagedChildBuilderDelegate` | Pass builders directly to widget |
| `controller.appendPage(items, key)` | Return `List<T>` from `fetchPage` |
| `controller.appendLastPage(items)` | Return fewer than `pageSize` — auto-detected |

---

## 0.8.0

- **Keyboard navigation**: `PaginationKeyboardHandler` — Page Down/Up, Home/End, Arrow keys for desktop & web scrolling

## 0.7.0

- **Animated pagination list**: `AnimatedPaginationListView` with staggered insert/remove animations, configurable durations, `plainItemBuilder` for zero-config

## 0.6.0

- **Bidirectional pagination**: `BidirectionalPaginationListView` — two-way scrolling with separate forward/backward loading, scroll-stable prepending via `CustomScrollView(center:)`

## 0.5.0

- **Auto-retry with exponential backoff**: `RetryPolicy` on `PaginationConfig` — `maxRetries`, `initialDelay`, `backoffMultiplier`, error filtering
- **Empty state refresh**: `DefaultEmpty` with optional `onRefresh` callback, auto-wired in controlled mode

## 0.4.0

- **Skeleton/shimmer loading**: `placeholderItem` + `placeholderCount` on all paginated widgets — reuses your `itemBuilder` as skeleton
- **`DefaultFirstPageLoading.builder()`** and **`.fromItemBuilder<T>()`** for custom skeleton layouts
- **Header & Footer**: `header` / `footer` params on `PaginationListView` and `PaginationGridView`
- **Testing utilities**: `testPaginationController()`, `hasItemCount()`, `hasStatus()`, `isPaginationCompleted`, `isPaginationEmpty`, `hasPaginationError()`

## 0.3.0

### Breaking Changes

- Generic page keys: `PaginationController<K, T>`, `PaginationListView<K, T>`, etc.
- `FetchPage<T>` → `FetchPage<K, T>`, `PaginationState.currentPage` → `.pageKey`
- `PaginationConfig.initialPage` removed — use `initialPageKey` on widget/controller

### New

- Convenience typedefs: `PagedListView<T>`, `PagedGridView<T>`, `PagedController<T>`, etc.
- Cursor & offset pagination support
- `updateFetchPage()` for search/filter
- Controlled mode (`.controlled()` constructors)

## 0.2.0

- `pageSize` auto last-page detection
- `initialItems` for pre-populated lists
- `totalItems` / `setTotalItems()` for progress tracking
- `findChildIndexCallback` passthrough

## 0.1.0

### Breaking Changes

- `invisibleItemsThreshold` → `scrollThreshold` (pixels, default 200)
- `onPageLoaded` now fires with new items only
- Removed unused `mainAxisSpacing` / `crossAxisSpacing` from `PaginationGridView`

### New

- `SliverPaginatedList`, `SliverPaginatedGrid`
- Pull-to-refresh (`enablePullToRefresh`)
- Accessibility labels on `NumberedPagination`

### Fixes

- `refresh()` keeps items visible while reloading
- `DefaultLoadMoreError` shows actual error message

## 0.0.1

Initial release — `PaginationListView`, `PaginationGridView`, `NumberedPagination`, `PaginationController`. Infinite scroll, load more button, numbered pagination. Zero dependencies.
