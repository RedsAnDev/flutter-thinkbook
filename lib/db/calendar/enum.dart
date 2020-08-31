enum EnumPlatform { apple, android, undefined }

class enumProxy {
  static String readEnum(dynamic value) {
    return value.toString().split(".").last;
  }

  static dynamic getEnum(String value) {
    switch (value.toLowerCase().trim()) {
      default:
        return null;
    }
  }
}
