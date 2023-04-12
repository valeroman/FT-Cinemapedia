

// * Definimos las reglas que necesito para trabajar este datasource
import '../entities/actor.dart';

abstract class ActorsDatasource {

  Future<List<Actor>> getActorsByMovie( String movieId );
}