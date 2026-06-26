class GameSettings {
  const GameSettings({
    this.localeCode = 'en',
    this.musicVolume = 0.8,
    this.sfxVolume = 1.0,
    this.joystickSensitivity = 1.0,
    this.vibrationEnabled = true,
  });

  final String localeCode;
  final double musicVolume;
  final double sfxVolume;
  final double joystickSensitivity;
  final bool vibrationEnabled;

  GameSettings copyWith({
    String? localeCode,
    double? musicVolume,
    double? sfxVolume,
    double? joystickSensitivity,
    bool? vibrationEnabled,
  }) {
    return GameSettings(
      localeCode: localeCode ?? this.localeCode,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      joystickSensitivity: joystickSensitivity ?? this.joystickSensitivity,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'localeCode': localeCode,
        'musicVolume': musicVolume,
        'sfxVolume': sfxVolume,
        'joystickSensitivity': joystickSensitivity,
        'vibrationEnabled': vibrationEnabled,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      localeCode: json['localeCode'] as String? ?? 'en',
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.8,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 1.0,
      joystickSensitivity:
          (json['joystickSensitivity'] as num?)?.toDouble() ?? 1.0,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }
}
