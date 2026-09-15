import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/profile_theme.dart';

class EvidencePreviewDialog extends StatefulWidget {
  const EvidencePreviewDialog({
    super.key,
    required this.filename,
    required this.loadUrl,
  });
  final String filename;
  final Future<String> Function() loadUrl;
  @override
  State<EvidencePreviewDialog> createState() => _EvidencePreviewDialogState();
}

class _EvidencePreviewDialogState extends State<EvidencePreviewDialog> {
  late final Future<String> _url = widget.loadUrl();
  bool _openFailed = false;
  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.filename,
                    style: ProfileTheme.heading.copyWith(fontSize: 23),
                  ),
                ),
                IconButton(
                  tooltip: 'Close preview',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: FutureBuilder<String>(
                future: _url,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Could not load this attachment. Check your access and try again.',
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (widget.filename.toLowerCase().endsWith('.pdf')) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.picture_as_pdf_outlined, size: 56),
                        const SizedBox(height: 16),
                        const Text('PDF document'),
                        TextButton.icon(
                          onPressed: () async {
                            try {
                              if (!await launchUrl(Uri.parse(snapshot.data!))) {
                                throw StateError('Cannot open PDF');
                              }
                            } catch (_) {
                              if (mounted) setState(() => _openFailed = true);
                            }
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open PDF'),
                        ),
                        if (_openFailed)
                          const Text(
                            'Could not open the PDF. Please try again.',
                          ),
                      ],
                    );
                  }
                  return InteractiveViewer(
                    minScale: .5,
                    maxScale: 5,
                    child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                      errorBuilder: (_, error, stack) => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'The image could not be loaded. Close the preview and try again.',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
