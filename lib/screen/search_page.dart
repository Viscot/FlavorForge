import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SearchApp());
}

class SearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SearchPage(),
    );
  }
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
          title: "Gado gado Entong",
          description: "Gado-gado adalah salah satu makanan khas Indonesia.",
          imageUrl: "https://cdn0-production-images-kly.akamaized.net/LCd7mzw6FM63ysIIv7K2Kde8kUE=/500x281/smart/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/2413676/original/011486100_1542811444-Gado_gado.jpg",
          creator: "Entong ganteng",
        ),
        Recipe(
          title: "Nasi Goreng Bang Toyib",
          description: "Nasi Goreng adalah makanan khas Indonesia yang lezat.",
          imageUrl: "https://www.masakapahariini.com/wp-content/uploads/2021/07/Nasi-Goreng-Spesial-Ayam-Kecombrang.jpg",
          creator: "Toyib cakep",
        ),
      ].where((recipe) => recipe.title.toLowerCase().contains(query.toLowerCase())).toList();
      saveSearchHistory(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  return Card(
                    margin: EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(recipe.title),
                      subtitle: Text(recipe.description),
                      leading: Image.network(recipe.imageUrl),
                      trailing: Text("By ${recipe.creator}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailPage(recipe: recipe),
                          ),
                        );
                      },
                    ),
                  );
                },
              )
            : Center(
                child: Text("Tidak ditemukan"),
              )
        : Container();
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.imageUrl),
            SizedBox(height: 16.0),
            Text(
              recipe.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text(
              recipe.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10.0),
            Text(
              'By ${recipe.creator}',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
