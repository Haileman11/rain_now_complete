import 'package:flutter/material.dart';
import '../providers/language_provider.dart';

class RainAlertBanner extends StatelessWidget {
  final LanguageProvider language;

  const RainAlertBanner({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.t('rain_expected'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                    fontSize: 16,
                  ),
                ),
                Text(
                  language.t('rain_expected_desc'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}