

import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/entities/actor_details.dart';
import 'package:cinemapedia/domain/repositories/actors_repository.dart';

class ActorRepositoryImpl extends ActorsRepository  {

  final ActorsDatasource datasource;

  ActorRepositoryImpl(this.datasource);

  @override
  Future<List<Actor>> getActorsByMovies(String movieId) {
    return datasource.getActorsByMovie(movieId);
  }

  @override
  Future<ActorDetails> getActorDetailsById(String actorId) {
    return datasource.getActorDetailsById(actorId);
  }
}