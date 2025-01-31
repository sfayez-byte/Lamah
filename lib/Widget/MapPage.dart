/*import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Map Page',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E225A)),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _getLocationAndOpenMaps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable them.';
      }

      // 2. Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are required to find nearby hospitals';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them in settings.';
      }

      // 3. Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best
      );

      // 4. Open maps with coordinates
      final url = Uri.parse(
        'https://www.google.com/maps/search/hospitals/@${position.latitude},'
        '${position.longitude},15z'
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch maps application';
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Healthcare Map',
        style: TextStyle(color: Colors.white), // Set the text color to white
      ),
      backgroundColor: const Color(0xFF2E225A),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_hospital,
            size: 64,
            color: Color(0xFF2E225A),
          ),
          const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _getLocationAndOpenMaps,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E225A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30, 
                        vertical: 15
                      ),
                    ),
                    child: const Text(
                      'Find Nearest Hospitals',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}