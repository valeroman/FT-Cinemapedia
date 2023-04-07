# cinemapedia

A new Flutter project.

## Dev

1. Copiar el .env.template y renombrarlo a .env
2. Cambiar las variables de entorno (The MovieDB)


#### Inicio del Proyecto

- Creamos las carpetas `presentation` y `config`
- Dentro de la carpeta `presentation` creamos la carpeta `screens` y dentro de screens creamos la carpeta `movies`

- dentro de la carpeta `movies` creamos el archivo `home_screen.dart`

- Agregamos el siguente código:

```
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(),
    );
  }
}
```

- Creamos el archivo de barril `screens.dart` dentro de la carpeta `screens`

- Agregamos el código:
```
export 'movies/home_screen.dart';

```

- Dentro de la carpeta `config`, creamos la carpeta `theme`
- En la carpeta `theme`, creamos el archivo `app_theme.dart`
- Agregamos el código:

```
import 'package:flutter/material.dart';

class AppTheme {

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF2862F5)
  );
}
```

- Dentro de la carpeta `config`, creamos la carpeta `router`.

- En la carpeta `router`, creamos el archivo `app_router.dart`

- Instalamos el paquete `go_router`
- Agregamos el código:

```
import 'package:cinemapedia/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    )
  ]
);
```

- El archivo `main.dart` agregamos la configuracion del `go_router`, para realizar la navegación de pantallas.

```
import 'package:flutter/material.dart';

import 'package:cinemapedia/config/router/app_router.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
```


## Entity - Repository - Datasources

- Creamos la carpeta `domain` y dentro de domain agregamos las carpetas: `datasources -> entities -> repositories`

#### Entity
- Creamos el archivo `movie.dart` dentro de la carpeta `entities`, la clase Movie

```
class Movie {
    final bool adult;
    final String backdropPath;
    final List<String> genreIds;
    final int id;
    final String originalLanguage;
    final String originalTitle;
    final String overview;
    final double popularity;
    final String posterPath;
    final DateTime releaseDate;
    final String title;
    final bool video;
    final double voteAverage;
    final int voteCount;

  Movie({
    required this.adult, 
    required this.backdropPath, 
    required this.genreIds, 
    required this.id, 
    required this.originalLanguage, 
    required this.originalTitle, 
    required this.overview, 
    required this.popularity, 
    required this.posterPath, 
    required this.releaseDate, 
    required this.title, 
    required this.video, 
    required this.voteAverage, 
    required this.voteCount
  });
}
```

#### Datasource

- Creamos el archivo `movies_datasource.dart` dentro de la carpeta `datasources`, la clase abstracta `MoviesDatasource`, la cual no crea instancia de ella.

- Aqui defino como lucen los origenes de datos que pueden traer peliculas, normalmente son los métodos que voy a llamar para traer la data.

- La clase `MoviesDatasource` defino el primer metodo `getNowPlaying`

```
import '../entities/movie.dart';

abstract class MoviesDatasource {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

}
```

#### Repository

- Creamos el archivo `movies_repository.dart` dentro de la carpeta `repositories`, la clase abstracta `MoviesRepository`, la cual no crea instancia de ella.

- El repositorio es quien llama al datasource, el repositorio es el que permite cambiar el datasource.

- La clase `MoviesRepository` defino el primer metodo `getNowPlaying`

```
import '../entities/movie.dart';

abstract class MoviesRepository {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

}
```

#### .ENV - .ENV.TEMPLATE
- creamos en la raíz del proyecto el archivo `.env` y `.env.template`, para colocar una variable de entorno.

```
THE_MOVIEDB_KEY=
```

### flutter_dotenv Instalación
Documentación: https://pub.dev/packages/flutter_dotenv

- `flutter_dotenv` permite utilizar los archivos .env en la aplicación.

- Ya instalado el paquete, abrimos el archivo `pubspec.yaml` y agregamos lo siguiente despues de:

```
flutter:
  uses-material-design: true
```

```
assets:
  - .env
```

- Para usar el archivo `.env` en nuestro proyecto, abrimos el archivo `main.dart` importammos el paquete:
```
import 'package:flutter_dotenv/flutter_dotenv.dart';
```
- Y actualizamos el main():
```
Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MainApp());
}
```

#### Constants 
- Creamos una carpeta llamada `constatnts` dentro de la carpeta `config`
- Creamos el archivo `environment.dart` y creamos la clase `Environment`

```

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {

  static String theMovieDbKey = dotenv.env['THE_MOVIEDB_KEY'] ?? 'No hay API Key';
}
```

#### Infrastructure
- Creamos la carpeta dentro de `lib` => `infrastructure`, para crear todas las implementaciones que estan en el `domain`.

- Creamos la carpeta `datasources` y  el archivo `moviedb_datasource.dart`, va a tener las interaciones con el api theMovieDB, unicamente.

- Instalamos el paquete de `dio`, para realizar peticiones http `dio: ^5.1.1`

