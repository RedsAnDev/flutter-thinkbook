enum EnumPlatform { apple, android, undefined }

class enumProxy {
  static String readEnum(dynamic value) {
    try {
      return value.toString().split(".").last;
    } catch (e) {
      return EnumPlatform.undefined.toString().split(".").last;
    }
  }

  static dynamic getEnum(String value) {
    if (value == null) return EnumPlatform.undefined;
    switch (value.toLowerCase().trim()) {
      case "apple":
        return EnumPlatform.apple;
      case "android":
        return EnumPlatform.android;
      default:
        return EnumPlatform.undefined;
    }
  }
}
