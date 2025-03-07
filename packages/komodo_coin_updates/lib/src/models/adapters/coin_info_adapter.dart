part of '../coin_info.dart';

class CoinInfoAdapter extends TypeAdapter<CoinInfo> {
  @override
  final int typeId = 13;

  @override
  CoinInfo read(BinaryReader reader) {
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinInfo(
      coin: fields[0] as Coin,
      coinConfig: fields[1] as CoinConfig?,
    );
  }

  @override
  void write(BinaryWriter writer, CoinInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.coin)
      ..writeByte(1)
      ..write(obj.coinConfig);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
