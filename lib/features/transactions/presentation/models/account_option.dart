class AccountOption {
  final String type;
  final int id;
  final String name;
  final double balance;

  const AccountOption({
    required this.type,
    required this.id,
    required this.name,
    required this.balance,
  });

  String get key => '$type:$id';

  bool get isCash => type == 'cash';

  bool get isBank => type == 'bank';
}
