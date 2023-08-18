class Setting2 {
  Setting2({
    this.invocationInfo,
    this.result,
  });

  Setting2.fromJson(dynamic json) {
    invocationInfo = json['invocationInfo'] != null ? InvocationInfo.fromJson(json['invocationInfo']) : null;
    if (json['result'] != null) {
      result = [];
      json['result'].forEach((v) {
        result?.add(Result.fromJson(v));
      });
    }
  }

  InvocationInfo? invocationInfo;
  List<Result>? result;

  Setting2 copyWith({
    InvocationInfo? invocationInfo,
    List<Result>? result,
  }) =>
      Setting2(
        invocationInfo: invocationInfo ?? this.invocationInfo,
        result: result ?? this.result,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (invocationInfo != null) {
      map['invocationInfo'] = invocationInfo?.toJson();
    }
    if (result != null) {
      map['result'] = result?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Result {
  Result({
    this.settings2,
    this.rupTitle,
    this.rupDescription,
  });

  Result.fromJson(dynamic json) {
    settings2 = json['settings2'] != null ? Settings2.fromJson(json['settings2']) : null;
    rupTitle = json['rupTitle'];
    rupDescription = json['rupDescription'];
  }

  Settings2? settings2;
  String? rupTitle;
  String? rupDescription;

  Result copyWith({
    Settings2? settings2,
    String? rupTitle,
    String? rupDescription,
  }) =>
      Result(
        settings2: settings2 ?? this.settings2,
        rupTitle: rupTitle ?? this.rupTitle,
        rupDescription: rupDescription ?? this.rupDescription,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (settings2 != null) {
      map['settings2'] = settings2?.toJson();
    }
    map['rupTitle'] = rupTitle;
    map['rupDescription'] = rupDescription;
    return map;
  }
}

class Settings2 {
  Settings2({
    this.language,
    this.moodEnergy,
    this.diversity,
  });

  Settings2.fromJson(dynamic json) {
    language = json['language'];
    moodEnergy = json['moodEnergy'];
    diversity = json['diversity'];
  }

  String? language;
  String? moodEnergy;
  String? diversity;

  Settings2 copyWith({
    String? language,
    String? moodEnergy,
    String? diversity,
  }) =>
      Settings2(
        language: language ?? this.language,
        moodEnergy: moodEnergy ?? this.moodEnergy,
        diversity: diversity ?? this.diversity,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['language'] = language;
    map['moodEnergy'] = moodEnergy;
    map['diversity'] = diversity;
    return map;
  }
}

class InvocationInfo {
  InvocationInfo({
    this.hostname,
    this.reqid,
    this.execdurationmillis,
  });

  InvocationInfo.fromJson(dynamic json) {
    hostname = json['hostname'];
    reqid = json['req-id'];
    execdurationmillis = json['exec-duration-millis'];
  }

  String? hostname;
  String? reqid;
  String? execdurationmillis;

  InvocationInfo copyWith({
    String? hostname,
    String? reqid,
    String? execdurationmillis,
  }) =>
      InvocationInfo(
        hostname: hostname ?? this.hostname,
        reqid: reqid ?? this.reqid,
        execdurationmillis: execdurationmillis ?? this.execdurationmillis,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hostname'] = hostname;
    map['req-id'] = reqid;
    map['exec-duration-millis'] = execdurationmillis;
    return map;
  }
}
