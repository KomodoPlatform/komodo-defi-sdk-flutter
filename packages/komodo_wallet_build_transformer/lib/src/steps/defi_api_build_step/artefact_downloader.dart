import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:komodo_wallet_build_transformer/src/steps/models/api/api_file_matching_config.dart';

abstract class ArtefactDownloader {
  ArtefactDownloader({
    required this.apiCommitHash,
    required this.sourceUrl,
    required this.apiBranch,
  });

  final String apiCommitHash;
  final String sourceUrl;
  final String apiBranch;

  Future<String> fetchDownloadUrl(
    ApiFileMatchingConfig matchingConfig,
    String platform,
  );

  Future<String> downloadArtefact({
    required String url,
    required String destinationPath,
  });

  Future<void> extractArtefact({
    required String filePath,
    required String destinationFolder,
  });
}

extension ResponseCode on http.Response {
  void throwIfNotSuccessResponse() {
    if (statusCode != 200) {
      throw HttpException(
        'Failed to fetch data: $statusCode $reasonPhrase',
      );
    }
  }
}
