import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConstructionPredictionScreen(),
    );
  }
}

class ConstructionPredictionScreen extends StatefulWidget {
  @override
  _ConstructionPredictionScreenState createState() =>
      _ConstructionPredictionScreenState();
}

class _ConstructionPredictionScreenState
    extends State<ConstructionPredictionScreen> {
  File? _image;
  String _prediction = '';
  final picker = ImagePicker();

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _prediction = '';
      }
    });
  }

  Future<void> _sendImageForPrediction() async {
    if (_image == null) {
      // Handle case when no image is selected
      return;
    }

    // Convert the image file to base64 encoded data
    final bytes = await _image!.readAsBytes();
    final String base64Image = base64Encode(bytes);

    var url = 'https://testflaskfunc.azurewebsites.net/classify'; // Replace with your Flask API URL

    try {
      var data = {'image': base64Image}; // Send the base64 encoded image data
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);


        print('response: ${response.body}');
        print('responseData: $responseData');
        final prediction = responseData['class'];

        print('API Response: $responseData');
        print('Prediction: $prediction');


        setState(() {
          _prediction = prediction;
        });
      } else {
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error:$e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Testing Model Integrations')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Image.file(_image!, height: 200, width: 200)
                : const Icon(Icons.image, size: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImageFromGallery,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendImageForPrediction,
              child: const Text('Predict'),
            ),
            const SizedBox(height: 20),
            _prediction.isNotEmpty
                ? Text(
              _prediction,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            )
                : const Text(
              'no prediction',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}