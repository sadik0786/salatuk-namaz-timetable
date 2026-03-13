import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/widgets/tr_text.dart';
import 'package:namaz_timetable/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModal extends StatefulWidget {
  final String currentCity;
  final String currentCountry;

  const SettingsModal({super.key, required this.currentCity, required this.currentCountry});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool isAutoDetectLocation = true;
  bool isDetectingLocation = false;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _cityController.text = widget.currentCity;
    _countryController.text = widget.currentCountry;
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isAuto = prefs.getBool('isAutoDetectLocation') ?? true;
    setState(() {
      isAutoDetectLocation = isAuto;
    });

    if (isAuto) {
      // Auto-fetch on load as per user request
      _fetchExactLocation();
    }
  }

  void _onToggleAutoDetect(bool value) async {
    setState(() {
      isAutoDetectLocation = value;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAutoDetectLocation', value);

    if (value) {
      await _fetchExactLocation();
    } else {
      // Clear coordinates in manual mode so the API uses text entries
      setState(() {
        latitude = null;
        longitude = null;
      });
    }
  }

  Future<void> _fetchExactLocation() async {
    setState(() => isDetectingLocation = true);
    final loc = await LocationService.getCurrentLocation();
    if (!mounted) return;

    if (loc != null) {
      setState(() {
        latitude = loc.latitude;
        longitude = loc.longitude;
        _areaController.text = loc.area;
        _cityController.text = loc.city;
        _stateController.text = loc.state;
        _countryController.text = loc.country;
        _pincodeController.text = loc.pincode;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not obtain GPS location'.tr)));
    }
    setState(() => isDetectingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TrText(
                  'Location Settings',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Auto Detect Location".tr),
              value: isAutoDetectLocation,
              onChanged: _onToggleAutoDetect,
            ),

            if (isDetectingLocation)
              const Center(
                child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
              )
            else if (!isAutoDetectLocation) ...[
              _buildTextField(_areaController, "Area".tr),
              const SizedBox(height: 10),
              _buildTextField(_cityController, "City".tr),
              const SizedBox(height: 10),
              _buildTextField(_stateController, "State".tr),
              const SizedBox(height: 10),
              _buildTextField(_countryController, "Country".tr),
              const SizedBox(height: 10),
              _buildTextField(_pincodeController, "Pincode".tr),
            ] else if (_areaController.text.isNotEmpty || _cityController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${_areaController.text}, ${_cityController.text}, ${_stateController.text}, ${_countryController.text} - ${_pincodeController.text}",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: TrText('Cancel'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(onPressed: _saveSettings, child: TrText('Save')),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }

  Future<void> _saveSettings() async {
    String city = _cityController.text.trim();
    String country = _countryController.text.trim();

    if (city.isEmpty || country.isEmpty) {
      if (!isAutoDetectLocation) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter city and country'.tr)));
        return;
      }
    }

    // Small loading indicator for geocoding
    if (!isAutoDetectLocation && latitude == null) {
      final coords = await LocationService.getCoordinatesFromAddress(city, country);
      if (coords != null) {
        latitude = coords['latitude'];
        longitude = coords['longitude'];
      }
    }

    if (!mounted) return;
    Navigator.pop(context, {
      'area': _areaController.text.trim(),
      'city': city,
      'state': _stateController.text.trim(),
      'country': country,
      'pincode': _pincodeController.text.trim(),
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  @override
  void dispose() {
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }
}
