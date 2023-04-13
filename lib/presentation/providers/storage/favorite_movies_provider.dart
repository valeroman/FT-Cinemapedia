

import 'package:cinemapedia/domain/repositories/local_starage_repository.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';


// * Creamos un nuevo contenedor en memoria, para todas las peliculas que estan en favoritos

final favoriteMoviesProvider = StateNotifierProvider<StorageMoviesNotifier, Map<int, Movie>>((ref) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return StorageMoviesNotifier(localStorageRepository: localStorageRepository);
});

/*

  {
    1234: Movie,
    1644: Movie,
    3343: Movie,
  }

*/

class StorageMoviesNotifier extends StateNotifier<Map<int, Movie>> {

  int page= 0;
  final LocalStorageRepository localStorageRepository;

  StorageMoviesNotifier({
    required this.localStorageRepository
  }): super({});

  Future<List<Movie>> loadNextPage() async {

    final movies = await localStorageRepository.loadMovies(offset: page * 10, limit: 20);
    page++;

    final tempMoviesMap = <int, Movie>{};
    for(final movie in movies) {
      tempMoviesMap[movie.id] = movie;
    }

    state = { ...state, ...tempMoviesMap };

    return movies;
  }

  Future<void> toggleFavorite( Movie movie) async {

    await localStorageRepository.toggleFavorite(movie);

    // * verifico si ya existe esa pelicula en el listado de peliculas favoritas
    final bool isMovieInFavorites = state[movie.id] != null;

    if ( isMovieInFavorites ) {
      state.remove(movie.id);
      state = { ...state };
    } else {
      state = { ...state, movie.id: movie };
    }
  }

}