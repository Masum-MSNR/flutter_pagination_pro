# Changelog

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
