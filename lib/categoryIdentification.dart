import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryIdentification extends StatefulWidget {
  @override
  _CategoryIdentificationState createState() => _CategoryIdentificationState();
}

class _CategoryIdentificationState extends State<CategoryIdentification> {
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController websiteUrlController = TextEditingController();
  
  String categoryName = '';
  String errorMessage = '';
  bool isLoading = false;

  Future<void> handleSubmit() async {
    setState(() {
      categoryName = '';
      errorMessage = '';
      isLoading = true;
    });

    // Prepare data
    String appName = appNameController.text.trim();
    String websiteUrl = websiteUrlController.text.trim();
    
    // Validate input fields
    if (appName.isEmpty && websiteUrl.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Please provide either an app name or website URL';
      });
      return;
    }

    try {
      // API request
      final response = await http.post(
        Uri.parse('http://10.0.2.2:7000/search/category'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'app_name': appName,
          'website_url': websiteUrl,
        }),
      );

      final responseData = jsonDecode(response.body);

      // Handle successful response
      if (responseData['status'] == 'success') {
        setState(() {
          categoryName = responseData['data'];
        });
      } else {
        setState(() {
          errorMessage = responseData['message'] ?? 'No category found';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Server error, please try again later';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category Identification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: appNameController,
              decoration: InputDecoration(
                labelText: 'App Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: websiteUrlController,
              decoration: InputDecoration(
                labelText: 'Website URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : handleSubmit,
              child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Search Category'),
            ),
            SizedBox(height: 20),
            if (categoryName.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.green.shade100,
                child: Text('Category Name: $categoryName', style: TextStyle(color: Colors.green.shade800)),
              ),
            if (errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.red.shade100,
                child: Text(errorMessage, style: TextStyle(color: Colors.red.shade800)),
              ),
          ],
        ),
      ),
    );
  }
}