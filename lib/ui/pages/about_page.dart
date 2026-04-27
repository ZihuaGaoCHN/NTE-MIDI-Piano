import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_strings.dart';

class AboutPage extends StatelessWidget {
  final VoidCallback onBack;
  const AboutPage({super.key, required this.onBack});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(top: Platform.isMacOS ? 28 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: onBack,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.get(context, 'about'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/app_icon.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'NTE-MIDI-Piano',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoItem(
                        context: context,
                        title: AppStrings.get(context, 'version'),
                        value: '1.0.0',
                      ),
                      const Divider(height: 1),
                      _buildInfoItem(
                        context: context,
                        title: AppStrings.get(context, 'author'),
                        value: AppStrings.get(context, 'authorName'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildLinkItem(
                        context: context,
                        icon: FontAwesomeIcons.github,
                        title: AppStrings.get(context, 'projectGithub'),
                        url: 'https://github.com/ZihuaGaoCHN/NTE-MIDI-Piano/',
                      ),
                      const Divider(height: 1),
                      _buildLinkItem(
                        context: context,
                        icon: FontAwesomeIcons.bilibili,
                        title: AppStrings.get(context, 'authorBilibili'),
                        url: 'https://space.bilibili.com/241304457',
                        iconSize: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    AppStrings.get(context, 'macOsWarning'),
                    style: const TextStyle(color: Colors.orange, fontSize: 13, height: 1.5),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required BuildContext context,
    required dynamic icon,
    required String title,
    required String url,
    double iconSize = 20,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(icon, size: iconSize, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.open_in_new, size: 18, color: Theme.of(context).disabledColor.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

