import 'package:flutter/material.dart';

/// System Settings & Configuration Screen
/// Features: App settings, email configuration, SMS gateway, payment settings, security settings
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  int _selectedTab = 0;

  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool _twoFactorAuth = true;
  bool _maintenanceMode = false;
  bool _testMode = true;

  final tabs = [
    'General',
    'Email',
    'SMS',
    'Payment',
    'Security',
    'Integrations'
  ];

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
        child: Column(
          children: [
            // Tab navigation
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (context, index) => _buildTab(index),
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.1)),

            // Tab content
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF059669) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            tabs[index],
            style: TextStyle(
              color: isActive ? const Color(0xFF059669) : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildGeneralSettings();
      case 1:
        return _buildEmailSettings();
      case 2:
        return _buildSmsSettings();
      case 3:
        return _buildPaymentSettings();
      case 4:
        return _buildSecuritySettings();
      case 5:
        return _buildIntegrationSettings();
      default:
        return const SizedBox();
    }
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        _buildSettingField('App Name', 'AGROLINKBD'),
        const SizedBox(height: 16),
        _buildSettingField('Company Email', 'support@agrolinkbd.com'),
        const SizedBox(height: 16),
        _buildSettingField('Support Phone', '+880 1234 567890'),
        const SizedBox(height: 16),
        _buildSettingField('Company Address', 'Dhaka, Bangladesh'),
        const SizedBox(height: 24),
        _buildToggleSetting('Maintenance Mode', _maintenanceMode, (value) {
          setState(() => _maintenanceMode = value);
        }),
        const SizedBox(height: 16),
        _buildToggleSetting('Test Mode', _testMode, (value) {
          setState(() => _testMode = value);
        }),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved successfully')),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF059669),
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildEmailSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Configuration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        _buildSettingField('SMTP Host', 'smtp.gmail.com'),
        const SizedBox(height: 16),
        _buildSettingField('SMTP Port', '587'),
        const SizedBox(height: 16),
        _buildSettingField('Email Address', 'noreply@agrolinkbd.com'),
        const SizedBox(height: 16),
        _buildPasswordField('Email Password', '••••••••'),
        const SizedBox(height: 24),
        _buildToggleSetting('Enable Email Notifications', _emailNotifications,
            (value) {
          setState(() => _emailNotifications = value);
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test email sent')),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Test Connection'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email settings saved')),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmsSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SMS Gateway Configuration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        _buildDropdownField(
            'SMS Provider', 'Twilio', ['Twilio', 'Nexmo', 'AWS SNS']),
        const SizedBox(height: 16),
        _buildSettingField('Account SID', 'AC••••••••••••••••'),
        const SizedBox(height: 16),
        _buildPasswordField('Auth Token', '••••••••'),
        const SizedBox(height: 16),
        _buildSettingField('Sender ID', 'AGROLINKBD'),
        const SizedBox(height: 24),
        _buildToggleSetting('Enable SMS Notifications', _smsNotifications,
            (value) {
          setState(() => _smsNotifications = value);
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test SMS sent')),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Test Connection'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SMS settings saved')),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Gateway Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        _buildToggleSetting('Enable Flutterwave', true, (value) {}),
        const SizedBox(height: 16),
        _buildSettingField('Flutterwave Public Key', 'FLWPUBK_TEST••••••••'),
        const SizedBox(height: 16),
        _buildPasswordField('Flutterwave Secret Key', '••••••••'),
        const SizedBox(height: 24),
        _buildToggleSetting('Enable bKash', true, (value) {}),
        const SizedBox(height: 16),
        _buildSettingField('bKash App Key', 'app_key••••••'),
        const SizedBox(height: 16),
        _buildPasswordField('bKash App Secret', '••••••••'),
        const SizedBox(height: 24),
        _buildToggleSetting('Enable Nagad', false, (value) {}),
        const SizedBox(height: 16),
        _buildSettingField('Transaction Commission', '2.5%'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment settings saved')),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF059669),
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        _buildToggleSetting('Two-Factor Authentication', _twoFactorAuth,
            (value) {
          setState(() => _twoFactorAuth = value);
        }),
        const SizedBox(height: 16),
        _buildToggleSetting('IP Whitelisting', true, (value) {}),
        const SizedBox(height: 16),
        _buildSettingField('Password Min Length', '8 characters'),
        const SizedBox(height: 16),
        _buildToggleSetting('Require Special Characters', true, (value) {}),
        const SizedBox(height: 16),
        _buildSettingField('Session Timeout', '30 minutes'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Danger Zone',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Reset all security settings to default',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    _showConfirmationDialog('Reset Security Settings?'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Reset to Default'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntegrationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Third-party Integrations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        _buildIntegrationCard(
          'Google Maps',
          'Location services and mapping',
          true,
          'Configure',
        ),
        const SizedBox(height: 12),
        _buildIntegrationCard(
          'Firebase Analytics',
          'Application analytics and tracking',
          true,
          'Configure',
        ),
        const SizedBox(height: 12),
        _buildIntegrationCard(
          'Stripe Payments',
          'International payment processing',
          false,
          'Enable',
        ),
        const SizedBox(height: 12),
        _buildIntegrationCard(
          'AWS S3 Storage',
          'Cloud file storage and backup',
          false,
          'Enable',
        ),
      ],
    );
  }

  Widget _buildIntegrationCard(
    String title,
    String description,
    bool isEnabled,
    String action,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isEnabled ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isEnabled ? Colors.green : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$action $title')),
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: options
                .map((option) => DropdownMenuItem(
                      value: option,
                      child: Text(option,
                          style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
            onChanged: (newValue) => setState(() {}),
            style: const TextStyle(color: Colors.white),
            dropdownColor: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSetting(
      String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF059669),
        ),
      ],
    );
  }

  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Confirm Action'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message.replaceAll('?', ' completed'))),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
