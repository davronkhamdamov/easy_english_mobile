import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/youtube_listening_repository.dart';
import '../widgets/youtube_search_tab.dart';

class YoutubeListeningScreen extends StatefulWidget {
  const YoutubeListeningScreen({super.key});

  @override
  State<YoutubeListeningScreen> createState() => _YoutubeListeningScreenState();
}

class _YoutubeListeningScreenState extends State<YoutubeListeningScreen> {
  late final YoutubeListeningRepository _repository;

  @override
  void initState() {
    super.initState();
    // Use ApiClient base URL (fallback to localhost:9000 or default)
    _repository = YoutubeListeningRepository(
      apiBaseUrl: ApiClient.baseUrl.contains(':8080')
          ? ApiClient.baseUrl.replaceAll(':8080', ':9000')
          : 'http://172.20.10.4:9000',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 19,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.headphones_rounded,
                color: theme.colorScheme.surface,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: 'Listen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  color: theme.colorScheme.surface,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: YoutubeSearchTab(repository: _repository),
        ),
      ),
    );
  }
}
