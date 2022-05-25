// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigAdapter extends TypeAdapter<Config> {
  @override
  final int typeId = 0;

  @override
  Config read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Config(
      ApiURL: fields[0] as String,
      DefaultImageURL: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Config obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.ApiURL)
      ..writeByte(1)
      ..write(obj.DefaultImageURL);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
