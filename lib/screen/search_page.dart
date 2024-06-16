import 'package:flavorforge/recipes/recipe_detail.dart';
import 'package:flavorforge/recipes/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> searchHistory = [];
  bool hasSearched = false;
  String searchQuery = '';

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
      searchQuery = query;
      saveSearchHistory(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
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
            child: hasSearched
                ? SearchResult(searchQuery: searchQuery)
                : Center(child: Text("Search for recipes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
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
  String hintText = "Search for recipes...";
  bool showHistory = false;

  Widget buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Searches',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        Center(
          child: TextButton(
            onPressed: widget.clearSearchHistory,
            child: Text('Clear History', style: TextStyle(color: Colors.deepOrange)),
          ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onTap: () {
            setState(() {
              hintText = "Example: 'gado gado'";
              showHistory = true;
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
  final String searchQuery;

  SearchResult({required this.searchQuery});

  Future<String> getAuthorName(DocumentReference authorRef) async {
    DocumentSnapshot userDoc = await authorRef.get();
    return userDoc['username'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No results found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
        }
        List<Recipe> searchResults = snapshot.data!.docs.map((doc) {
          return Recipe.fromFirestore(doc);
        }).toList();

        return ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            Recipe recipe = searchResults[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: ListTile(
                title: Text(recipe.name, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(recipe.description),
                leading: Image.network(
                  recipe.imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
