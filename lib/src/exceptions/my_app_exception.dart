class MyAppException implements Exception {
  final String? message;

  const MyAppException({ this.message});

  @override
  String toString() => "MyAppException: $message";
}
