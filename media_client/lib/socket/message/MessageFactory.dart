import 'dart:convert';
import 'dart:typed_data';

import 'StreamMessage.dart';

class MessageFactory {
  static StreamMessage create<T>(MediaStreamType type, T data) {
    StreamMessage message = new StreamMessage();
    MediaStreamHead head = new MediaStreamHead();
    head.type=type;
    head.build();
    message.head=head;
    if (type == MediaStreamType.Binary) {
      message.bytes=data as Uint8List;
    } else if (data != null) {
      String jsonValue = json.encode(data);
      List<int> bytes = utf8.encode(jsonValue);
      message.bytes=Uint8List.fromList(bytes);
    }
    return message;
  }
}
