
import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:cinemapedia/presentation/providers/actors/actor_details_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// * Crear el provider
final actorDetailsProvider = StateNotifierProvider<ActorDetailsMapNotifier, Map<String, ActorDetails>>((ref) {
  final actorDetailsRepository = ref.watch( actorDetailRepositoryProvider );
  return ActorDetailsMapNotifier(getActorDetail: actorDetailsRepository.getActorDetailsById);
});


// * Definición del callback
typedef GetActorDetailsCallback = Future<ActorDetails>Function(String actorId);

class ActorDetailsMapNotifier extends StateNotifier<Map<String, ActorDetails>> {

  final GetActorDetailsCallback getActorDetail;

  ActorDetailsMapNotifier({
    required this.getActorDetail
  }): super({});

  Future<void> loadDetail( String actorId ) async {

    if ( state[actorId] != null ) return;

    final actorDetail = await getActorDetail( actorId ) ;


    // * Genero un nuevo estado
    // * Clono el state y agrego el movieId que apunta a la movie
    state = { ...state, actorId: actorDetail };
  }
  
}
