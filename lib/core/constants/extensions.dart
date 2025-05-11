extension StringExtension on String {
  String capitalize() {
    return split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
        })
        .join(' ');
  }
}

extension TruncateExtension on String {
  String truncate(int maxLength, {String omission = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$omission';
  }
}
