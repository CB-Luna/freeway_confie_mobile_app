import 'package:json_annotation/json_annotation.dart';

part 'home_policy_request.g.dart';

@JsonSerializable()
class HomePolicyRequest {
  @JsonKey(name: 'customer_id')
  final int customerId;

  HomePolicyRequest({required this.customerId});

  factory HomePolicyRequest.fromJson(Map<String, dynamic> json) =>
      _$HomePolicyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HomePolicyRequestToJson(this);
}
