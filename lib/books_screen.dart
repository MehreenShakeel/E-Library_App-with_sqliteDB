// books_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'book_detail_screen.dart';
import '../services/database_helper.dart';

class Book {
  final int? id;
  final String title;
  final String author;
  final String image;
  final String description;
  double rating;
  List<Comment> comments;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.image,
    required this.description,
    this.rating = 0.0,
    this.comments = const [],
  });

  Book copyWithId(int id) => Book(
        id: id,
        title: title,
        author: author,
        image: image,
        description: description,
        rating: rating,
        comments: comments,
      );
}

class Comment {
  final String user;
  final String text;
  final bool liked;
  Comment({required this.user, required this.text, this.liked = false});
}

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});
  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _loadBooks() async {
    final books = await dbHelper.getBooks();
    setState(() {
      _books = books;
      _filteredBooks = books;
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _books.where((book) {
        return book.title.toLowerCase().contains(query) ||
               book.author.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddBookDialog() {
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Book'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: authorCtrl, decoration: const InputDecoration(labelText: 'Author')),
            TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'Image URL')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final book = Book(
                title: titleCtrl.text,
                author: authorCtrl.text,
                image: imageCtrl.text.isEmpty ? 'https://picsum.photos/150?random=${DateTime.now().millisecondsSinceEpoch}' : imageCtrl.text,
                description: descCtrl.text,
              );
              await dbHelper.insertBook(book);
              _loadBooks();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          ElevatedButton.icon(
            onPressed: _showAddBookDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _filteredBooks.isEmpty
          ? const Center(child: Text('No books found'))
          : ListView.builder(
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                final book = _filteredBooks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    leading: Image.network(book.image, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(book.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Author: ${book.author}'),
                        RatingBar.builder(
                          initialRating: book.rating,
                          minRating: 1,
                          itemSize: 20,
                          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (r) async {
                            book.rating = r;
                            await dbHelper.updateBook(book);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (book.id != null) {
                          await dbHelper.deleteBook(book.id!);
                          _loadBooks();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}