- Ahora agregamos el siguiente código:
```

import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:dio/dio.dart';

class MoviedbDatasource extends MoviesDatasource {

    // Propiedades de la clase MoviedbDatasource
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {
        'api_key': Environment.theMovieDbKey,
        'language': 'es-ES' // es-MX
      }
    ));


  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {

    final response = await dio.get('/movie/now_playing');
    final List<Movie> movies = [];

    return movies;

  }

}

```
- Pero falta mapear la data que nos viene del API MovieDB.

- En la carpeta `infrastructure`, agregamos las carpetas `models` y dentro de model `moviedb`.
- Dentro de la carpeta `moviedb`, creamos los archivos `moviedb_response.dart` y `movie_moviedb.dart`
- En el archivo `moviedb_response.dart` compiamos la respuesta del api => `https://api.themoviedb.org/3/movie/now_playing` y nos vamos a https://quicktype.io/, para generar las clases
- En `quicktype.io`, pegamos la respuesta del api y le colocamos el nombre de `MovieDbResponse` y copiamos todo al archivo `moviedb_response.dart`
- Sustituimos en la clase `Result` por `MovieMovieDB`
- Y cortamos toda la clase `MovieMovieDB` y la pegaremos en el archivo `movie_moviedb.dart`
- Terminados los ajustes al archivo el resultado seria:
```
import 'movie_moviedb.dart';

class MovieDbResponse {
    MovieDbResponse({
        required this.dates,
        required this.page,
        required this.results,
        required this.totalPages,
        required this.totalResults,
    });

    final Dates? dates;
    final int page;
    final List<MovieMovieDB> results;
    final int totalPages;
    final int totalResults;

    factory MovieDbResponse.fromJson(Map<String, dynamic> json) => MovieDbResponse(
        dates: json["dates"] ? Dates.fromJson(json["dates"]) : null,
        page: json["page"],
        results: List<MovieMovieDB>.from(json["results"].map((x) => MovieMovieDB.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
    );

    Map<String, dynamic> toJson() => {
        "dates": dates == null ? null : dates!.toJson(),
        "page": page,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "total_pages": totalPages,
        "total_results": totalResults,
    };
}

class Dates {
    Dates({
        required this.maximum,
        required this.minimum,
    });

    final DateTime maximum;
    final DateTime minimum;

    factory Dates.fromJson(Map<String, dynamic> json) => Dates(
        maximum: DateTime.parse(json["maximum"]),
        minimum: DateTime.parse(json["minimum"]),
    );

    Map<String, dynamic> toJson() => {
        "maximum": "${maximum.year.toString().padLeft(4, '0')}-${maximum.month.toString().padLeft(2, '0')}-${maximum.day.toString().padLeft(2, '0')}",
        "minimum": "${minimum.year.toString().padLeft(4, '0')}-${minimum.month.toString().padLeft(2, '0')}-${minimum.day.toString().padLeft(2, '0')}",
    };
}
``` 
- En el archivo `movie_moviedb.dart`  validamos unos campos, deberia de quedar asi:

```
class MovieMovieDB {
    MovieMovieDB({
        required this.adult,
        required this.backdropPath,
        required this.genreIds,
        required this.id,
        required this.originalLanguage,
        required this.originalTitle,
        required this.overview,
        required this.popularity,
        required this.posterPath,
        required this.releaseDate,
        required this.title,
        required this.video,
        required this.voteAverage,
        required this.voteCount,
    });

    final bool adult;
    final String backdropPath;
    final List<int> genreIds;
    final int id;
    final String originalLanguage;
    final String originalTitle;
    final String overview;
    final double popularity;
    final String posterPath;
    final DateTime releaseDate;
    final String title;
    final bool video;
    final double voteAverage;
    final int voteCount;

    factory MovieMovieDB.fromJson(Map<String, dynamic> json) => MovieMovieDB(
        adult: json["adult"] ?? false,
        backdropPath: json["backdrop_path"] ?? '',
        genreIds: List<int>.from(json["genre_ids"].map((x) => x)),
        id: json["id"],
        originalLanguage: json["original_language"],
        originalTitle: json["original_title"],
        overview: json["overview"] ?? '',
        popularity: json["popularity"]?.toDouble(),
        posterPath: json["poster_path"] ?? '',
        releaseDate: DateTime.parse(json["release_date"]),
        title: json["title"],
        video: json["video"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
    );

    Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
        "id": id,
        "original_language": originalLanguage,
        "original_title": originalTitle,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "release_date": "${releaseDate.year.toString().padLeft(4, '0')}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}",
        "title": title,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
    };
}

```

#### Mappers
Un mapper va a leer varios modelos y crear la entidad.

- En la carpeta `infrastructure`, creamos la carpeta `mappers` y dentro de mappers, creamos el archivo `movie_mapper.dart`

