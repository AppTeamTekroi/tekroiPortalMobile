import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileLinkWidget extends StatelessWidget {
  final String? url;
  final String title;

  const FileLinkWidget({
    Key? key,
    required this.url,
    this.title = "View uploaded file",
  }) : super(key: key);

  Future<void> _launchFileUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const SizedBox(); // nothing if no file
    }

    return InkWell(
      onTap: () => _launchFileUrl(url!),
      child: Row(
        children: [
          const Icon(Icons.link, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}