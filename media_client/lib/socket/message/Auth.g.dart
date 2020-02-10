// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthMessage _$AuthMessageFromJson(Map<String, dynamic> json) {
  return AuthMessage(
    uid: json['uid'] as String,
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$AuthMessageToJson(AuthMessage instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'token': instance.token,
    };

AuthResult _$AuthResultFromJson(Map<String, dynamic> json) {
  return AuthResult(
    success: json['success'] as bool,
  );
}

Map<String, dynamic> _$AuthResultToJson(AuthResult instance) =>
    <String, dynamic>{
      'success': instance.success,
    };
