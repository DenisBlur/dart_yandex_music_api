import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yam_api/radio/session.dart';
import 'package:yam_api/radio/setting2.dart';
import 'package:yam_api/track/track.dart';

import 'enums.dart';

class Radio {
  String baseUrl = "https://api.music.yandex.net";

  String batchId = "";
  String radioSessionId = "";

  Map<String, String> headers = {};
  String device = "";
  String currentStation = "user:onyourwave";

  List<Track> sequence = [];

  void init(Map<String, String> headers, String device) {
    this.headers = headers;
    this.device = device;
  }

  Future<List<Track>> startRotorRadio({String station = "user:onyourwave"}) async {
    currentStation = station;
    sequence = await getRotorTracks();
    return sequence;
  }

  Future<Setting2> getStationInfo() async {
    var stationInfo = await http.get(Uri.parse("$baseUrl/rotor/station/$currentStation/info"), headers: headers);
    return Setting2.fromJson(jsonDecode(stationInfo.body));
  }

  Future<void> sendRotorStationSetting(
      {required RadioDiversity radioDiversity, required RadioMoodEnergy radioMoodEnergy, required RadioLanguage radioLanguage}) async {
    String moodEnergy = radioMoodEnergy.name;
    String diversity = radioDiversity == RadioDiversity.defaultDiversity ? "default" : radioDiversity.name;
    String language = radioLanguage == RadioLanguage.withoutWords
        ? "without-words"
        : radioLanguage == RadioLanguage.notRussian
            ? "not-russian"
            : radioLanguage.name;

    String data = '{"moodEnergy": "$moodEnergy","diversity": "$diversity","language": "$language"}';

    await http.post(Uri.parse("$baseUrl/rotor/station/$currentStation/settings2"), headers: headers, body: data);
  }

  Future<void> sendRotorRadioFeedback({required RadioFeedback feedback, String trackId = "", String albumId = "", double seconds = -0.5}) async {
    DateTime times = DateTime.now();

    String params = "";
    String timestamp = "${times.year}-${times.month}-${times.day}T${times.hour}:${times.minute}:${times.second}.${times.millisecond}-04:00";
    String from = "mobile-radio-user-onyourwave";

    Map<String, dynamic> body = {
      "type": feedback.name,
      "timestamp": timestamp,
      "from": from,
    };

    if (batchId.isNotEmpty) {
      params = "?batch-id=$batchId";
    }

    if (trackId.isNotEmpty) {
      body["trackId"] = "$trackId:$albumId";
    }

    if (seconds != -0.5) {
      body["totalPlayedSeconds"] = seconds;
    }

    await http.post(Uri.parse("$baseUrl/rotor/station/$currentStation/feedback$params"), headers: headers, body: jsonEncode(body));
  }

  Future<List<Track>> getRotorTracks() async {
    String queue = "";

    if (sequence.isNotEmpty) {
      queue = "?queue=";
      for (var element in sequence) {
        queue = "$queue${element.id},";
      }
    }

    var tracksResponse = await http.get(Uri.parse("$baseUrl/rotor/station/$currentStation/tracks?setting2=true$queue"), headers: headers);

    Session session = Session.fromJson(jsonDecode(tracksResponse.body));

    batchId = session.result!.batchId!;

    return session.result!.sequence!;
  }

  ///Второй способ работы с радио, может надо, может нет)

  Future<List<Track>> createRadioSession() async {
    DateTime times = DateTime.now();
    String timestamp = "${times.year}-${times.month}-${times.day}T${times.hour}:${times.minute}:${times.second}.${times.millisecond}-04:00";

    var createSession = await http.post(Uri.parse("$baseUrl/rotor/session/new?setting2=true"),
        headers: headers, body: '{"seeds": ["user:onyourwave"],"includeTracksInResponse": true, "settings2": true}');
    Session session = Session.fromJson(jsonDecode(createSession.body));
    batchId = session.result!.batchId!;
    radioSessionId = session.result!.radioSessionId!;

    sequence = session.result!.sequence!;

    var radioStartFeedback = await http.post(Uri.parse("$baseUrl/rotor/session/$radioSessionId/feedback"),
        headers: headers,
        body: '{"event":{"type":"radioStarted","from":"radio-mobile-user-onyourwave-default","timestamp":"$timestamp"},"batchId":"$batchId"}');

    if (radioStartFeedback.statusCode == 200) {
      await sendRadioFeedback(RadioFeedback.trackStarted, sequence[0].id.toString(), 0);
      return sequence;
    }

    return [];
  }

  Future<void> sendRadioFeedback(RadioFeedback feedback, String trackId, double seconds) async {
    DateTime times = DateTime.now();
    String timestamp = "${times.year}-${times.month}-${times.day}T${times.hour}:${times.minute}:${times.second}.${times.millisecond}-04:00";

    String bodySkip =
        '{"event":{"type":"${feedback.name}","timestamp":"$timestamp","trackId":"$trackId", "totalPlayedSeconds": $seconds},"batchId":"$batchId"}';
    String bodyStart = '{"event":{"type":"${feedback.name}","timestamp":"$timestamp","trackId":"$trackId"},"batchId":"$batchId"}';

    await http.post(Uri.parse("$baseUrl/rotor/session/$radioSessionId/feedback"),
        headers: headers, body: feedback == RadioFeedback.trackStarted ? bodyStart : bodySkip);
  }

  Future<List<Track>> getRadioTracks() async {
    var radioTracks = await http.post(Uri.parse("$baseUrl/rotor/session/$radioSessionId/tracks?setting2=true"),
        headers: headers, body: '{"queue":[${sequence[0].id}], "settings2": true}');
    Session session = Session.fromJson(jsonDecode(radioTracks.body));
    sequence = session.result!.sequence!;
    return sequence;
  }
}
