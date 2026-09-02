import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/weather_model.dart';
import 'package:agrolinkbd/core/services/weather_service.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/constants/bd_location_data.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class WeatherCardWidget extends StatefulWidget {
  final String? customDistrict;
  final String? customUpazila;
  final bool isFisheriesTheme;
  final bool isCompact;

  const WeatherCardWidget({
    super.key,
    this.customDistrict,
    this.customUpazila,
    this.isFisheriesTheme = false,
    this.isCompact = true,
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

  @override
  void didUpdateWidget(covariant WeatherCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customDistrict != widget.customDistrict ||
        oldWidget.customUpazila != widget.customUpazila) {
      _loadWeather();
    }
  }

  Future<void> _loadWeather() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    String? dist = _selectedDistrict ?? widget.customDistrict ?? user?.district;
    String? upa = _selectedUpazila ?? widget.customUpazila ?? user?.upazila;

    // Address fallback if upazila is missing from user profile
    if ((upa == null || upa.isEmpty) && user?.address != null) {
      final addr = user!.address!.toLowerCase();
      if (addr.contains('gurudaspur') || addr.contains('গুরুদাসপুর')) {
        upa = 'Gurudaspur';
        dist = 'Natore';
      } else if (addr.contains('singra') || addr.contains('সিংড়া')) {
        upa = 'Singra';
        dist = 'Natore';
      } else if (addr.contains('baraigram') || addr.contains('বড়াইগ্রাম')) {
        upa = 'Baraigram';
        dist = 'Natore';
      } else if (addr.contains('natore') || addr.contains('নাটোর')) {
        upa = 'Natore Sadar';
        dist = 'Natore';
      } else if (addr.contains('gazipur') || addr.contains('গাজীপুর')) {
        dist = 'Gazipur';
      }
    }

    try {
      final weather = await WeatherService().fetchCurrentWeather(
        userDistrict: dist,
        userUpazila: upa,
        forceGps: false,
      );

      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String fallbackBn = upa != null
            ? '${WeatherService.getBanglaUpazilaName(upa)}, ${dist != null ? WeatherService.getBanglaUpazilaName(dist) : "পটুয়াখালী"}'
            : 'দুমকি, পটুয়াখালী (বরিশাল)';
        String fallbackEn = upa != null
            ? '${WeatherService.getEnglishUpazilaName(upa)}, ${dist ?? "Patuakhali"}'
            : 'Dumki, Patuakhali (Barishal)';
        setState(() {
          _weather = WeatherModel.defaultFallback(fallbackBn, locationEn: fallbackEn);
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

            final isBn = LanguageProvider.isBn(context);

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
                        isBn ? 'অবস্থান নির্বাচন করুন' : 'Select Location',
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
                    hint: Text(isBn ? 'বিভাগ নির্বাচন করুন' : 'Select Division'),
                    items: divisions
                        .map((div) => DropdownMenuItem<String>(
                              value: div,
                              child: Text(isBn ? WeatherService.getBanglaUpazilaName(div) : div),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        tempDiv = val;
                        tempDist = null;
                        tempUpa = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: isBn ? 'বিভাগ' : 'Division',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // District Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: tempDist,
                    hint: Text(isBn ? 'জেলা নির্বাচন করুন' : 'Select District'),
                    items: districts
                        .map((dist) => DropdownMenuItem<String>(
                              value: dist,
                              child: Text(isBn ? WeatherService.getBanglaUpazilaName(dist) : dist),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        tempDist = val;
                        tempUpa = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: isBn ? 'জেলা' : 'District',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Upazila Dropdown
                  if (upazilas.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: tempUpa,
                      hint: Text(isBn ? 'উপজেলা নির্বাচন করুন' : 'Select Upazila'),
                      items: upazilas
                          .map((upa) => DropdownMenuItem<String>(
                                value: upa,
                                child: Text(isBn ? WeatherService.getBanglaUpazilaName(upa) : upa),
                              ))
                          .toList(),
                      onChanged: (val) => setModalState(() => tempUpa = val),
                      decoration: InputDecoration(
                        labelText: isBn ? 'উপজেলা' : 'Upazila',
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
                        isBn ? 'আবহাওয়া আপডেট করুন' : 'Update Weather',
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

  void _showDetailedWeatherBottomSheet(WeatherModel weather) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LanguageProvider.isBn(context) ? 'বিস্তারিত আবহাওয়া পূর্বাভাস' : 'Detailed Weather Forecast',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        weather.getLocationDisplayName(LanguageProvider.isBn(context)),
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 24-Hour Forecast Section
                      Text(
                        LanguageProvider.isBn(context) ? '২৪ ঘণ্টার পূর্বাভাস' : '24-Hour Forecast',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: weather.hourlyForecast.length,
                          itemBuilder: (context, index) {
                            final h = weather.hourlyForecast[index];
                            final bool isBn = LanguageProvider.isBn(context);
                            return Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2A2A3C) : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? Colors.grey.shade800 : Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    h.getTime(isBn),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(_getWeatherIcon(h.weatherCode), size: 22, color: Colors.amber.shade700),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${h.temperature.toStringAsFixed(0)}°C',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  if (h.rainProbability > 0)
                                    Text(
                                      '🌧️${h.rainProbability}%',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 7-Day Extended Forecast Section
                      Text(
                        LanguageProvider.isBn(context) ? '৭ দিনের আবহাওয়া পূর্বাভাস' : '7-Day Extended Forecast',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: weather.dailyForecast.map((d) {
                          final bool isBn = LanguageProvider.isBn(context);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A3C) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    d.getDayName(isBn),
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(_getWeatherIcon(d.weatherCode), size: 20, color: Colors.amber.shade700),
                                    const SizedBox(width: 8),
                                    if (d.rainProbability > 0)
                                      Text(
                                        '${d.rainProbability}% ${isBn ? "বৃষ্টি" : "Rain"}',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 12,
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${d.maxTemp.toStringAsFixed(0)}°',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${d.minTemp.toStringAsFixed(0)}°',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Extra Weather Metrics Breakdown
                      Text(
                        LanguageProvider.isBn(context) ? 'পরিবেশ ও বায়ুমণ্ডলীয় মেট্রিক্স' : 'Environmental Metrics',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          _buildDetailGridCard('☀️ UV Index', weather.uvIndex.toStringAsFixed(1), isDark),
                          _buildDetailGridCard(LanguageProvider.isBn(context) ? '🌧️ বৃষ্টিপাত' : '🌧️ Rainfall', '${weather.rainMm.toStringAsFixed(1)} mm', isDark),
                          _buildDetailGridCard(LanguageProvider.isBn(context) ? '💨 বাতাসের দিক' : '💨 Wind Direction', weather.windDirectionText, isDark),
                          _buildDetailGridCard(LanguageProvider.isBn(context) ? '🌡️ অনুভব তাপমাত্রা' : '🌡️ Feels Like', '${weather.feelsLike.toStringAsFixed(1)}°C', isDark),
                          _buildDetailGridCard(LanguageProvider.isBn(context) ? '⏲️ বায়ুচাপ' : '⏲️ Pressure', '${weather.pressureHpa.toStringAsFixed(0)} hPa', isDark),
                          _buildDetailGridCard(LanguageProvider.isBn(context) ? '☁️ মেঘের ঘনত্ব' : '☁️ Cloud Cover', '${weather.cloudCoverPercent}%', isDark),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Live Weather News & Agriculture Advisories Section
                      Text(
                        LanguageProvider.isBn(context) ? '📰 সর্বশেষ আবহাওয়া সংবাদ ও কৃষি পরামর্শ' : '📰 Latest Weather News & Agri Advisory',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFA5D6A7),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.newspaper, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    LanguageProvider.isBn(context) 
                                        ? '${weather.locationName} এলাকার আবহাওয়া বিশেষ বুলেটিন'
                                        : '${weather.locationName} Area Weather Bulletin',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.green.shade300 : Colors.green.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weather.getAgriAdviceText(LanguageProvider.isBn(context)),
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                height: 1.5,
                                color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Divider(color: isDark ? Colors.white12 : Colors.black12),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LanguageProvider.isBn(context) 
                                      ? 'উৎস: বাংলাদেশ আবহাওয়া অধিদপ্তর ও Open-Meteo Live'
                                      : 'Source: Bangladesh Meteorological Dept & Open-Meteo',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  LanguageProvider.isBn(context) ? 'আপডেট: এইমাত্র' : 'Update: Just now',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailGridCard(String label, String val, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3C) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.hindSiliguri(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
          Text(val, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
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
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: gradientColors),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final weather = _weather ?? WeatherModel.defaultFallback('গুরুদাসপুর, নাটোর');
    final bool isBn = LanguageProvider.isBn(context);

    return GestureDetector(
      onTap: () => _showDetailedWeatherBottomSheet(weather),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(widget.isCompact ? 14 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        weather.getLocationDisplayName(isBn),
                        style: GoogleFonts.hindSiliguri(
                          fontSize: widget.isCompact ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(Icons.my_location, color: Colors.white, size: 18),
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        final w = await WeatherService().fetchCurrentWeather(forceGps: true);
                        if (mounted) {
                          setState(() {
                            _weather = w;
                            _isLoading = false;
                          });
                        }
                      },
                      tooltip: isBn ? 'জিপিএস অবস্থান ব্যবহার করুন' : 'Use GPS Location',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                      onPressed: _loadWeather,
                      tooltip: isBn ? 'আবহাওয়া রিফ্রেশ করুন' : 'Refresh Weather',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: widget.isCompact ? 8 : 12),

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
                            fontSize: widget.isCompact ? 32 : 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'C',
                          style: GoogleFonts.poppins(
                            fontSize: widget.isCompact ? 18 : 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${weather.getConditionText(isBn)} • ${isBn ? "অনুভব" : "Feels"}: ${weather.feelsLike.toStringAsFixed(1)}°C',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: widget.isCompact ? 12 : 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                Icon(
                  _getWeatherIcon(weather.weatherCode),
                  size: widget.isCompact ? 48 : 64,
                  color: Colors.amber.shade300,
                ),
              ],
            ),
            SizedBox(height: widget.isCompact ? 10 : 16),

            // Weather Metrics Grid (Rain, Wind & Direction, Humidity, UV)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem(
                    icon: Icons.umbrella,
                    label: isBn ? 'বৃষ্টির সম্ভাবনা' : 'Rain Chance',
                    value: '${weather.rainProbability}%',
                  ),
                  Container(height: 20, width: 1, color: Colors.white24),
                  _buildMetricItem(
                    icon: Icons.air,
                    label: isBn 
                        ? 'বাতাস (${weather.getWindDirection(true)})'
                        : 'Wind (${weather.getWindDirection(false)})',
                    value: '${weather.windSpeedKmH.toStringAsFixed(1)} km/h',
                  ),
                  Container(height: 20, width: 1, color: Colors.white24),
                  _buildMetricItem(
                    icon: Icons.water_drop,
                    label: isBn ? 'আর্দ্রতা' : 'Humidity',
                    value: '${weather.humidity}%',
                  ),
                ],
              ),
            ),
            SizedBox(height: widget.isCompact ? 8 : 14),

            // Agricultural Advice Alert Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      weather.getAgriAdviceText(isBn),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 12),
                ],
              ),
            ),
            SizedBox(height: widget.isCompact ? 8 : 12),

            // Next 3-Hour Rain & Temp Mini Forecast Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'পরবর্তী ৩ ঘণ্টার বৃষ্টির সম্ভাবনা' : 'Next 3-Hour Rain Probability',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        isBn ? 'বিস্তারিত দেখুন →' : 'View Details →',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          color: Colors.amber.shade300,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weather.hourlyForecast.take(3).map((h) {
                      final isHighRain = h.rainProbability >= 40;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isHighRain
                              ? Colors.blue.shade900.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isHighRain
                                ? Colors.cyanAccent.withValues(alpha: 0.5)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              h.getTime(isBn),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _getWeatherIcon(h.weatherCode),
                              size: 14,
                              color: isHighRain ? Colors.cyanAccent : Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${h.rainProbability}%',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isHighRain ? Colors.cyanAccent : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
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
