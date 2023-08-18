import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yam_api/radio/Session.dart';
import 'package:yam_api/track/track.dart';

import 'enums.dart';

class Radio {
  String baseUrl = "https://api.music.yandex.net";

  String batchId = "";
  String radioSessionId = "";

  Map<String, String> headers = {};
  String device = "";

  List<Track> sequence = [];

  void init(Map<String, String> headers, String device) {
    this.headers = headers;
    this.device = device;
  }

  Future<void> startRotorRadio(String station) async {
    String stationInfo = await getStationInfo(station);
    print(stationInfo);

  }


  Future<String> getStationInfo(String station) async {
    var stationInfo = await http.get(Uri.parse("$baseUrl/rotor/station/$station/info"), headers: headers);
    return stationInfo.body;
  }

  Future<void> sendStationSetting({required String station,
    required RadioDiversity radioDiversity,
    required RadioMoodEnergy radioMoodEnergy,
    required RadioLanguage radioLanguage}) async {
    String moodEnergy = radioMoodEnergy.name;
    String diversity = radioDiversity == RadioDiversity.defaultDiversity ? "default" : radioDiversity.name;
    String language = radioLanguage == RadioLanguage.withoutWords ? "without-words" : radioLanguage == RadioLanguage.notRussian
        ? "not-russian"
        : radioLanguage.name;

    String data = '{"moodEnergy": "$moodEnergy","diversity": "$diversity","type": "rotor","language": "$language"}';

    var stationInfo = await http.post(Uri.parse("$baseUrl/rotor/station/$station/settings3"), headers: headers, body: data);
  }

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

    print(batchId);
    print(radioSessionId);

    if (radioStartFeedback.statusCode == 200) {
      print(createSession.body);
      await sendRadioFeedback(RadioFeedback.trackStarted, sequence[0].id.toString(), 0);
      return sequence;
    }

    print(createSession.body);

    return [];
  }

  Future<void> sendRotorRadioFeedback(
      {String station = "user:onyourwave", required RadioFeedback feedback, String trackId = "", double seconds = -0.5}) async {
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
      body["trackId"] = trackId;
    }

    if (seconds != -0.5) {
      body["totalPlayedSeconds"] = seconds;
    }

    print(jsonEncode(body));

    // var trackFeedback = await http.post(Uri.parse("$baseUrl/rotor/session/$station/feedback$params"),
    //     headers: headers, body: jsonEncode(body));
    //
    // print(trackFeedback.body);

  }

  Future<void> sendRadioFeedback(RadioFeedback feedback, String trackId, double seconds) async {
    DateTime times = DateTime.now();
    String timestamp = "${times.year}-${times.month}-${times.day}T${times.hour}:${times.minute}:${times.second}.${times.millisecond}-04:00";

    String bodySkip =
        '{"event":{"type":"${feedback.name}","timestamp":"$timestamp","trackId":"$trackId", "totalPlayedSeconds": $seconds},"batchId":"$batchId"}';
    String bodyStart = '{"event":{"type":"${feedback.name}","timestamp":"$timestamp","trackId":"$trackId"},"batchId":"$batchId"}';

    var trackFeedback = await http.post(Uri.parse("$baseUrl/rotor/session/$radioSessionId/feedback"),
        headers: headers, body: feedback == RadioFeedback.trackStarted ? bodyStart : bodySkip);
  }

  Future<List<Track>> getRadioTracks() async {
    var radioTracks =
    await http.post(Uri.parse("$baseUrl/rotor/session/$radioSessionId/tracks?setting2=true"), headers: headers,
        body: '{"queue":[${sequence[0].id}], "settings2": true}');
    Session session = Session.fromJson(jsonDecode(radioTracks.body));
    sequence = session.result!.sequence!;

    print(radioTracks.body);

    return sequence;
  }
}