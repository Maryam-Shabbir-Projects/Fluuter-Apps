enum QrKind { website, text, wifi, contact, email, phone }

extension QrKindX on QrKind {
  String get label => const {
        QrKind.website: 'Website',
        QrKind.text: 'Text',
        QrKind.wifi: 'Wi-Fi',
        QrKind.contact: 'Contact',
        QrKind.email: 'Email',
        QrKind.phone: 'Phone',
      }[this]!;

  String get hint => const {
        QrKind.website: 'Any link',
        QrKind.text: 'Plain message',
        QrKind.wifi: 'Share your network',
        QrKind.contact: 'Name, phone, email',
        QrKind.email: 'Pre-filled message',
        QrKind.phone: 'Tap to call',
      }[this]!;
}

/// What a scanned or created code contains, in a friendly form.
class ParsedQr {
  final QrKind kind;
  final String raw;
  final String title;
  final Map<String, String> fields;
  const ParsedQr(this.kind, this.raw, this.title, [this.fields = const {}]);
}

ParsedQr parseQr(String input) {
  final raw = input.trim();
  final lower = raw.toLowerCase();

  if (lower.startsWith('wifi:')) {
    final f = _parseWifi(raw.substring(5));
    return ParsedQr(QrKind.wifi, raw, f['S'] ?? 'Wi-Fi network', f);
  }
  if (lower.startsWith('begin:vcard')) {
    final f = <String, String>{};
    for (final line in raw.split(RegExp(r'\r?\n'))) {
      final i = line.indexOf(':');
      if (i < 0) continue;
      final key = line.substring(0, i).split(';').first.toUpperCase();
      if (const ['FN', 'TEL', 'EMAIL'].contains(key)) {
        f.putIfAbsent(key, () => line.substring(i + 1).trim());
      }
    }
    return ParsedQr(QrKind.contact, raw, f['FN'] ?? 'Contact', f);
  }
  if (lower.startsWith('mailto:')) {
    final uri = Uri.tryParse(raw);
    final to = uri?.path ?? raw.substring(7);
    return ParsedQr(QrKind.email, raw, to, {
      'To': to,
      if (uri?.queryParameters['subject'] != null) 'Subject': uri!.queryParameters['subject']!,
      if (uri?.queryParameters['body'] != null) 'Message': uri!.queryParameters['body']!,
    });
  }
  if (lower.startsWith('tel:')) {
    return ParsedQr(QrKind.phone, raw, raw.substring(4), {'Number': raw.substring(4)});
  }
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    final host = Uri.tryParse(raw)?.host ?? '';
    return ParsedQr(QrKind.website, raw, host.isEmpty ? raw : host);
  }
  final first = raw.split('\n').first;
  return ParsedQr(QrKind.text, raw, first.length > 40 ? '${first.substring(0, 40)}...' : first);
}

Map<String, String> _parseWifi(String body) {
  final out = <String, String>{};
  var key = StringBuffer();
  var val = StringBuffer();
  var inKey = true;
  var esc = false;
  for (final ch in body.split('')) {
    if (esc) {
      (inKey ? key : val).write(ch);
      esc = false;
    } else if (ch == r'\') {
      esc = true;
    } else if (inKey && ch == ':') {
      inKey = false;
    } else if (ch == ';') {
      if (!inKey) out[key.toString().toUpperCase()] = val.toString();
      key = StringBuffer();
      val = StringBuffer();
      inKey = true;
    } else {
      (inKey ? key : val).write(ch);
    }
  }
  return out;
}

// ---- Payload builders (everything is built on the phone) ----

String normaliseUrl(String s) {
  final t = s.trim();
  return RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(t) ? t : 'https://$t';
}

String _esc(String s) => s.replaceAllMapped(RegExp(r'([\\;,:"])'), (m) => '\\${m[1]}');

String buildWifi(String ssid, String password, String security) {
  final pw = security == 'nopass' ? '' : _esc(password);
  return 'WIFI:T:$security;S:${_esc(ssid)};P:$pw;;';
}

String buildVcard({required String first, String last = '', String phone = '', String email = ''}) {
  return [
    'BEGIN:VCARD',
    'VERSION:3.0',
    'N:$last;$first;;;',
    'FN:${('$first $last').trim()}',
    if (phone.isNotEmpty) 'TEL:$phone',
    if (email.isNotEmpty) 'EMAIL:$email',
    'END:VCARD',
  ].join('\n');
}

String buildEmail(String to, String subject, String body) {
  final q = [
    if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
    if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
  ].join('&');
  return 'mailto:$to${q.isEmpty ? '' : '?$q'}';
}

// ---- History ----

class HistoryItem {
  final String id;
  final String raw;
  final bool created; // false = scanned
  final int time; // millisecondsSinceEpoch
  const HistoryItem(this.id, this.raw, this.created, this.time);

  Map<String, dynamic> toJson() => {'id': id, 'raw': raw, 'created': created, 'time': time};
  factory HistoryItem.fromJson(Map<String, dynamic> j) =>
      HistoryItem(j['id'] as String, j['raw'] as String, j['created'] as bool, j['time'] as int);
}
