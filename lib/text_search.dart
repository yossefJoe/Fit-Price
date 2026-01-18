import 'package:flutter/material.dart';
import 'package:one_shot/helper_methods.dart';

import 'assets_manager.dart';
import 'custom_gradient.dart';
import 'result_card.dart';
import 'result_model.dart';

class TextSearch extends StatefulWidget {
  const TextSearch({Key? key}) : super(key: key);

  @override
  _TextSearchState createState() => _TextSearchState();
}

class _TextSearchState extends State<TextSearch> {
  TextEditingController controller = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  List<ResultModel> _results = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomGradient(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (value) async {
                    setState(() {
                      _isLoading = true;
                    });
                    await HelperMethods.searchByText(value).then((value) {
                      setState(() {
                        _results = value;
                        _isLoading = false;
                      });
                    });
                  },
                  controller: controller,
                  decoration: InputDecoration(
                    disabledBorder: null,
                    enabledBorder: null,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                    hintText: 'Search by text',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    :
                    // رسالة الخطأ
                    (_errorMessage != null && !_isLoading)
                    ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children:
                            _results
                                .map((res) => ResultCard(result: res))
                                .toList(),
                      ),
                    ),
              ],
            ),
          ),

          // عرض النتائج لكل عنصر في List<ResultModel>
        ),
      ),
    );
  }
}
