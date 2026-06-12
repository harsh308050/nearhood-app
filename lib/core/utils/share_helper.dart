import 'dart:async';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

String getPostDeepLink(String postId) {
  final String apiBaseUrl =
      dotenv.env['BASE_URL'] ?? 'https://nearhood-api.onrender.com/api';
  // Strip trailing '/api' from the base URL to get the web domain
  final String cleanBaseUrl = apiBaseUrl.replaceAll('/api', '');
  return '$cleanBaseUrl/share/posts/$postId';
}

Future<void> copyPostLinkToClipboard(String postId) async {
  final deepLink = getPostDeepLink(postId);
  await Clipboard.setData(ClipboardData(text: deepLink));
}

void sharePost(PostModel post) {
  final String shareUrl = getPostDeepLink(post.id);

  // Format short preview text
  String postContent = post.content.trim();
  if (postContent.length > 100) {
    postContent = '${postContent.substring(0, 100)}...';
  }

  final String sharePrefix = postContent.isEmpty ? '' : '$postContent ';
  final String shareMessage =
      '${sharePrefix}Check this post on Nearhood: $shareUrl';

  unawaited(
    SharePlus.instance.share(
      ShareParams(text: shareMessage, subject: 'Check this post on Nearhood'),
    ),
  );
}
