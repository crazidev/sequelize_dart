import 'dart:convert';
import 'dart:typed_data';

import 'package:sequelize_orm/src/utils/parse_helpers.dart';

/// Ultra-fast, zero-dependency MessagePack decoder for Dart.
/// Decodes binary MessagePack payloads (Uint8List) directly into Dart objects.
class FastMsgPackDecoder {
  final Uint8List _bytes;
  final ByteData _bd;
  int _offset = 0;

  FastMsgPackDecoder(this._bytes) : _bd = ByteData.sublistView(_bytes);

  static dynamic decode(Uint8List bytes) {
    if (bytes.isEmpty) return null;
    final decoder = FastMsgPackDecoder(bytes);
    final val = decoder._readNext();
    return unpackTabularResult(val);
  }

  dynamic _readNext() {
    if (_offset >= _bytes.length) return null;
    final b = _bytes[_offset++];

    // Positive FixInt (0x00 - 0x7f)
    if (b <= 0x7f) return b;

    // FixMap (0x80 - 0x8f)
    if (b >= 0x80 && b <= 0x8f) {
      final len = b & 0x0f;
      return _readMap(len);
    }

    // FixArray (0x90 - 0x9f)
    if (b >= 0x90 && b <= 0x9f) {
      final len = b & 0x0f;
      return _readArray(len);
    }

    // FixStr (0xa0 - 0xbf)
    if (b >= 0xa0 && b <= 0xbf) {
      final len = b & 0x1f;
      return _readString(len);
    }

    // Nil / Null
    if (b == 0xc0) return null;

    // Booleans
    if (b == 0xc2) return false;
    if (b == 0xc3) return true;

    // Bin 8, 16, 32
    if (b == 0xc4) {
      final len = _bytes[_offset++];
      return _readBin(len);
    }
    if (b == 0xc5) {
      final len = _bd.getUint16(_offset);
      _offset += 2;
      return _readBin(len);
    }
    if (b == 0xc6) {
      final len = _bd.getUint32(_offset);
      _offset += 4;
      return _readBin(len);
    }

    // Ext 8, 16, 32
    if (b == 0xc7) {
      final len = _bytes[_offset++];
      final type = _bd.getInt8(_offset++);
      return _readExt(type, len);
    }
    if (b == 0xc8) {
      final len = _bd.getUint16(_offset);
      _offset += 2;
      final type = _bd.getInt8(_offset++);
      return _readExt(type, len);
    }
    if (b == 0xc9) {
      final len = _bd.getUint32(_offset);
      _offset += 4;
      final type = _bd.getInt8(_offset++);
      return _readExt(type, len);
    }

    // Float 32 / Float 64
    if (b == 0xca) {
      final v = _bd.getFloat32(_offset);
      _offset += 4;
      return v;
    }
    if (b == 0xcb) {
      final v = _bd.getFloat64(_offset);
      _offset += 8;
      return v;
    }

    // Uint 8, 16, 32, 64
    if (b == 0xcc) return _bytes[_offset++];
    if (b == 0xcd) {
      final v = _bd.getUint16(_offset);
      _offset += 2;
      return v;
    }
    if (b == 0xce) {
      final v = _bd.getUint32(_offset);
      _offset += 4;
      return v;
    }
    if (b == 0xcf) {
      final v = _bd.getUint64(_offset);
      _offset += 8;
      return v;
    }

    // Int 8, 16, 32, 64
    if (b == 0xd0) return _bd.getInt8(_offset++);
    if (b == 0xd1) {
      final v = _bd.getInt16(_offset);
      _offset += 2;
      return v;
    }
    if (b == 0xd2) {
      final v = _bd.getInt32(_offset);
      _offset += 4;
      return v;
    }
    if (b == 0xd3) {
      final v = _bd.getInt64(_offset);
      _offset += 8;
      return v;
    }

    // FixExt 1, 2, 4, 8, 16
    if (b == 0xd4) {
      final type = _bd.getInt8(_offset++);
      return _readExt(type, 1);
    }
    if (b == 0xd5) {
      final type = _bd.getInt8(_offset++);
      return _readExt(type, 2);
    }
    if (b == 0xd6) {
      final type = _bd.getInt8(_offset++);
      return _readExt(type, 4);
    }
    if (b == 0xd7) {
      final type = _bd.getInt8(_offset++);
      return _readExt(type, 8);
    }
    if (b == 0xd8) {
      final type = _bd.getInt8(_offset++);
      return _readExt(type, 16);
    }

    // Str 8, 16, 32
    if (b == 0xd9) {
      final len = _bytes[_offset++];
      return _readString(len);
    }
    if (b == 0xda) {
      final len = _bd.getUint16(_offset);
      _offset += 2;
      return _readString(len);
    }
    if (b == 0xdb) {
      final len = _bd.getUint32(_offset);
      _offset += 4;
      return _readString(len);
    }

    // Array 16, 32
    if (b == 0xdc) {
      final len = _bd.getUint16(_offset);
      _offset += 2;
      return _readArray(len);
    }
    if (b == 0xdd) {
      final len = _bd.getUint32(_offset);
      _offset += 4;
      return _readArray(len);
    }

    // Map 16, 32
    if (b == 0xde) {
      final len = _bd.getUint16(_offset);
      _offset += 2;
      return _readMap(len);
    }
    if (b == 0xdf) {
      final len = _bd.getUint32(_offset);
      _offset += 4;
      return _readMap(len);
    }

    // Negative FixInt (0xe0 - 0xff)
    if (b >= 0xe0) return b - 256;

    throw FormatException(
      'Unknown MessagePack byte header: 0x${b.toRadixString(16)}',
    );
  }

