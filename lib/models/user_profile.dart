import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  @JsonKey(ignore: true)
  String id;
  String firstName;
  String birthDay;

  UserProfile({
    @required this.id,
    @required this.firstName,
    @required this.birthDay,
  });

  //gender
  //sexual orientation
  //interested men/women/all

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  factory UserProfile.fromFirestore(DocumentSnapshot documentSnapshot) {
    if (!documentSnapshot.exists) return null;
    final json = documentSnapshot.data();
    UserProfile model = UserProfile.fromJson({
      "id": documentSnapshot.id,
      ...json,
    });
    return model;
  }
}
