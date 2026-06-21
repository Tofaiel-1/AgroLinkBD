import 'package:flutter/material.dart';

/// System Settings Screen
/// Features: Platform configuration, feature toggles, commission settings, security settings
class AdminSystemSettingsScreen extends StatefulWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  State<AdminSystemSettingsScreen> createState() =>
      _AdminSystemSettingsScreenState();
}

class _AdminSystemSettingsScreenState extends State<AdminSystemSettingsScreen> {
  bool _maintenanceMode = false;
  bool _enableDriverModule = true;
  bool _enableServiceProvider = true;
  bool _enableReferralProgram = false;
  bool _enforce2FA = true;
  String _timezone = 'Asia/Dhaka';
  double _platformFee = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('System Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsCategoryGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // General Settings
        _buildSettingCard(
          'General Settings',
          [
            _buildSettingField('App Name', 'AGROLINKBD', Icons.edit),
            _buildSettingField(
                'Contact Email', 'support@agrolinkbd.com', Icons.edit),
            _buildSettingField('Support Phone', '+880 1234 567890', Icons.edit),
            _buildToggleSetting('Maintenance Mode', _maintenanceMode,
                (value) => setState(() => _maintenanceMode = value)),
          ],
        ),
        const SizedBox(height: 20),

        // Commission Settings
        _buildSettingCard(
          'Commission Settings',
          [
            _buildSliderSetting('Platform Fee (%)', _platformFee, 0, 30,
                (value) => setState(() => _platformFee = value)),
            _buildSettingField('Driver Commission (%)', '10%', Icons.edit),
            _buildSettingField('Minimum Withdrawal', '৳1,000', Icons.edit),
            _buildSettingField('Referral Bonus', '৳500', Icons.edit),
          ],
        ),
        const SizedBox(height: 20),

        // Feature Toggles
        _buildSettingCard(
          'Feature Toggles',
          [
            _buildToggleSetting('Enable Driver Module', _enableDriverModule,
                (value) => setState(() => _enableDriverModule = value)),
            _buildToggleSetting(
                'Enable Service Provider Module',
                _enableServiceProvider,
                (value) => setState(() => _enableServiceProvider = value)),
            _buildToggleSetting(
                'Enable Referral Program',
                _enableReferralProgram,
                (value) => setState(() => _enableReferralProgram = value)),
            _buildToggleSetting('Enable Wallet System', true, (_) {}),
          ],
        ),
        const SizedBox(height: 20),

        // Security Settings
        _buildSettingCard(
          'Security Settings',
          [
            _buildToggleSetting('Enforce 2FA for Admin', _enforce2FA,
                (value) => setState(() => _enforce2FA = value)),
            _buildSettingField(
                'Password Policy (Min Length)', '8 characters', Icons.edit),
            _buildSettingField('Session Timeout (minutes)', '30', Icons.edit),
            _buildSettingField('Failed Login Attempts Limit', '5', Icons.edit),
          ],
        ),
        const SizedBox(height: 20),

        // Localization
        _buildSettingCard(
          'Localization',
          [
            _buildDropdownSetting('Timezone', _timezone,
                ['Asia/Dhaka', 'Asia/Kolkata', 'UTC', 'Asia/Bangkok']),
            _buildSettingField('Default Currency', 'BDT (৳)', Icons.edit),
            _buildSettingField(
                'Supported Languages', 'Bengali, English', Icons.edit),
          ],
        ),
        const SizedBox(height: 20),

        // API Configuration
        _buildSettingCard(
          'API Configuration',
          [
            _buildSettingField(
                'Google Maps API Key', '•••••••••••', Icons.visibility_off),
            _buildSettingField('SMS Gateway Provider', 'TwilioSMS', Icons.edit),
            _buildSettingField(
                'Firebase Project ID', 'agrolinkbd-prod', Icons.lock),
          ],
        ),
        const SizedBox(height: 20),

        // Data Management
        _buildSettingCard(
          'Data Management',
          [
            _buildSettingField(
                'Backup Schedule', 'Daily at 2:00 AM', Icons.edit),
            _buildSettingField('Backup Retention (days)', '30', Icons.edit),
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manual backup initiated'))),
              icon: const Icon(Icons.backup),
              label: const Text('Manual Backup'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved successfully!'))),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669)),
            child: const Text('Save All Settings'),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...children
              .asMap()
              .entries
              .map((entry) => Column(
                    children: [
                      entry.value,
                      if (entry.key < children.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSettingField(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        IconButton(
          icon: Icon(icon, color: Colors.white54),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildToggleSetting(
      String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF059669),
        ),
      ],
    );
  }

  Widget _buildSliderSetting(String label, double value, double min, double max,
      Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${value.toStringAsFixed(1)}%',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 0.1).toInt(),
          onChanged: onChanged,
          activeColor: const Color(0xFF059669),
          inactiveColor: Colors.white.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildDropdownSetting(
      String label, String value, List<String> options) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        DropdownButton<String>(
          value: value,
          items: options
              .map((String option) => DropdownMenuItem(
                  value: option,
                  child: Text(option,
                      style: const TextStyle(color: Colors.white))))
              .toList(),
          onChanged: (newValue) =>
              setState(() => _timezone = newValue ?? _timezone),
          dropdownColor: const Color(0xFF1F2937),
          style: const TextStyle(color: Colors.white),
          underline: Container(),
        ),
      ],
    );
  }
}
