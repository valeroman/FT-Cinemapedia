

import 'package:cinemapedia/infrastructure/models/moviedb/movie_video.dart';

import '../../domain/entities/video.dart';

class VideoMapper {

  static moviedbVideoToEntity( Result moviedbVideo) => Video(

    id: moviedbVideo.id,
    name: moviedbVideo.name,
    publishedAt: moviedbVideo.publishedAt,
    youtubeKey: moviedbVideo.key
  );

}