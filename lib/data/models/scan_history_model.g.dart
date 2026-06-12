// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanHistoryModelAdapter extends TypeAdapter<ScanHistoryModel> {
  @override
  final int typeId = 1;

  @override
  ScanHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistoryModel(
      product: fields[0] as ProductModel,
      scanDate: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistoryModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.product)
      ..writeByte(1)
      ..write(obj.scanDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
