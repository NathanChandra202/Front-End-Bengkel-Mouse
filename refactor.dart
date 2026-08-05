import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('theme.dart')) continue;

    String content = file.readAsStringSync();
    bool modified = false;

    if (content.contains('AppTheme.backgroundColor')) {
      content = content.replaceAll('AppTheme.backgroundColor', 'Theme.of(context).scaffoldBackgroundColor');
      modified = true;
    }
    if (content.contains('AppTheme.surfaceColor')) {
      content = content.replaceAll('AppTheme.surfaceColor', 'Theme.of(context).colorScheme.surface');
      modified = true;
    }
    if (content.contains('AppTheme.surfaceHighColor')) {
      content = content.replaceAll('AppTheme.surfaceHighColor', '(Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceHighColor : AppTheme.surfaceHighColorLight)');
      modified = true;
    }
    if (content.contains('AppTheme.textColor')) {
      content = content.replaceAll('AppTheme.textColor', 'Theme.of(context).colorScheme.onSurface');
      modified = true;
    }
    if (content.contains('AppTheme.textMuted')) {
      content = content.replaceAll('AppTheme.textMuted', '(Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)');
      modified = true;
    }
    if (content.contains('AppTheme.borderColor')) {
      content = content.replaceAll('AppTheme.borderColor', 'Theme.of(context).dividerTheme.color!');
      modified = true;
    }
    if (content.contains('AppTheme.primaryDark')) {
       // Keep as is or add if needed
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
