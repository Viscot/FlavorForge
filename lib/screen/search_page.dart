import 'package:flutter/material.dart';

void main() {
  runApp(SearchPage());
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> searchHistory = [];

  void updateSearchQuery(String query) {
    setState(() {
      searchHistory.add(query);
    });
  }

  void clearSearchHistory() {
    setState(() {
      searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Search Page'),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearchHistory,
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SearchBox(
                onSearch: updateSearchQuery,
              ),
            ),
            Expanded(
              child: SearchResult(
                searchHistory: searchHistory,
                onSearch: updateSearchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  final Function(String) onSearch;

  SearchBox({required this.onSearch});

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController _textEditingController = TextEditingController();
  String hintText = "Cari resep makanan";

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            String query = _textEditingController.text;
            if (query.isNotEmpty) {
              widget.onSearch(query);
            }
          },
        ),
      ),
      onTap: () {
        setState(() {
          hintText = "Contoh 'gado gado'";
        });
      },
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class SearchResult extends StatelessWidget {
  final List<String> searchHistory;
  final Function(String) onSearch;

  SearchResult({required this.searchHistory, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searchHistory.length,
      itemBuilder: (context, index) {
        String query = searchHistory[index];
        return ListTile(
          title: Text(query),
          onTap: () {
            onSearch(query);
          },
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              searchHistory.removeAt(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Pencarian '$query' dihapus dari riwayat."),
                  action: SnackBarAction(
                    label: 'Batalkan',
                    onPressed: () {
                      searchHistory.insert(index, query);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
