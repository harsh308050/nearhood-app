import 'dart:async';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

final String apiBaseUrl =
    dotenv.env['BASE_URL'] ?? 'https://nearhood-api.onrender.com/api';
final String cleanBaseUrl = apiBaseUrl.replaceAll('/api', '');
void sharePost(PostModel post) {
  final String shareUrl = '$cleanBaseUrl/share/posts/${post.id}';

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

Future<void> copyPostLinkToClipboard(String postId) async {
  final String postUrl = '$cleanBaseUrl/share/posts/$postId';
  await Clipboard.setData(ClipboardData(text: postUrl));
}
