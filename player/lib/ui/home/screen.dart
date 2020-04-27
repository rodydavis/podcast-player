import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../src/constants.dart';
import '../../src/controllers/podcast.dart';
import 'details.dart';

const kTabletBreakpiint = 720.0;
const kSideMenuWidth = 350.0;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _controller = Provider.of<PodcastController>(context, listen: false);

    return LayoutBuilder(
      builder: (_, dimens) {
        if (dimens.maxWidth >= kTabletBreakpiint) {
          return Row(
            children: <Widget>[
              Container(
                width: kSideMenuWidth,
                child: buildEpisodes(context, (val) {
                  _controller.selectEpisode(val);
                }),
              ),
              VerticalDivider(width: 0),
              Expanded(
                child: ValueListenableBuilder<Episode>(
                  valueListenable: _controller.selection,
                  builder: (context, episode, child) {
                    if (episode == null) {
                      return Scaffold(
                        appBar: AppBar(),
                        body: Center(child: Text('No Episode Selected')),
                      );
                    }
                    return EpisodeDetails(episode: episode);
                  },
                ),
              ),
            ],
          );
        }
        return buildEpisodes(context, (val) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EpisodeDetails(episode: val),
          ));
        });
      },
    );
  }

  Widget buildEpisodes(BuildContext context, ValueChanged<Episode> onSelect) {
    final _controller = Provider.of<PodcastController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Creative Engineering'),
        actions: [
          IconButton(
            icon: Icon(Icons.rss_feed),
            onPressed: () {
              launch('feed:$kPodcastFeed');
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _controller.load();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: ValueListenableBuilder<Episode>(
          valueListenable: _controller.playingEpisode,
          builder: (context, episode, child) => ValueListenableBuilder<bool>(
            valueListenable: _controller.isPlaying,
            builder: (context, playing, child) =>
                ValueListenableBuilder<Podcast>(
              valueListenable: _controller.feed,
              builder: (context, podcast, child) => Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: podcast == null
                        ? Center(child: CircularProgressIndicator())
                        : RepaintBoundary(child: Image.network(podcast.image)),
                  ),
                  Expanded(
                    child: ListTile(
                      dense: true,
                      title: Text(
                        episode == null ? 'No Podcast Selected' : episode.title,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Episode Details',
                    icon: Icon(Icons.info_outline),
                    onPressed: episode == null ? null : () => onSelect(episode),
                  ),
                  IconButton(
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: episode == null
                        ? null
                        : () {
                            if (playing) {
                              _controller.pause();
                              return;
                            }
                            _controller.resume();
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<Podcast>(
        valueListenable: _controller.feed,
        builder: (context, podcast, child) {
          if (podcast == null) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(height: 0),
            itemCount: podcast.episodes.length,
            itemBuilder: (context, index) {
              final _episode = podcast.episodes[index];
              return ListTile(
                leading: RepaintBoundary(child: Image.network(podcast.image)),
                title: Text(_episode.title),
                subtitle: Text(timeago.format(_episode.publicationDate)),
                trailing: IconButton(
                  tooltip: 'Episode Details',
                  icon: Icon(Icons.info_outline),
                  onPressed: () => onSelect(_episode),
                ),
                onTap: () {
                  _controller.play(_episode);
                },
              );
            },
          );
        },
      ),
    );
  }
}
