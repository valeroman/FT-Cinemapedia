
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/movie.dart';

// * Crear el provider
final movieInfoProvider = StateNotifierProvider<MovieMapNotifier, Map<String, Movie>>((ref) {
  final movieRepository = ref.watch( movieRepositoryProvider );
  return MovieMapNotifier(getMovie: movieRepository.getMovieById);
});

/*
  {
    '505642': Movie(),
    '505643': Movie(),
    '505643': Movie(),
    '505342': Movie(),
  }
*/

// * Definición del callback
typedef GetMovieCallback = Future<Movie>Function(String movieId);

class MovieMapNotifier extends StateNotifier<Map<String, Movie>> {

  final GetMovieCallback getMovie;

  MovieMapNotifier({ 
    required this.getMovie,
  }): super({});

  Future<void> loadMovie( String movieId ) async {

    if ( state[movieId] != null ) return;

    final movie = await getMovie( movieId ) ;


    // * Genero un nuevo estado
    // * Clono el state y agrego el movieId que apunta a la movie
    state = { ...state, movieId: movie };
  }

}