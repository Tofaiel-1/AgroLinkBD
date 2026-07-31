import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/weather_model.dart';
import 'package:agrolinkbd/core/services/weather_service.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/constants/bd_location_data.dart';

class WeatherCardWidget extends StatefulWidget {
  final String? customDistrict;
  final String? customUpazila;
  final bool isFisheriesTheme;

  const WeatherCardWidget({
    super.key,
    this.customDistrict,
    this.customUpazila,
    this.isFisheriesTheme = false,
  });

  @override
  State<WeatherCardWidget> createState() => _WeatherCardWidgetState();
}

class _WeatherCardWidgetState extends State<WeatherCardWidget> {
  WeatherModel? _weather;
  bool _isLoading = true;
  String? _selectedDistrict;
  String? _selectedUpazila;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    String? dist = _selectedDistrict ?? widget.customDistrict ?? user?.district;
    String? upa = _selectedUpazila ?? widget.customUpazila ?? user?.upazila;

    try {
      final weather = await WeatherService().fetchCurrentWeather(
        userDistrict: dist,
        userUpazila: upa,
        userLat: user?.latitude,
        userLng: user?.longitude,
      );

      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weather = WeatherModel.defaultFallback(dist ?? 'গাজীপুর');
          _isLoading = false;
        });
      }
    }
  }

  void _showLocationPicker() {
    String? tempDiv;
    String? tempDist = _selectedDistrict;
    String? tempUpa = _selectedUpazila;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final divisions = BDLocationData.divisions;
            final districts = tempDiv != null ? (BDLocationData.districtsByDivision[tempDiv] ?? []) : [];
            final upazilas = tempDist != null ? (BDLocationData.upazilasByDistrict[tempDist] ?? []) : [];

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'অবস্থান নির্বাচন করুন',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Division Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: tempDiv,
                    hint: const Text('বিভাগ নির্বাচন করুন'),
                    items: divisions.map((div) => DropdownMenuItem<String>(value: div, child: Text(div))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        tempDiv = val;
                        tempDist = null;
                        tempUpa = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'বিভাগ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // District Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: tempDist,
                    hint: const Text('জেলা নির্বাচন করুন'),
                    items: districts.map((dist) => DropdownMenuItem<String>(value: dist, child: Text(dist))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        tempDist = val;
                        tempUpa = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'জেলা',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Upazila Dropdown
                  if (upazilas.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: tempUpa,
                      hint: const Text('উপজেলা নির্বাচন করুন'),
                      items: upazilas.map((upa) => DropdownMenuItem<String>(value: upa, child: Text(upa))).toList(),
                      onChanged: (val) => setModalState(() => tempUpa = val),
                      decoration: InputDecoration(
                        labelText: 'উপজেলা',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedDistrict = tempDist;
                          _selectedUpazila = tempUpa;
                        });
                        _loadWeather();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'আবহাওয়া আপডেট করুন',
                        style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getWeatherIcon(int code) {
    if (code >= 95) return Icons.thunderstorm;
    if (code >= 80) return Icons.grain;
    if (code >= 61) return Icons.umbrella;
    if (code >= 51) return Icons.water_drop;
    if (code >= 45) return Icons.cloud;
    if (code >= 1) return Icons.cloud_queue;
    return Icons.wb_sunny;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = widget.isFisheriesTheme
        ? (isDark
            ? [const Color(0xFF01579B), const Color(0xFF006064)]
            : [const Color(0xFF0288D1), const Color(0xFF00ACC1)])
        : (isDark
            ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
            : [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]);

    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: gradientColors),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final weather = _weather ?? WeatherModel.defaultFallback('গাজীপুর');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Location Name & Picker Trigger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _showLocationPicker,
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      weather.locationName,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                    onPressed: _loadWeather,
                    tooltip: 'আবহাওয়া রিফ্রেশ করুন',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Temperature & Condition
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°',
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'C',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weather.condition} • অনুভব: ${weather.feelsLike.toStringAsFixed(1)}°C',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Icon(
                _getWeatherIcon(weather.weatherCode),
                size: 64,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weather Metrics Grid (Rain, Wind, Humidity)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  icon: Icons.water_drop,
                  label: 'বৃষ্টি',
                  value: weather.rainMm > 0 ? '${weather.rainMm.toStringAsFixed(1)} mm' : '${weather.rainProbability}%',
                ),
                Container(height: 24, width: 1, color: Colors.white24),
                _buildMetricItem(
                  icon: Icons.air,
                  label: 'বাতাসের গতি',
                  value: '${weather.windSpeedKmH.toStringAsFixed(1)} km/h',
                ),
                Container(height: 24, width: 1, color: Colors.white24),
                _buildMetricItem(
                  icon: Icons.water,
                  label: 'আর্দ্রতা',
                  value: '${weather.humidity}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Agricultural Advice Alert
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    weather.agriAdvice,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
