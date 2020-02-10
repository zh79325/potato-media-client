import 'dart:io';
import 'dart:async';

import 'dart:typed_data';

import 'message/StreamMessage.dart';

class SocketManage {
  static String host='localhost';
  static int  port=8018;
  static Socket socket;
  static  Stream<List<int>> mStream;

  static Int8List cacheData = Int8List(0);

  static initSocket() async{
    try {
      socket = await Socket.connect(host, port, timeout: Duration(seconds: 2));
      socket.listen(decodeHandle,
          onError: errorHandler,
          onDone: doneHandler,
          cancelOnError: false);
    } catch (e) {
      print("连接socket出现异常，e=${e.toString()}");
    }



  }

  static void sendMessage(StreamMessage message){
    Int8List buf=message.encode();
    String msgCode=message.head.type.toString();
    try {
      socket.add(buf);
      print("给服务端发送消息，消息号=$msgCode");
    } catch (e) {
      print("send捕获异常：msgCode=${msgCode}，e=${e.toString()}");
    }
  }

  static void decodeHandle(newData){
    //拼凑当前最新未处理的网络数据
    cacheData = Int8List.fromList(cacheData + newData);
    var msgLen=0;
    var buf=cacheData.buffer.asByteData();
    while(msgLen<buf.lengthInBytes)
      msgLen=buf.getInt32(0);
      if(msgLen>buf.lengthInBytes-4){
        return;
      }
      var byteBody = cacheData.sublist(4, msgLen +4);
      cacheData=cacheData.sublist(msgLen+4);
      //处理消息
      handler(byteBody);
    }

  static void handler(Int8List body) {
    print(body);
    StreamMessage message=new StreamMessage();
    message.decode(body);
    print(message);
  }




  static void doneHandler() {
    print('done');
  }

  static errorHandler(e) {
    print('error');
  }
}
