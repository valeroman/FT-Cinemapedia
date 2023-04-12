

import 'package:cinemapedia/presentation/providers/actors/actors_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/actor.dart';


// * Crear el provider
final actorsByMovieProvider = StateNotifierProvider<ActorsByMovieNotifier, Map<String, List<Actor>>>((ref) {
  final actorsRepository = ref.watch( actorsRepositoryProvider );

  return ActorsByMovieNotifier(getActors: actorsRepository.getActorsByMovies);
});

/*
  {
    '505642': <Actor>(),
    '505643': <Actor>(),
    '505643': <Actor>(),
    '505342': <Actor>(),
  }
*/

// * Definición del callback
typedef GetActorsCallback = Future<List<Actor>>Function(String movieId);

class ActorsByMovieNotifier extends StateNotifier<Map<String, List<Actor>>> {

  final GetActorsCallback getActors;

  ActorsByMovieNotifier({ 
    required this.getActors,
  }): super({});

  Future<void> loadActors( String movieId ) async {

    if ( state[movieId] != null ) return;

    final List<Actor> actors = await getActors( movieId ) ;


    // * Genero un nuevo estado
    // * Clono el state y agrego el movieId que apunta a la movie
    state = { ...state, movieId: actors };
  }

}