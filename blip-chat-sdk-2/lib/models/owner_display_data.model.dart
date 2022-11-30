import '../enums/status.enum.dart';

class OwnerDisplayData {
  OwnerDisplayData({
    required this.name,
    this.photo,
    this.status = Status.offline,
  });

  String name;
  Uri? photo;
  Status status;
}
