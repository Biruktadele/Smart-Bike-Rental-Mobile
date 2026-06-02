import 'dart:convert';

void main() {
  final jsonString = '{"data": [{"id": 1}]}';
  final decoded = jsonDecode(jsonString);
  final data = decoded['data'];
  if (data is List) {
    final list = data.whereType<Map<String, dynamic>>().toList();
    print('whereType length: ${list.length}');
  }
}
