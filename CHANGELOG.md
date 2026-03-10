# Changelog

## 0.3.0

### Breaking Changes

- **Generic page keys (`K`)**: All controllers and widgets now require two type parameters: `PaginationController<K, T>`, `PaginationListView<K, T>`, etc. where `K` is the page key type and `T` is the item type. For integer pages, use `<int, T>` or the new convenience aliases.
- **`FetchPage<T>` → `FetchPage<K, T>`**: The fetch callback now receives `K pageKey` instead of `int page`.
- **`OnPageLoaded<T>` → `OnPageLoaded<K, T>`**: The page-loaded callback now provides `K pageKey` instead of `int page`.
- **`PaginationState.currentPage` → `PaginationState.pageKey`**: The `int currentPage` field is replaced by `K? pageKey`.
- **`PaginationConfig.initialPage` removed**: Use `initialPageKey` on the controller or widget constructor instead.

### New Features

- **`initialPageKey` is optional for int keys**: When `K` is `int`, `initialPageKey` defaults to `1` — you no longer need to pass it for the common case.
- **Convenience typedefs**: `PagedListView<T>`, `PagedGridView<T>`, `PagedController<T>`, `SliverPagedList<T>`, `SliverPagedGrid<T>` — these alias the `<int, T>` variants so you can write `PagedListView<User>(...)` instead of `PaginationListView<int, User>(...)`.
- **Cursor-based pagination**: Use `PaginationController<String, T>` with `nextPageKeyBuilder: (_, items) => items.last.cursor` for cursor/token-based APIs.
- **Offset-based pagination**: Use `PaginationController<int, T>` with `initialPageKey: 0` and `nextPageKeyBuilder: (offset, items) => offset + items.length`.
- **`updateFetchPage()`**: Replace the data source at runtime — ideal for search/filter scenarios. Cancels any ongoing fetch, resets state, and reloads from the first page.
- **Controlled mode (`.controlled()` constructors)**: All four widget types (`PaginationListView`, `PaginationGridView`, `SliverPaginatedList`, `SliverPaginatedGrid`) now support a `.controlled()` named constructor for BYO state management — provide items, status, and callbacks directly without a `PaginationController`.
- **`NextPageKeyBuilder<K, T>` typedef**: New callback type for computing the next page key from the current key and loaded items. Defaults to `(k, _) => k + 1` for `int` keys.

### Migration Guide (0.2.0 → 0.3.0)

```dart
// Before (0.2.0)
PaginationController<User>(fetchPage: (page) => api.getUsers(page: page));
PaginationListView<User>(fetchPage: (page) => ..., itemBuilder: ...);

// After (0.3.0) — simplest with aliases
PagedController<User>(fetchPage: (page) => api.getUsers(page: page));
PagedListView<User>(fetchPage: (page) => ..., itemBuilder: ...);

// After (0.3.0) — explicit generic form (also valid)
PaginationController<int, User>(fetchPage: (page) => api.getUsers(page: page));
PaginationListView<int, User>(fetchPage: (page) => ..., itemBuilder: ...);
```

## 0.2.0

### New Features

- **`pageSize` auto last-page detection**: Set `pageSize` in `PaginationConfig` to automatically detect the final page when fewer items than expected are returned — eliminates phantom "loading more" spinners.
- **`initialItems` support**: Prepopulate the list with cached data via `PaginationController(initialItems: [...])`. The controller starts in `loaded` state, skipping the initial load.
- **`totalItems` / `setTotalItems`**: Track the total item count from your API. Call `controller.setTotalItems(total)` to display "Showing X of Y" and auto-complete when all items are loaded.
- **`findChildIndexCallback` passthrough**: All scroll widgets (`PaginationListView`, `PaginationGridView`, `SliverPaginatedList`, `SliverPaginatedGrid`) now accept `findChildIndexCallback` for improved performance during item mutations.

### Improvements

- `PaginationConfig` now supports `pageSize` field with proper `==`/`hashCode`/`copyWith`.
- `PaginationState` now includes `totalItems` field with proper `==`/`hashCode`/`copyWith`/`toString`.

## 0.1.0

### Breaking Changes

- **`PaginationConfig`**: Replaced `invisibleItemsThreshold` with `scrollThreshold` (in pixels, default 200.0) for clearer, more accurate scroll-triggered loading.
- **`onPageLoaded`**: Now fires with only the **new** items loaded on that page instead of the full accumulated list.
- **`PaginationGridView`**: Removed unused `mainAxisSpacing` and `crossAxisSpacing` parameters (they were accepted but never applied). Set spacing via `gridDelegate` instead.

### Bug Fixes

- **Refresh no longer wipes the screen**: `controller.refresh()` now keeps existing items visible while reloading, instead of replacing everything with a full-page loading spinner.
- **`DefaultLoadMoreError` now shows the actual error**: Previously hardcoded "Failed to load more" and ignored the `error` field.

### New Features

- **Sliver variants**: Added `SliverPaginatedList` and `SliverPaginatedGrid` for use inside `CustomScrollView`, enabling composability with `SliverAppBar`, `SliverToBoxAdapter`, and other slivers.
- **Pull-to-refresh**: Added `enablePullToRefresh` parameter to `PaginationListView` and `PaginationGridView`.
- **Accessibility**: Added semantic labels to `NumberedPagination` buttons for screen readers.
- **`NumberedPaginationConfig`**: Added `==` and `hashCode` for proper equality comparison.

### Improvements

- **Shared pagination mixin**: Extracted `PaginationStateMixin` to eliminate code duplication between `PaginationListView` and `PaginationGridView`.
- **Config from controller**: When using `.withController()`, config is now read from the controller instead of widget defaults.
- **Fixed README**: Corrected parameter tables to match actual API.

## 0.0.1

Initial release.

### Features

- **PaginationListView** - ListView with pagination support
- **PaginationGridView** - GridView with pagination support
- **NumberedPagination** - Page number navigation widget
- **PaginationController** - Programmatic control for pagination

### Pagination Modes

- **Infinite Scroll** - Auto-load when scrolling near bottom
- **Load More Button** - Manual button to load next page
- **Numbered** - Classic page number navigation

### Highlights

- Zero external dependencies
- Fully customizable UI components
- Built-in loading, error, and empty states
- Type-safe generic API
- Separator support for ListView
