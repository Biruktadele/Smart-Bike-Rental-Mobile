import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smbk/features/bikes/presentation/bike_providers.dart';

void main() async {
  final container = ProviderContainer();
  try {
    final bikes = await container.read(bikesProvider.future);
    print('Bikes loaded: \${bikes.length}');
  } catch (e, stack) {
    print('Error: \$e');
    print(stack);
  }
}
