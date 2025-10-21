// filename: model/parcel.dart
import 'package:hive/hive.dart';

part 'parcel.g.dart';

@HiveType(typeId: 1)
class Parcel extends HiveObject {
  @HiveField(0)
  String trackingNumber;

  @HiveField(1)
  String sender;

  @HiveField(2)
  String recipient;

  @HiveField(3)
  String status;

  @HiveField(4)
  List<TrackingEvent> history;

  Parcel({
    required this.trackingNumber,
    required this.sender,
    required this.recipient,
    required this.status,
    required this.history,
  });
}

@HiveType(typeId: 2)
class TrackingEvent extends HiveObject {
  @HiveField(0)
  String location;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime timestamp;

  TrackingEvent({
    required this.location,
    required this.description,
    required this.timestamp,
  });
}
