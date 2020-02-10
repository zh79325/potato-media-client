import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';

class StreamMessage {
  MediaStreamHead head;
  Int8List bytes;

  Int8List encode() {
    Int8List headBytes = head.encode();
    var msg = headBytes;
    if (bytes != null) {
      msg += bytes;
    }
    return MessageUtil.wrap(msg);
  }

  void decode(Int8List buf) {
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

  Int8List encode() {
    var name = type.toString();
    var body = MessageUtil.encodeString(name);
    body += MessageUtil.encodeString(mid);
    body += MessageUtil.encodeString(parentId);
    return MessageUtil.wrap(body);
  }

  void decode(Int8List headBytes) {
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
      if (v.toString() == value) {
        return v;
      }
    }
    return null;
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
  static Int8List encodeString(String value) {
    var l = ByteData(4);
    if (value == null || value == "") {
      l.setInt32(0, 0);
      return l.buffer.asInt8List();
    }
    List<int> encoded = utf8.encode(value);
    l.setInt32(0, encoded.length);
    var result = l.buffer.asInt8List() + encoded;
    return result;
  }

  static Int8List wrap(Int8List body) {
    var l = ByteData(4);
    l.setInt32(0, body.lengthInBytes);
    return l.buffer.asInt8List() + body;
  }

  static StringDecodeResult decodeString(Int8List buf) {
    var data = buf.buffer.asByteData();
    var length = data.getInt32(0);
    var dataBytes = buf.sublist(4, length + 4);

    StringDecodeResult result = new StringDecodeResult();
    result.offset = length + 4;
    result.value = utf8.decode(dataBytes);
    return result;
  }
}
