import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme.dart';
import '../payment_providers.dart';
import 'add_card_screen.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(_balanceProvider);
    final methods = ref.watch(_methodsProvider);
    final transactions = ref.watch(_transactionsProvider);

    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text('Payment Methods',
                      style: VelocityText.headlineSmall()),
                ],
              ),
              const SizedBox(height: 16),
              balance.when(
                data: (wallet) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: VelocityColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wallet Balance',
                          style: VelocityText.bodySmall(
                              color: const Color(0xFFCDFFD3))),
                      const SizedBox(height: 8),
                      Text(
                        '${wallet.balance.toStringAsFixed(2)} ${wallet.currency}',
                        style: VelocityText.titleLarge(
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(e.toString()),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Saved Methods', style: VelocityText.titleLarge()),
                  TextButton(
                    onPressed: () async {
                      final added = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => const AddCardScreen(),
                        ),
                      );
                      if (added == true) {
                        ref.invalidate(_methodsProvider);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
              methods.when(
                data: (items) => Column(
                  children: items
                      .map((method) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: VelocityColors.surfacePale,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                method.brand == 'Visa' 
                                    ? Icons.credit_score_rounded 
                                    : Icons.credit_card_rounded,
                                color: VelocityColors.primary,
                              ),
                            ),
                            title: Text('${method.brand} Card', style: VelocityText.bodyLarge()),
                            subtitle: Text('•••• ${method.last4}  •  Exp ${method.expiryDate}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: VelocityColors.error),
                              onPressed: () async {
                                await ref
                                    .read(paymentRepositoryProvider)
                                    .removeMethod(method.id);
                                ref.invalidate(_methodsProvider);
                              },
                            ),
                          ))
                      .toList(),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(e.toString()),
              ),
              const SizedBox(height: 24),
              Text('Transactions', style: VelocityText.titleLarge()),
              const SizedBox(height: 8),
              Expanded(
                child: transactions.when(
                  data: (items) => ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (_, i) {
                      final tx = items[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(tx.title),
                        subtitle: Text(tx.date?.toLocal().toString() ?? '-'),
                        trailing: Text(
                          '${tx.amount.toStringAsFixed(2)} ETB',
                          style: VelocityText.bodyMedium(
                            color: VelocityColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



final _balanceProvider = FutureProvider((ref) {
  return ref.watch(paymentRepositoryProvider).fetchBalance();
});

final _methodsProvider = FutureProvider((ref) {
  return ref.watch(paymentRepositoryProvider).fetchMethods();
});

final _transactionsProvider = FutureProvider((ref) {
  return ref.watch(paymentRepositoryProvider).fetchTransactions();
});
