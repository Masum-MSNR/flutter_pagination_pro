/// Mock item model for demo purposes
class MockItem {
  const MockItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.category,
  });

  final int id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? category;

  static const categories = ['Tech', 'Design', 'Business', 'Science', 'Art'];

  factory MockItem.generate(int index, int page) {
    return MockItem(
      id: index + 1,
      title: 'Item ${index + 1}',
      subtitle: 'Page $page • Created just now',
      imageUrl: 'https://picsum.photos/seed/${index + 1}/200/200',
      category: categories[index % categories.length],
    );
  }
}
