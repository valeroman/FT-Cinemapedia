

// * Definimos las reglas que necesito para trabajar este datasource
import 'package:cinemapedia/domain/entities/entities.dart';


abstract class ActorsDatasource {

  Future<List<Actor>> getActorsByMovie( String movieId );

  Future<ActorDetails> getActorDetailsById( String actorId );
}