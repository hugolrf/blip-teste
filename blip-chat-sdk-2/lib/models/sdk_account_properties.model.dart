class SdkAccountProperties {
  String? pushToken;
  String? fullName;
  String? email;
  Uri? photoUri;
  bool? encryptMessageContent;

  SdkAccountProperties({
    this.pushToken,
    this.fullName,
    this.email,
    this.photoUri,
    this.encryptMessageContent,
  });

  SdkAccountProperties.fromJson(Map<String, dynamic> json)
      : pushToken = json['pushToken'],
        fullName = json['fullName'],
        email = json['email'],
        photoUri = (json['photoUri']?.isNotEmpty ?? false)
            ? Uri.tryParse(json['photoUri']!)
            : null,
        encryptMessageContent = json['encryptMessageContent'];
}
