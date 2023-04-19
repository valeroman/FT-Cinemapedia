import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// * FutureProvider.family => me permite mandar un argumento que es el id de la pelicula
final FutureProviderFamily<List<Video>, int> videosFromMovieProvider = FutureProvider.family((ref, int movieId) {
    final movieRepository = ref.watch( movieRepositoryProvider );
    return movieRepository.getYoutubeVideosById(movieId);
});

class VideoFromMovie extends ConsumerWidget {

  final int movieId;

  const VideoFromMovie({
    super.key, 
    required this.movieId
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final moviesFromVideo = ref.watch( videosFromMovieProvider(movieId) );

    return moviesFromVideo.when(
      data: ( videos ) => _VideoList(videos: videos), 
      error: ( _, __ ) => const Center(child: Text('No se pudo cargar el video')), 
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _VideoList extends StatelessWidget {

  final List<Video> videos;

  const _VideoList({required this.videos});

  @override
  Widget build(BuildContext context) {

    if ( videos.isEmpty ) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('Videos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        ),

        // * Mostrar solo un video
        _YoutubeVideoPlayer(youtubeId: videos.first.youtubeKey, name: videos.first.name)

      ],
    );
  }
}

class _YoutubeVideoPlayer extends StatefulWidget {

  final String youtubeId;
  final String name;

  const _YoutubeVideoPlayer({
    required this.youtubeId, 
    required this.name
  });

  @override
  State<_YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<_YoutubeVideoPlayer> {

  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(
        hideThumbnail: true,
        showLiveFullscreenButton: false,
        mute: false,
        autoPlay: false,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false
      )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name),
          YoutubePlayer(controller: _controller)
        ],
      ),
    );
  }
}