/// Validates local paths for receipt photo attachments.
class ReceiptImageValidator {
  ReceiptImageValidator._();

  static const supportedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'gif',
  ];

  static bool isSupportedPath(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return false;
    return supportedExtensions.contains(
      path.substring(dot + 1).toLowerCase(),
    );
  }
}
