//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PluginMethodResponseDto {
  /// Returns a new [PluginMethodResponseDto] instance.
  PluginMethodResponseDto({
    required this.description,
    required this.key,
    required this.name,
    required this.schema,
    required this.title,
    this.types = const [],
  });

  /// Description
  String description;

  /// Key
  String key;

  /// Name
  String name;

  /// Schema
  Object? schema;

  /// Title
  String title;

  /// Workflow types
  List<WorkflowType> types;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PluginMethodResponseDto &&
    other.description == description &&
    other.key == key &&
    other.name == name &&
    other.schema == schema &&
    other.title == title &&
    _deepEquality.equals(other.types, types);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (description.hashCode) +
    (key.hashCode) +
    (name.hashCode) +
    (schema == null ? 0 : schema!.hashCode) +
    (title.hashCode) +
    (types.hashCode);

  @override
  String toString() => 'PluginMethodResponseDto[description=$description, key=$key, name=$name, schema=$schema, title=$title, types=$types]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'description'] = this.description;
      json[r'key'] = this.key;
      json[r'name'] = this.name;
    if (this.schema != null) {
      json[r'schema'] = this.schema;
    } else {
    //  json[r'schema'] = null;
    }
      json[r'title'] = this.title;
      json[r'types'] = this.types;
    return json;
  }

  /// Returns a new [PluginMethodResponseDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PluginMethodResponseDto? fromJson(dynamic value) {
    upgradeDto(value, "PluginMethodResponseDto");
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return PluginMethodResponseDto(
        description: mapValueOfType<String>(json, r'description')!,
        key: mapValueOfType<String>(json, r'key')!,
        name: mapValueOfType<String>(json, r'name')!,
        schema: mapValueOfType<Object>(json, r'schema'),
        title: mapValueOfType<String>(json, r'title')!,
        types: WorkflowType.listFromJson(json[r'types']),
      );
    }
    return null;
  }

  static List<PluginMethodResponseDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PluginMethodResponseDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PluginMethodResponseDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PluginMethodResponseDto> mapFromJson(dynamic json) {
    final map = <String, PluginMethodResponseDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PluginMethodResponseDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PluginMethodResponseDto-objects as value to a dart map
  static Map<String, List<PluginMethodResponseDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PluginMethodResponseDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PluginMethodResponseDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'description',
    'key',
    'name',
    'schema',
    'title',
    'types',
  };
}

