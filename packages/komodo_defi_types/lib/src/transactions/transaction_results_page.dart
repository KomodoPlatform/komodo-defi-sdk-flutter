import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class TransactionPage extends Equatable {
  const TransactionPage({
    required this.transactions,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    this.nextPageId,
  });

  final List<Transaction> transactions;
  final int total;
  final String? nextPageId;
  final int currentPage;
  final int totalPages;

  @override
  List<Object?> get props => [
        transactions,
        total,
        nextPageId,
        currentPage,
        totalPages,
      ];
}
