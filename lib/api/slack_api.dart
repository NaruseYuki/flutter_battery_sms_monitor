import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'slack_api.g.dart';

@JsonSerializable()
class SlackMessage {
  final String text;
  
  SlackMessage({required this.text});
  
  factory SlackMessage.fromJson(Map<String, dynamic> json) => 
      _$SlackMessageFromJson(json);
  
  Map<String, dynamic> toJson() => _$SlackMessageToJson(this);
}

@RestApi()
abstract class SlackApi {
  factory SlackApi(Dio dio, {String baseUrl}) = _SlackApi;

  @POST('')
  Future<void> postMessage(@Body() SlackMessage message);
}
