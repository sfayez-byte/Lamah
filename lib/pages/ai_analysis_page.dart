// File: lib/pages/ai_analysis_page.dart

import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../Widget/HomePage.dart'; // Assuming you have a HomePage to navigate back to

class AIAnalysisPage extends StatefulWidget {
  const AIAnalysisPage({Key? key}) : super(key: key);

  @override
  _AIAnalysisPageState createState() => _AIAnalysisPageState();
}

class _AIAnalysisPageState extends State<AIAnalysisPage> {
  late Interpreter _interpreter;
  bool _isLoading = false;
  String? _analysisResult;
  String? _errorMessage;
  final Uuid _uuid = const Uuid();

  // Define class labels
  final List<String> _labels = ["Non-ASD", "ASD"];

  // Default quantization parameters
  final double _inputScale = 0.003921568859368563; // 1/255
  final int _inputZeroPoint = -128;
  final double _outputScale = 0.00390625; // 1/256
  final int _outputZeroPoint = -128;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      print('Initializing TensorFlow Lite model...');
      final modelData = await rootBundle.load('assets/models/updated_cnn_model.tflite');
      _interpreter = Interpreter.fromBuffer(
        modelData.buffer.asUint8List(),
        options: InterpreterOptions()
          ..threads = 4
          ..useNnApiForAndroid = false,
      );

      // Get and log tensor shapes
      final inputShape = _interpreter.getInputTensor(0).shape;
      final outputShape = _interpreter.getOutputTensor(0).shape;
      print('Model loaded successfully.');
      print('Input Tensor Shape: $inputShape');
      print('Output Tensor Shape: $outputShape');
    } catch (e, stackTrace) {
      print('Error initializing model: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to initialize AI model. Please try again later.';
      });
    }
  }

  Future<void> _analyzeImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      print("No image selected.");
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = null;
      _errorMessage = null;
    });

    try {
      print('Image selected successfully.');
      final imageBytes = await pickedFile.readAsBytes();
      final Int8List inputTensor = await _preprocessImage(imageBytes);

      // Reshape input tensor to match expected shape [1, 224, 224, 3]
      final input = [inputTensor.reshape([1, 224, 224, 3])];

      // Create output tensor with correct shape [1, 2]
      final outputShape = _interpreter.getOutputTensor(0).shape;
      final output = List.generate(
        outputShape[0],
        (_) => List<int>.filled(outputShape[1], 0),
      );

      // Run inference
      print('Running inference...');
      print('Output shape: $outputShape');
      _interpreter.run(input[0], output);

      // Convert output to Int8List for post-processing
      final flatOutput = Int8List.fromList(output[0]);

      // Post-process results
      final result = _postProcessOutput(flatOutput);
      await _saveAnalysisResult(result);

      setState(() {
        _analysisResult = result;
      });

      print('Inference completed successfully.');
    } catch (e, stackTrace) {
      print('Analysis error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Error analyzing image: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Int8List> _preprocessImage(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image.');

    print('Original Image Dimensions: ${image.width}x${image.height}');

    final resizedImage = img.copyResize(image, width: 224, height: 224);
    print('Resized Image Dimensions: ${resizedImage.width}x${resizedImage.height}');

    final byteBuffer = resizedImage.getBytes(order: img.ChannelOrder.rgb);

    // Convert to quantized Int8 values
    final int8Buffer = Int8List(224 * 224 * 3);
    for (int i = 0; i < byteBuffer.length; i++) {
      // Convert to float in range [0, 1]
      double normalizedValue = byteBuffer[i] / 255.0;

      // Apply quantization formula: q = (r / scale) + zero_point
      double quantizedValue = (normalizedValue / _inputScale) + _inputZeroPoint;

      // Clamp to Int8 range and convert to integer
      int8Buffer[i] = quantizedValue.round().clamp(-128, 127);
    }

    return int8Buffer;
  }

  String _postProcessOutput(Int8List output) {
    // Dequantize the output: r = (q - zero_point) * scale
    List<double> dequantizedOutput = output.map((q) {
      return (q - _outputZeroPoint) * _outputScale;
    }).toList();

    // Get probabilities
    final nonASD = dequantizedOutput[0];
    final asd = dequantizedOutput[1];

    // Calculate confidence and determine label
    final confidence = asd > nonASD ? asd : nonASD;
    final label = asd > nonASD ? 'ASD' : 'Non-ASD';

    return '$label (${(confidence * 100).toStringAsFixed(2)}%)';
  }

  Future<void> _saveAnalysisResult(String result) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('No authenticated user found.');
      throw Exception('User not authenticated');
    }

    try {
      final response = await supabase.from('ai_analysis').insert({
        'analysis_id': _uuid.v4(),
        'user_id': userId,
        'result': result,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }).select();

      print('Analysis result saved successfully: $response');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving analysis result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save analysis: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw Exception('Failed to save analysis result: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Analysis',
          style: TextStyle(
            color: Colors.white, // **Set the text color to white**
            fontWeight: FontWeight.bold, // Optional: Make the text bold
          ),
        ),
        backgroundColor: const Color(0xFF2E225A),
        iconTheme: const IconThemeData(color: Colors.white), // Optional: Set icon colors to white
        elevation: 0, // Optional: Remove the default shadow for a flat look
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_analysisResult != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Analysis Result: $_analysisResult',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF2E225A),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Upload Image',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            if (_analysisResult != null)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF2E225A),
                ),
                child: const Text(
                  'Return to Home',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}
