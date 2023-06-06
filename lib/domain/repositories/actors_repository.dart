
import '../entities/entities.dart';

abstract class ActorsRepository {
  
  Future<List<Actor>> getActorsByMovies( String movieId );

  Future<ActorDetails> getActorDetailsById( String actorId );
}