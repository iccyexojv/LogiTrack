// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParcelAdapter extends TypeAdapter<Parcel> {
  @override
  final int typeId = 1;

  @override
  Parcel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Parcel(
      trackingNumber: fields[0] as String,
      sender: fields[1] as String,
      recipient: fields[2] as String,
      status: fields[3] as String,
      history: (fields[4] as List).cast<TrackingEvent>(),
    );
  }

  @override
  void write(BinaryWriter writer, Parcel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.trackingNumber)
      ..writeByte(1)
      ..write(obj.sender)
      ..writeByte(2)
      ..write(obj.recipient)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.history);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParcelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrackingEventAdapter extends TypeAdapter<TrackingEvent> {
  @override
  final int typeId = 2;

  @override
  TrackingEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackingEvent(
      location: fields[0] as String,
      description: fields[1] as String,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingEvent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.location)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
