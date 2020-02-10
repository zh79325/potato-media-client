import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';

class StreamMessage {
  MediaStreamHead head;
  Uint8List bytes;

  Uint8List encode() {
    Uint8List headBytes = head.encode();
    if (bytes != null) {
      return MessageUtil.wrap(Uint8List.fromList(headBytes + bytes));
    }
    return MessageUtil.wrap(headBytes);
  }

  void decode(Uint8List buf) {
    var data = buf.buffer.asByteData();
    var headLength = data.getInt32(0);
    var headBytes = buf.sublist(4, headLength + 4);
    head = new MediaStreamHead();
    head.decode(headBytes);
    bytes = buf.sublist(headLength + 4);
  }
}

class MediaStreamHead {
  MediaStreamType type;
  String mid;
  String parentId;

  Uint8List encode() {
    var name = getName(type);
    var body = MessageUtil.encodeString(name) +
        MessageUtil.encodeString(mid) +
        MessageUtil.encodeString(parentId);
    return MessageUtil.wrap(Uint8List.fromList(body));
  }

  void decode(Uint8List headBytes) {
    StringDecodeResult typeName = MessageUtil.decodeString(headBytes);
    this.type = getByName(typeName.value);
    headBytes = headBytes.sublist(typeName.offset);
    StringDecodeResult midResult = MessageUtil.decodeString(headBytes);
    this.mid = midResult.value;
    headBytes = headBytes.sublist(midResult.offset);
    StringDecodeResult pidResult = MessageUtil.decodeString(headBytes);
    this.parentId = pidResult.value;
  }

  MediaStreamType getByName(String value) {
    for (var v in MediaStreamType.values) {
      if (v.toString().split('.')[1] == value) {
        return v;
      }
    }
    return null;
  }
  String getName(MediaStreamType type){
    return type.toString().split('.')[1];
  }

  void build() {
    mid = currentTimeMillis().toString() + randomString(10);
  }

  static int currentTimeMillis() {
    return new DateTime.now().millisecondsSinceEpoch;
  }

  static String randomString(int strlenght) {
    String alphabet =
        '0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';

    /// 生成的字符串固定长度
    String left = '';
    for (var i = 0; i < strlenght; i++) {
      left = left + alphabet[Random().nextInt(alphabet.length)];
    }
    return left;
  }
}

enum MediaStreamType {
  Auth,
  AuthResp,
  Subscribe,
  Unsubscribe,
  Reset,
  Binary,
  Message,
  Ping,
  Pong

}

class StringDecodeResult {
  String value;
  int offset;
}

class MessageUtil {
  static Uint8List encodeString(String value) {
    var l = ByteData(4);
    if (value == null || value == "") {
      l.setInt32(0, 0);
      return l.buffer.asUint8List();
    }
    List<int> encoded = utf8.encode(value);
    l.setInt32(0, encoded.length);
    var result = l.buffer.asUint8List() + Uint8List.fromList(encoded);
    return Uint8List.fromList(result);
  }

  static Uint8List wrap(Uint8List body) {
    var l = ByteData(4);
    l.setInt32(0, body.lengthInBytes);
    return Uint8List.fromList(l.buffer.asUint8List() + body);
  }

  static StringDecodeResult decodeString(Uint8List buf) {
    var data = buf.buffer.asByteData();
    var length = data.getInt32(0);
    StringDecodeResult result = new StringDecodeResult();
    if(length==0){
      result.offset=4;
      result.value=null;
      return result;
    }
    var dataBytes = buf.sublist(4, length + 4);


    result.offset = length + 4;
    result.value = utf8.decode(dataBytes);
    return result;
  }
}
