
import '../entities/actor.dart';

abstract class ActorsRepository {
  
  Future<List<Actor>> getActorsByMovies( String movieId );
}