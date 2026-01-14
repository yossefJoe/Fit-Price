import 'package:flutter/material.dart';
import 'image_search.dart';
import 'text_search.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key, required this.searchType}) : super(key: key);
  final String searchType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('تحليل المنتج'), centerTitle: true),
      body:  SafeArea(child:  searchType == 'image' ? ImageSearch() : TextSearch(),
    ));
  }
}
