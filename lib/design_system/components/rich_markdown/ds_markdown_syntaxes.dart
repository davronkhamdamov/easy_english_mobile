import 'package:markdown/markdown.dart' as md;

/// Syntax for highlighted text `==highlighted text==`.
class DSHighlightSyntax extends md.InlineSyntax {
  DSHighlightSyntax() : super(r'==([^=]+)==');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1);
    if (text == null || text.isEmpty) return false;
    final element = md.Element('mark', [md.Text(text)]);
    parser.addNode(element);
    return true;
  }
}

/// Syntax for `<mark>highlighted text</mark>`.
class DSMarkTagSyntax extends md.InlineSyntax {
  DSMarkTagSyntax() : super(r'<mark>(.*?)</mark>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1);
    if (text == null || text.isEmpty) return false;
    final element = md.Element('mark', [md.Text(text)]);
    parser.addNode(element);
    return true;
  }
}

/// Syntax for superscript `^superscript^`.
class DSSuperscriptSyntax extends md.InlineSyntax {
  DSSuperscriptSyntax() : super(r'\^([^^]+)\^');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1);
    if (text == null || text.isEmpty) return false;
    final element = md.Element('sup', [md.Text(text)]);
    parser.addNode(element);
    return true;
  }
}

/// Syntax for subscript `~subscript~` (single tilde).
class DSSubscriptSyntax extends md.InlineSyntax {
  DSSubscriptSyntax() : super(r'~([^~]+)~');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1);
    if (text == null || text.isEmpty) return false;
    final element = md.Element('sub', [md.Text(text)]);
    parser.addNode(element);
    return true;
  }
}

/// Syntax for custom badges `[badge:variant:text]`, e.g. `[badge:success:Passed]`.
class DSBadgeSyntax extends md.InlineSyntax {
  DSBadgeSyntax() : super(r'\[badge:([a-zA-Z0-9_-]+):([^\]]+)\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final variant = match.group(1) ?? 'primary';
    final label = match.group(2) ?? '';
    final element = md.Element('ds-badge', [md.Text(label)])
      ..attributes['variant'] = variant;
    parser.addNode(element);
    return true;
  }
}

/// Block syntax for GitHub Alert Callouts:
/// `> [!NOTE]`
/// `> Callout body...`
class DSAlertBlockSyntax extends md.BlockSyntax {
  static final RegExp _alertHeaderPattern = RegExp(
    r'^>\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION|INFO|SUCCESS|QUESTION)\]\s*(.*)$',
    caseSensitive: false,
  );

  @override
  RegExp get pattern => RegExp(r'^>\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION|INFO|SUCCESS|QUESTION)\]', caseSensitive: false);

  @override
  bool canParse(md.BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }

  @override
  md.Node? parse(md.BlockParser parser) {
    final match = _alertHeaderPattern.firstMatch(parser.current.content);
    if (match == null) return null;

    final alertType = (match.group(1) ?? 'NOTE').toLowerCase();
    final inlineTitle = match.group(2)?.trim();

    parser.advance();

    final childLines = <String>[];
    while (!parser.isDone) {
      final current = parser.current.content;
      if (current.startsWith('>')) {
        // Strip leading '>' and optional space
        var content = current.substring(1);
        if (content.startsWith(' ')) {
          content = content.substring(1);
        }
        childLines.add(content);
        parser.advance();
      } else if (current.trim().isEmpty) {
        // Empty line inside or ending blockquote
        childLines.add('');
        parser.advance();
        if (parser.isDone || !parser.current.content.startsWith('>')) {
          break;
        }
      } else {
        break;
      }
    }

    final element = md.Element('alert-callout', [
      md.Text(childLines.join('\n')),
    ])
      ..attributes['type'] = alertType;

    if (inlineTitle != null && inlineTitle.isNotEmpty) {
      element.attributes['custom_title'] = inlineTitle;
    }

    return element;
  }
}
