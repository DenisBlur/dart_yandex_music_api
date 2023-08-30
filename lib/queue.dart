import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yam_api/queue/queue_create.dart';
import 'package:yam_api/queue/queue_item.dart';
import 'package:yam_api/queue/queues_list.dart';
import 'package:yam_api/string_extension.dart';
import 'package:yam_api/track/track.dart';

class Queue {
  Map<String, String> headers = {};
  String device = "";
  String baseUrl = "https://api.music.yandex.net";

  String queueId = "";
  int currentPosition = 0;
  String currentQueueId = "";

  void init(Map<String, String> headers, String device) {
    this.headers = headers;
    this.device = device;

    this.headers["X-Yandex-Music-Device"] = device;
  }

  Future<bool> getQueue() async {
    var queue = await http.get(Uri.parse("$baseUrl/queues"), headers: headers);
    QueuesList queuesList = QueuesList.fromJson(jsonDecode(queue.body)["result"]);
    queueId = queuesList.queues![0].id!;
    currentQueueId = queuesList.queues![0].context!.id!;
    return queuesList.queues![0].context!.type == "radio";
  }

  Future<List<Track?>?> getQueueTracks() async {
    var queue = await http.get(Uri.parse("$baseUrl/queues/$queueId"), headers: headers);
    QueueItem queueItem = QueueItem.fromJson(jsonDecode(queue.body)["result"]);
    List<String?>? list = [];
    queueItem.tracks?.forEach((element) {
      list.add(element.trackId);
    });
    String params = list.join(',');
    String url = "/tracks?track-ids=$params";

    var trackList = await http.get(Uri.parse(baseUrl + url), headers: headers);
    List<dynamic> mapResult = jsonDecode(trackList.body)["result"];
    List<Track?>? returnList = [];
    for (var track in mapResult) {
      returnList.add(Track.fromJson(track));
    }

    currentPosition = queueItem.currentIndex!.toInt();

    return returnList;
  }

  postQueue(List<Track?>? tracks,
      String id,
      type,
      description,
      int index,) async {
    QueueCreate queueCreate = QueueCreate();

    queueCreate.tracks = [];
    for (var element in tracks!) {
      String albumId = "null";

      if (element!.albums!.isNotEmpty) {
        albumId = element.albums!.first.id.toString();
      }

      queueCreate.tracks!.add(Tracks(trackId: element.id, albumId: albumId == "null" ? null : albumId, from: "desktop_win-default-track-default"));
    }

    queueCreate.currentIndex = index;
    queueCreate.isInteractive = true;
    queueCreate.context = InfoContext(description: description, id: id, type: type);

    var queue = await http.post(Uri.parse("$baseUrl/queues"), headers: headers, body: jsonEncode(queueCreate.toJson()));
  }

  updateQueue(int index,) async {
    var queue = await http.post(
      Uri.parse("$baseUrl/queues/$queueId/update-position?currentIndex=$index&isInteractive=True"),
      headers: headers,
    );
  }

  playAudio(String trackId, String albumId, double trackLengthSeconds) async {
    ///Отправка трека на сервер
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/play-audio'));
    request.fields.addAll({
      'track-id': trackId,
      'timestamp': DateTime.now().oldTimestampYandex(),
      'play-id': '',
      'from': 'desktop_win-default-track-default'
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode != 200) {
      print(response.reasonPhrase);
    }

  }
}
