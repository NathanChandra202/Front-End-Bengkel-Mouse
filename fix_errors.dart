import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // Fix const Icon(..., color: Theme...)
    final iconRegex = RegExp(r'const\s+Icon\(([^,]+),\s*color:\s*(?:\()?Theme\.of\(context\)');
    if (iconRegex.hasMatch(content)) {
      content = content.replaceAllMapped(iconRegex, (m) {
        return 'Icon(${m.group(1)}, color: Theme.of(context)';
      });
      // also handle the case where it was wrapped in parens, but replaceAllMapped already caught the 'color: (Theme.of...' or 'color: Theme.of'
      modified = true;
    }

    final iconRegex2 = RegExp(r'const\s+Icon\(([^,]+),\s*color:\s*\(\s*Theme\.of\(context\)');
    if (iconRegex2.hasMatch(content)) {
      content = content.replaceAllMapped(iconRegex2, (m) {
        return 'Icon(${m.group(1)}, color: (Theme.of(context)';
      });
      modified = true;
    }

    // Fix const Border(top: BorderSide(color: Theme...
    final borderRegex = RegExp(r'const\s+Border\(');
    if (borderRegex.hasMatch(content)) {
      final lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('const Border(') && lines[i].contains('Theme.of(context)')) {
          lines[i] = lines[i].replaceAll('const Border(', 'Border(');
          modified = true;
        } else if (lines[i].contains('const Border(')) {
           // check if next line contains Theme
           if (i + 1 < lines.length && lines[i+1].contains('Theme.of(context)')) {
              lines[i] = lines[i].replaceAll('const Border(', 'Border(');
              modified = true;
           }
        }
      }
      content = lines.join('\n');
    }
    
    // Fix home_screen _statCard and _buildServiceCard
    if (file.path.contains('home_screen.dart')) {
      if (content.contains('_statCard(String val')) {
        content = content.replaceAll('_statCard(String val', '_statCard(BuildContext context, String val');
        content = content.replaceAll('_statCard(\'500+', '_statCard(context, \'500+');
        content = content.replaceAll('_statCard(\'4.9', '_statCard(context, \'4.9');
        content = content.replaceAll('_statCard(\'1', '_statCard(context, \'1');
        modified = true;
      }
      if (content.contains('_buildServiceCard(_ServiceItem s)')) {
        content = content.replaceAll('_buildServiceCard(_ServiceItem s)', '_buildServiceCard(BuildContext context, _ServiceItem s)');
        content = content.replaceAll('_buildServiceCard(services[i])', '_buildServiceCard(context, services[i])');
        modified = true;
      }
    }

    // Fix tracking_detail_screen _infoRow and _buildTimelineNode
    if (file.path.contains('tracking_detail_screen.dart')) {
      if (content.contains('_infoRow(String label')) {
        content = content.replaceAll('_infoRow(String label', '_infoRow(BuildContext context, String label');
        // Now find usages of _infoRow(
        final usages = RegExp(r'_infoRow\([^c]'); // matches _infoRow('...
        if (usages.hasMatch(content)) {
           content = content.replaceAll('_infoRow(\'Merek', '_infoRow(context, \'Merek');
           content = content.replaceAll('_infoRow(\'Model', '_infoRow(context, \'Model');
           content = content.replaceAll('_infoRow(\'Kategori', '_infoRow(context, \'Kategori');
           content = content.replaceAll('_infoRow(\'Keluhan', '_infoRow(context, \'Keluhan');
        }
        modified = true;
      }
      if (content.contains('_buildTimelineNode(int index')) {
        content = content.replaceAll('_buildTimelineNode(int index', '_buildTimelineNode(BuildContext context, int index');
        content = content.replaceAll('_buildTimelineNode(i,', '_buildTimelineNode(context, i,');
        modified = true;
      }
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Fixed \${file.path}');
    }
  }
}
