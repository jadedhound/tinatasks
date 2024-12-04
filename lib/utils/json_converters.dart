import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

class JsonColorConverter implements JsonConverter<Color, String> {
  const JsonColorConverter();

  @override
  Color fromJson(String json) => Color(int.parse(json, radix: 16) + 0xFF000000);

  @override
  String toJson(Color color) =>
      color.value.toRadixString(16).padLeft(8, '0').substring(2);
}
