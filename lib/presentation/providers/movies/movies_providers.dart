

import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/domain/entities/movie.dart';


// Cuando necesite saber cuales paliculas o movies hay en el cine.
// consulto este provider => nowPlayingMoviesProvider
final nowPlayingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {

  final fetcMoreMovies = ref.watch( movieRepositoryProvider ).getNowPlaying;

  return MoviesNotifier(
    fetchMoreMovies: fetcMoreMovies
  );
});

// Definir el tipo de función que espero
// definir el caso de uso, 
typedef MovieCallback = Future<List<Movie>> Function({ int page });


// El MoviesNotifier el objetivo es que proporcione el listado de movies
class MoviesNotifier extends StateNotifier<List<Movie>> {

  // Propiedades
  int currentPage = 0;
  bool isLoading = false;
  MovieCallback fetchMoreMovies;

  MoviesNotifier({
    required this.fetchMoreMovies,
  }): super([]);

  // Metodos
  Future<void> loadNextPage() async {
    if ( isLoading ) return;
    isLoading = true;

    currentPage++;
    final List<Movie> movies = await fetchMoreMovies( page: currentPage );
    state = [...state, ...movies];
    
    await Future.delayed(const Duration(milliseconds: 300));
    isLoading = false;
  }

}