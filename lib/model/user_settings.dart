class UserSettings {
  double fontSize;
  bool darkMode;

  UserSettings({
    this.fontSize = 16.0,
    this.darkMode = true,
  });

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'darkMode': darkMode,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
        darkMode: json['darkMode'] as bool? ?? true,
      );

  UserSettings copyWith({
    double? fontSize,
    bool? darkMode,
  }) {
    return UserSettings(
      fontSize: fontSize ?? this.fontSize,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
