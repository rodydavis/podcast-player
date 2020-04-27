import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:podcast_search/podcast_search.dart';

import '../constants.dart';

class PodcastController {
  final _player = AudioPlayer();
  final _playing = ValueNotifier<bool>(false);
  final _podcast = ValueNotifier<Podcast>(null);
  final _episode = ValueNotifier<Episode>(null);
  final _playingEpisode = ValueNotifier<Episode>(null);

  void load() async {
    var podcast = await Podcast.loadFeed(url: kPodcastFeed);
    _podcast.value = podcast;
  }

  ValueListenable<bool> get isPlaying => _playing;
  ValueListenable<Podcast> get feed => _podcast;
  ValueListenable<Episode> get playingEpisode => _playingEpisode;
  ValueListenable<Episode> get selection => _episode;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  void selectEpisode(Episode val) {
    _episode.value = val;
  }

  void play(Episode val) {
    _playingEpisode.value = val;
    _episode.value = val;
    _player.play(val.contentUrl);
    _player.onPlayerCompletion.listen((event) {
      _playing.value = false;
    });
    _playing.value = true;
  }

  void stop() {
    _playingEpisode.value = null;
    _player.stop();
    _playing.value = false;
  }

  void resume() {
    _player.resume();
    _playing.value = true;
  }

  void pause() {
    _player.pause();
    _playing.value = false;
  }

  void seek(Duration pos) {
    _player.seek(pos);
    _playing.value = false;
  }
}