  Map<String, dynamic> _readMap(int len) {
    final map = <String, dynamic>{};
    for (var i = 0; i < len; i++) {
      final key = _readNext();
      final val = _readNext();
      if (key != null) map[key.toString()] = val;
    }
    return map;
  }

  List<dynamic> _readArray(int len) {
    final list = List<dynamic>.filled(len, null, growable: false);
    for (var i = 0; i < len; i++) {
      list[i] = _readNext();
    }
    return list;
  }

  Uint8List _readBin(int len) {
    final slice = Uint8List.sublistView(_bytes, _offset, _offset + len);
    _offset += len;
    return slice;
  }

  String _readString(int len) {
    if (len == 0) return '';
    final str = utf8.decode(
      Uint8List.sublistView(_bytes, _offset, _offset + len),
    );
    _offset += len;
    return str;
  }

  dynamic _readExt(int type, int len) {
    if (type == -1) {
      // Timestamp extension (-1) in MessagePack spec
      if (len == 4) {
        final sec = _bd.getUint32(_offset);
        _offset += 4;
        return DateTime.fromMillisecondsSinceEpoch(
          sec * 1000,
          isUtc: true,
        ).toIso8601String();
      } else if (len == 8) {
        final data64 = _bd.getUint64(_offset);
        _offset += 8;
        final nsec = (data64 >> 34) & 0x3fffffff;
        final sec = data64 & 0x00000003ffffffff;
        return DateTime.fromMillisecondsSinceEpoch(
          sec * 1000 + (nsec ~/ 1000000),
          isUtc: true,
        ).toIso8601String();
      } else if (len == 12) {
        final nsec = _bd.getUint32(_offset);
        _offset += 4;
        final sec = _bd.getInt64(_offset);
        _offset += 8;
        return DateTime.fromMillisecondsSinceEpoch(
          sec * 1000 + (nsec ~/ 1000000),
          isUtc: true,
        ).toIso8601String();
      }
    }
    final slice = Uint8List.sublistView(_bytes, _offset, _offset + len);
    _offset += len;
    return slice;
  }
}
