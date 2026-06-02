import 'package:http/http.dart' as http;

void main() async {
  final res = await http.get(
    Uri.parse('https://smart-bike-rental-backend.onrender.com/api/bikes'),
  );
  print(res.statusCode);
  if (res.statusCode >= 400) print(res.body);
}
