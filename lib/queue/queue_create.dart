import 'package:yam_api/queue/queue_item.dart';

class QueueCreate {
  QueueCreate({
    this.tracks,
    this.isInteractive,
    this.from,
    this.currentIndex,
    this.context,
  });

  QueueCreate.fromJson(dynamic json) {
    if (json['tracks'] != null) {
      tracks = [];
      json['tracks'].forEach((v) {
        tracks?.add(Tracks.fromJson(v));
      });
    }
    isInteractive = json['isInteractive'];
    from = json['from'];
    currentIndex = json['currentIndex'];
    context = json['context'] != null ? InfoContext.fromJson(json['context']) : null;
  }

  List<Tracks>? tracks;
  bool? isInteractive;
  dynamic from;
  num? currentIndex;
  InfoContext? context;

  QueueCreate copyWith({
    List<Tracks>? tracks,
    bool? isInteractive,
    dynamic from,
    num? currentIndex,
    InfoContext? context,
  }) =>
      QueueCreate(
        tracks: tracks ?? this.tracks,
        isInteractive: isInteractive ?? this.isInteractive,
        from: from ?? this.from,
        currentIndex: currentIndex ?? this.currentIndex,
        context: context ?? this.context,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (tracks != null) {
      map['tracks'] = tracks?.map((v) => v.toJson()).toList();
    }
    map['isInteractive'] = isInteractive;
    map['from'] = from;
    map['currentIndex'] = currentIndex;
    if (context != null) {
      map['context'] = context?.toJson();
    }
    return map;
  }
}

class InfoContext {
  InfoContext({
    this.type,
    this.id,
    this.description,
  });

  InfoContext.fromJson(dynamic json) {
    type = json['type'];
    id = json['id'];
    description = json['description'];
  }

  String? type;
  String? id;
  String? description;

  InfoContext copyWith({
    String? type,
    String? id,
    String? description,
  }) =>
      InfoContext(
        type: type ?? this.type,
        id: id ?? this.id,
        description: description ?? this.description,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['id'] = id;
    map['description'] = description;
    return map;
  }
}
