

// * El primer provider que se va a manejar es el Stream
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';

// * Este provider solo maneja el string
final searchQueryProvider = StateProvider<String>((ref) => '');

// * Este provider va a manejar las peliculas previamente buscadas o implementacion del searchedMoviesProvider
final searchedMoviesProvider = StateNotifierProvider<SearchedMoviesNotifier, List<Movie>>((ref) {

  final movieRepository = ref.read( movieRepositoryProvider );

  return SearchedMoviesNotifier(
    ref: ref, 
    searchMovies: movieRepository.searchMovies
  );
});


// * defino una función personalizada
typedef SearchMoviesCallback = Future<List<Movie>> Function( String query );



// * Creamos el Notifier
class SearchedMoviesNotifier extends StateNotifier<List<Movie>> {

  // Propiedades son final por que  no va a cambiar
  final SearchMoviesCallback searchMovies;
  final Ref ref;


  // Constructor
  SearchedMoviesNotifier({
    required this.searchMovies,
    required this.ref,
  }): super([]);

  // Metodo
  Future<List<Movie>> searchMoviesByQuery( String query ) async {

    // Obtengo las peliculas
    final List<Movie> movies = await searchMovies( query );
    ref.read( searchQueryProvider.notifier ).update((state) => query);

    // Ahora el resultado lo metemos en el estado, como es un nuevo objecto no hacemos el sprade [...movies]
    state = movies;

    return movies;
  }
}