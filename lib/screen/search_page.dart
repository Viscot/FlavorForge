import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SearchPage());
}

class Recipe {
  final String title;
  final String description;
  final String imageUrl;
  final String creator;

  Recipe({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.creator,
  });
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Recipe> searchResults = [];
  List<String> searchHistory = [];
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    loadSearchHistory();
  }

  void loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  void saveSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (!searchHistory.contains(query)) {
      searchHistory.insert(0, query);
      prefs.setStringList('searchHistory', searchHistory);
    }
  }

  void removeFromSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.remove(query);
      prefs.setStringList('searchHistory', searchHistory);
    });
  }

  void clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.clear();
      prefs.setStringList('searchHistory', searchHistory);
    });
  }

  void updateSearchQuery(String query) {
    setState(() {
      hasSearched = true;
      searchResults = [
        Recipe(
          title: "Gado gado",
          description: "Gado-gado adalah salah satu makanan khas Indonesia.",
          imageUrl: "https://example.com/gadogado.jpg",
          creator: "User123",
        ),
        Recipe(
          title: "Nasi Goreng",
          description: "Nasi Goreng adalah makanan khas Indonesia yang lezat.",
          imageUrl: "https://example.com/nasigoreng.jpg",
          creator: "Chef456",
        ),
      ].where((recipe) => recipe.title.toLowerCase().contains(query.toLowerCase())).toList();
      saveSearchHistory(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Search Page'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SearchBox(
                onSearch: updateSearchQuery,
                searchHistory: searchHistory,
                removeFromSearchHistory: removeFromSearchHistory,
                clearSearchHistory: clearSearchHistory,
              ),
            ),
            Expanded(
              child: SearchResult(
                searchResults: searchResults,
                hasSearched: hasSearched,
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
  final List<String> searchHistory;
  final Function(String) removeFromSearchHistory;
  final Function() clearSearchHistory;

  SearchBox({
    required this.onSearch,
    required this.searchHistory,
    required this.removeFromSearchHistory,
    required this.clearSearchHistory,
  });

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController _textEditingController = TextEditingController();
  String hintText = "Cari resep makanan";
  bool showHistory = false;

  Widget buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'History:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        ...widget.searchHistory.map((query) {
          return ListTile(
            title: Text(
              query,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                widget.removeFromSearchHistory(query);
              },
            ),
            onTap: () {
              _textEditingController.text = query;
              widget.onSearch(query);
              setState(() {
                showHistory = false;
              });
            },
          );
        }).toList(),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: widget.clearSearchHistory,
          child: Text('Clear History'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                String query = _textEditingController.text;
                widget.onSearch(query);
                setState(() {
                  showHistory = false;
                });
              },
            ),
          ),
          onTap: () {
            setState(() {
              hintText = "Contoh 'gado gado'";
              showHistory = false;
            });
          },
        ),
        SizedBox(height: 10),
        if (widget.searchHistory.isNotEmpty)
          ExpansionTile(
            title: Text("Show Search History"),
            onExpansionChanged: (expanded) {
              setState(() {
                showHistory = expanded;
              });
            },
            children: [
              if (showHistory) buildSearchHistory(),
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class SearchResult extends StatelessWidget {
  final List<Recipe> searchResults;
  final bool hasSearched;

  SearchResult({required this.searchResults, required this.hasSearched});

  @override
  Widget build(BuildContext context) {
    return hasSearched
        ? searchResults.isNotEmpty
            ? ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  Recipe recipe = searchResults[index];
                  return ListTile(
                    title: Text(recipe.title),
                    subtitle: Text(recipe.description),
                    leading: Image.network(recipe.imageUrl),
                    trailing: Text("By ${recipe.creator}"),
                    onTap: () {
                      // Tambahkan logika untuk menangani ketika resep makanan dipilih
                      // Misalnya, Anda dapat menampilkan detail resep.
                    },
                  );
                },
              )
            : Center(
                child: Text("Tidak ditemukan"),
              )
        : Container();
  }
}
