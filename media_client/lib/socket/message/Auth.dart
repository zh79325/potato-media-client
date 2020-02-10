import 'package:json_annotation/json_annotation.dart';

part 'Auth.g.dart';

@JsonSerializable()
class AuthMessage{
  String uid;
  String token;

  AuthMessage({this.uid, this.token});

  factory AuthMessage.fromJson(Map<String, dynamic> json) => _$AuthMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AuthMessageToJson(this);
}
@JsonSerializable()
class AuthResult{
  bool success;

  AuthResult({this.success});

  factory AuthResult.fromJson(Map<String, dynamic> json) => _$AuthResultFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResultToJson(this);

}