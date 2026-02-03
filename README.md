# Flutter Pagination Pro

[![pub package](https://img.shields.io/pub/v/flutter_pagination_pro.svg)](https://pub.dev/packages/flutter_pagination_pro)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/platform-flutter-ff69b4.svg)](https://flutter.dev)

A simple yet powerful Flutter pagination package supporting **infinite scroll**, **load more button**, and **numbered pagination** — all with **zero dependencies**.

## ✨ Features

- 🎯 **Simple API** - Just 2-3 required parameters for basic usage
- 📜 **Infinite Scroll** - Auto-load content when reaching the bottom
- 🔘 **Load More Button** - Manual button to load next page
- 🔢 **Numbered Pagination** - Classic web-style page navigation
- 📦 **Zero Dependencies** - Pure Flutter implementation
- ⚠️ **Error Handling** - Built-in error states with retry
- 🎨 **Highly Customizable** - Customize every aspect of the UI
- 📱 **All Layouts** - ListView, GridView, and Sliver support

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_pagination_pro: ^0.0.1
```

Then run:
```bash
flutter pub get
```

## 🚀 Quick Start

### Infinite Scroll (Simplest)

```dart
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

PaginationListView<User>(
  fetchPage: (page) => api.getUsers(page: page, limit: 20),
  itemBuilder: (context, user, index) => ListTile(
    title: Text(user.name),
  ),
)
```

### Load More Button

```dart
PaginationListView<User>(
  paginationType: PaginationType.loadMore,
  fetchPage: (page) => api.getUsers(page: page, limit: 20),
  itemBuilder: (context, user, index) => ListTile(
    title: Text(user.name),
  ),
)
```

### Numbered Pagination

```dart
NumberedPaginationView<Product>(
  totalPages: 50,
  fetchPage: (page) => api.getProducts(page: page),
  itemBuilder: (context, product, index) => ProductCard(product: product),
)
```

## 📖 Documentation

For detailed documentation, see the [docs folder](../docs).

### Core Widgets

| Widget | Description |
|--------|-------------|
| `PaginationListView` | ListView with pagination |
| `PaginationGridView` | GridView with pagination |
| `NumberedPagination` | Page number navigation UI |
| `NumberedPaginationView` | Complete numbered pagination with content |

### Pagination Types

| Type | Description |
|------|-------------|
| `PaginationType.infiniteScroll` | Auto-load when reaching bottom |
| `PaginationType.loadMore` | Manual load more button |
| `PaginationType.numbered` | Page number navigation |

## 🎨 Customization

### Custom Loading Indicator

```dart
PaginationListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  loadingBuilder: (context) => Center(
    child: CircularProgressIndicator(),
  ),
)
```

### Custom Error Widget

```dart
PaginationListView<User>(
  fetchPage: (page) => api.getUsers(page: page),
  itemBuilder: (context, user, index) => UserTile(user: user),
  errorBuilder: (context, error, retry) => Column(
    children: [
      Text('Error: ${error.toString()}'),
      ElevatedButton(onPressed: retry, child: Text('Retry')),
    ],
  ),
)
```

### With Controller

```dart
final controller = PaginationController<User>(
  fetchPage: (page) => api.getUsers(page: page),
);

// In widget
PaginationListView<User>(
  controller: controller,
  itemBuilder: (context, user, index) => UserTile(user: user),
)

// Programmatic control
controller.refresh();
controller.goToPage(5);
```

## 🆚 Comparison

| Feature | flutter_pagination_pro | Others |
|---------|----------------------|--------|
| Dependencies | 0 | 1-4 |
| Min setup lines | 3 | 10-20 |
| Infinite scroll | ✅ | ✅ |
| Load more button | ✅ | ❌ |
| Numbered pagination | ✅ | ❌ |
| Error handling | ✅ Built-in | Manual |

## 📝 Example

Check out the [example](./example) folder for a complete sample app.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