- En el archivo `movie_mapper.dart` creamos una clase llamada `MovieMapper`, cuya funcion es crear una pelicula o movie, basado en un tipo deobjeto que vamos a recibir.
- El código del mapper quedaria asi:
```
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_moviedb.dart';

class MovieMapper {
  // Retornar una movie, pero se va a recibir una MovieMovieDB
  //  y regreso la instancia de Movie
  static Movie movieDBToEntity(MovieMovieDB moviedb) => 
  Movie(
      adult: moviedb.adult,
      backdropPath: (moviedb.backdropPath != '')
        ? 'https://image.tmdb.org/t/p/w500/${ moviedb.backdropPath }'
        : 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
      genreIds: moviedb.genreIds.map((e) => e.toString()).toList(),
      id: moviedb.id,
      originalLanguage: moviedb.originalLanguage,
      originalTitle: moviedb.originalTitle,
      overview: moviedb.overview,
      popularity: moviedb.popularity,
      posterPath: (moviedb.posterPath != '')
         ? 'https://image.tmdb.org/t/p/w500/${ moviedb.posterPath }'
        : 'no-poster',
      releaseDate: moviedb.releaseDate,
      title: moviedb.title,
      video: moviedb.video,
      voteAverage: moviedb.voteAverage,
      voteCount: moviedb.voteCount
  );
}
```

- Ahora que ya tenemos la clase `MovieMapper` lista, la usaremos en la clase `MoviedbDatasource`, que se encuentra en `infrastructure -> datasources -> moviedb_datasource.dart`

- el código queda asi:
```
final movieDBResponse = MovieDbResponse.fromJson(response.data);

// El where => nos ayuda a filtrar si no tenemos imagen del poster, no se crea la movie
final List<Movie> movies = movieDBResponse.results
.where((moviedb) => moviedb.posterPath != 'no-poster')
.map(
    (moviedb) => MovieMapper.movieDBToEntity(moviedb)
).toList();
```

### Implementación del Repositorio

- Creamos la carpeta `repositories` dentro de la carpeta `infrastructure`

- Creamos el archivo `movie_repository_impl.dart`
- La implementación del `movie_repository_impl.dart`, es llamar al datasource
- Creamos la clase `MovieRepositoryImpl` que extiende de `MoviesRepository`
- Código:
```
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/repositories/movies_repository.dart';

import '../../domain/datasources/movies_datasource.dart';

class MovieRepositoryImpl extends MoviesRepository {
  
  // Llamamos al datasource
  final MoviesDatasource datasource;
  MovieRepositoryImpl(this.datasource);

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) {
    return datasource.getNowPlaying(page: page);
  }

}
```

### Crear la instancia del repositorio - Riverpod

- Creamos  dentro de `presentation` la carpeta `providers` y dentro de providers la carpeta `movies`
- Creamos el archivo `movies_repository_provider.dart` dentro de la carpeta `movies`, el archivo `movies_repository_provider.dart`, va a hacer quien va a crear la instancia de ese `MovieRepositoryImpl`.

- Instalamos el Gestor de Estados => `flutter_riverpod`
- Actualizamos el `main.dart` con el siguente código:
```
runApp(
    const ProviderScope(child: MainApp())
);
```

- En el archivo `movies_repository_provider.dart` , copiamos el siguiente código:
```
import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';


// Este provider nunca va a cambiar, osea la data no cambia
// Los providers aqui son de solo lectura => Provider
// Este repositorio es inmutable
final movieRepositoryProvider = Provider((ref) {
  return MovieRepositoryImpl(MoviedbDatasource()); 
  // return MovieRepositoryImpl(IMDBDatasource()); // en el caso que tengamos otro datasource
});
```

#### NowPlaying Provider y Notifier

- Creamos el archivo `movies_providers.dart` dentro de la carpeta `movies`, 
- agregamos el código:

```


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
  MovieCallback fetchMoreMovies;

  MoviesNotifier({
    required this.fetchMoreMovies,
  }): super([]);

  // Metodos
  Future<void> loadNextPage() async {
    currentPage++;
    final List<Movie> movies = await fetchMoreMovies( page: currentPage );
    state = [...state, ...movies];
  }

}
```

#### Crear el archivo de barril

- creamos el archivo `providers.dart` en la carpeta `presentation -> providers`

```


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
  MovieCallback fetchMoreMovies;

  MoviesNotifier({
    required this.fetchMoreMovies,
  }): super([]);

  // Metodos
  Future<void> loadNextPage() async {
    currentPage++;
    final List<Movie> movies = await fetchMoreMovies( page: currentPage );
    state = [...state, ...movies];
  }

}
```

#### Mostrar las películas en pantalla

- Extraemos el widget del placeholder y lo llamamos `_HomeView`
- Cuado se carga la pagina del `home_screen.dart`, se quiere tambien cargar la primera pagina de la moviesPlaying, para ello cambiamos de `StatelessWidget` a `StatefulWidget`, el widget del `_HomeView`
- Agregamos el `initState`, en la clase `_HomeViewState`
- Ahora cambiamos el  `StatefulWidget` a `ConsumerStatefulWidget`
```
class _HomeView extends ConsumerStatefulWidget {
  const _HomeView();

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<_HomeView> {

  @override
  void initState() {
    super.initState();

    ref.read( nowPlayingMoviesProvider.notifier ).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
```

- 

