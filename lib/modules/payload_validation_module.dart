class PayloadWithValidationResponse {
  Map? payload;
  bool isValid = false;
  List<String> requiredKeys = [];

  PayloadWithValidationResponse({
    this.payload,
    this.isValid = false,
    this.requiredKeys = const <String>[],
  });
}
