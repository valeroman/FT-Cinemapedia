
import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/entities/actor_details.dart';
import 'package:cinemapedia/infrastructure/mappers/actor_details_mapper.dart';
import 'package:cinemapedia/infrastructure/mappers/actor_mapper.dart';
import 'package:cinemapedia/infrastructure/models/actors/actor_details.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';
import 'package:dio/dio.dart';

import '../../config/constants/environment.dart';

class ActorMovieDbDatasource extends ActorsDatasource {

  // Propiedades de la clase MoviedbDatasource
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {
        'api_key': Environment.theMovieDbKey,
        'language': 'es-ES' // es-MX
      }
    ));

  @override
  Future<List<Actor>> getActorsByMovie(String movieId) async {

    final response = await dio.get('/movie/$movieId/credits');

    final castResponse = CreditsResponse.fromJson(response.data);

    List<Actor> actors = castResponse.cast.map(
      (cast) => ActorMapper.castToEntity(cast)
    ).toList();

    return actors;

  }

  @override
  Future<ActorDetails> getActorDetailsById(String actorId) async {

    final response = await dio.get('/person/$actorId');

    if ( response.statusCode != 200 ) throw Exception('Actor with id: $actorId not found ');

    final actorDetails = ActorDetailsDB.fromJson(response.data);
    final ActorDetails actorDetail = ActorDetailsMapper.actorDetailToEntry(actorDetails);
    return actorDetail;
  }

}

