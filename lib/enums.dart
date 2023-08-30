enum QualityTrack { medium, high, low }

enum ObjectType { playlist, artist, album, track }

enum SearchType {all, user, playlist, artist, album, track, podcast }

enum ChartSelect { russia, world }

enum RadioFeedback {off, on, radioStarted, trackStarted, trackFinished, skip, getTracks}

enum RadioDiversity {favorite, discover, popular, defaultDiversity, none}
enum RadioMoodEnergy {active, fun, calm, sad, all, none}
enum RadioLanguage {russian, notRussian, withoutWords, any, none}

enum QueueType { radio, my_music, album, various, search}

List<String> diversityTranslate = [
  "Любимое",
  "Незнакомое",
  "Популярное",
  "Любое",
];

List<String> moodEnergyTranslate = [
  "Бодрое",
  "Весёлое",
  "Спокойное",
  "Грустное",
  "Любое",
];

List<String> languageTranslate = [
  "Русский",
  "Иностранный",
  "Без слов",
  "Любой",
];
