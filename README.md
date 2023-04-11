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

import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_response.dart';
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

    final response = await dio.get('/movie/now_playing',
      queryParameters: {
        'page': page
      }
    );

    final movieDBResponse = MovieDbResponse.fromJson(response.data);

    // El where => nos ayuda a filtrar si no tenemos imagen del poster, no se crea la movie
    final List<Movie> movies = movieDBResponse.results
    .where((moviedb) => moviedb.posterPath != 'no-poster')
    .map(
      (moviedb) => MovieMapper.movieDBToEntity(moviedb)
    ).toList();

    return movies;
  }
}
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

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );

    return ListView.builder(
      itemCount: nowPlayingMovies.length,
      itemBuilder: (context, index) {
        final movie = nowPlayingMovies[index];
        return ListTile(
          title: Text( movie.title ),
        );
      },
    );
  }
}
```

### Widgets del la aplicación:


####  - Appbar -

- Creamos dentro de la carpeta `presentation` la carpeta `widgets` y dentro la carpeta `widgets` creamos la carpeta `shared` que es de uso general
- Dentro de `shared`, creamos el archivo `custom_appbar.dart`

- En el archivo `custom_appbar.dart` agregamos el siguiente código:

```
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

- Creamos el archivo de barril `widgets.dart`, dentro de la carpeta `widgets`
- agregamos el código:
```
export 'shared/custom_appbar.dart';
```

- Ahora vamos al archivo `home_screem.dart`, realizamos unos cambios como:
  1 - Cortamos el `ListView.builder` y agregamos un `Column`, luego pegamos el `Lisview.Builder`, en los `children` del Column, al `ListView.builder` lo envolvemos en un nuevo widget `Expanded`
  2 - Agregamos el `CustomAppbar` al children de `Column`, el código quedaria asi:

  ```
  @override
  Widget build(BuildContext context) {

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );

    return Column(
      children: [

        CustomAppbar(),

        Expanded(
          child: ListView.builder(
            itemCount: nowPlayingMovies.length,
            itemBuilder: (context, index) {
              final movie = nowPlayingMovies[index];
              return ListTile(
                title: Text( movie.title ),
              );
            },
          ),
        )
      ]
    );
  }
  ```

- Ahora vamos a cambiar el diseño del`custom_appbar.dart`
- Agregamos el siguiente códiigo:

```
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Icon(Icons.movie_outlined, color: colors.primary),
              const SizedBox( width: 5 ),
              Text('Cinemapedia', style: titleStyle,),
      
              const Spacer(),
      
              IconButton(
                onPressed: (){}, 
                icon: const Icon(Icons.search)
              )
            ],
          ),
        ),
      ),
    );
  }
}
```

- Nota: si queremos ver el area del widget de un color rojo, por ejemplo, entonces envolvemos en un nuevo widget el `Padding` y agregamos el `Container` y al `Container`, le colocamos le propiedad `color: Colors.red` .

- Código de ejemplo del  `Container`:
```
@override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return SafeArea(
      child: Container(
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Icon(Icons.movie_outlined, color: colors.primary),
                const SizedBox( width: 5 ),
                Text('Cinemapedia', style: titleStyle,),
        
                const Spacer(),
        
                IconButton(
                  onPressed: (){}, 
                  icon: const Icon(Icons.search)
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
```
- Para quitar el `Padding` removemos el widget.

- 

####  - MovieSlideShow - Carrusel de peliculas

Documentación: https://pub.dev/packages/card_swiper

- Usaremos un paquete de terceros llamado: `card_swiper`, e instalamos la libreria.

- Ahora dentro de la carpeta `presentation -> widgets`, creamos la carpeta `movies`, ya que el carrusel esta relacionado a peliculas, quiero mostrar las peliculas

- Y dentro de `movies`, cramos el archivo `movies_slideshow.dart`
- Agregamos el siguuiente código:
```
import 'package:flutter/material.dart';
import '../../../domain/entities/movie.dart';

class MoviesSlideshow extends StatelessWidget {

  final List<Movie> movies;

  const MoviesSlideshow({
    super.key, 
    required this.movies
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

- Ahora vamos al archivo `home_screem.dart`, realizamos unos cambios.

- Quitamos el ListView.builder por que ya no vamos a mostrar la lista de peliculas.
- Agregamos nuestro widget `MoviesSlideshow`, el código seria asi:

```
@override
  Widget build(BuildContext context) {

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );

    return Column(
      children: [

        const CustomAppbar(),
        MoviesSlideshow(movies: nowPlayingMovies),

      ]
    );
  }
```

- Ahora vamos a cambiar el diseño del`movies_slideshow.dart`
- Agregamos el siguiente códiigo:

```


import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/movie.dart';

class MoviesSlideshow extends StatelessWidget {

  final List<Movie> movies;

  const MoviesSlideshow({
    super.key, 
    required this.movies
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Swiper(
        viewportFraction: 0.8,
        scale: 0.9,
        autoplay: true,
        itemCount: movies.length,
        itemBuilder: (context, index) => _Slide(movie: movies[index])
      ),
    );
  }
}

class _Slide extends StatelessWidget {

  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
```

#### Mostrar información en los slides y punticos

- Agregamos el siguiente código en `movies_slideshow.dart`.

```


import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/movie.dart';

class MoviesSlideshow extends StatelessWidget {

  final List<Movie> movies;

  const MoviesSlideshow({
    super.key, 
    required this.movies
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Swiper(
        viewportFraction: 0.8,
        scale: 0.9,
        autoplay: true,
        itemCount: movies.length,
        itemBuilder: (context, index) => _Slide(movie: movies[index])
      ),
    );
  }
}

class _Slide extends StatelessWidget {

  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 10)
        )
      ]
    );

    return Container(
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: DecoratedBox(
          decoration: decoration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              movie.backdropPath,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if ( loadingProgress != null ) {
                  return const DecoratedBox(
                    decoration: BoxDecoration( color: Colors.black12 )
                  );
                }

                return child;
              },
            )
          ),
        ),
      ),
    );
  }
}
```

- Ahora agregamos el paquete de animaciones `animate-do`, en el return del child agregamos `return FadeIn(child: child)`

- Agregamos los punticos y removemos el Container para quitar el color rojo:

```
import 'package:animate_do/animate_do.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/movie.dart';

class MoviesSlideshow extends StatelessWidget {

  final List<Movie> movies;

  const MoviesSlideshow({
    super.key, 
    required this.movies
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Swiper(
        viewportFraction: 0.8,
        scale: 0.9,
        autoplay: true,
        pagination: SwiperPagination(
          margin: const EdgeInsets.only(top: 0),
          builder: DotSwiperPaginationBuilder(
            activeColor: colors.primary,
            color: colors.secondary
          )
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) => _Slide(movie: movies[index])
      ),
    );
  }
}

class _Slide extends StatelessWidget {

  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 10)
        )
      ]
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: DecoratedBox(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            movie.backdropPath,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if ( loadingProgress != null ) {
                return const DecoratedBox(
                  decoration: BoxDecoration( color: Colors.black12 )
                );
              }

              return FadeIn(child: child);
            },
          )
        ),
      ),
    );
  }
}
```

#### Movies Slideshow Provider - Riverpod

- Creamos un nuevo Provider de riverpod para mostar solo 6 piliculas, para eso creamos el archivo `movies_slideshow_provider.dart`, dentro de la carpeta `presentation -> providers -> movies`

- Agregamos el siguiente código:
```
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'movies_providers.dart';

// Provider de solo lectura que va a mostrar solo 6 peliculas en el slideshow
final moviesSlideshowProvider = Provider<List<Movie>>((ref) {

  final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );

  if ( nowPlayingMovies.isEmpty ) return [];

  return nowPlayingMovies.sublist(0, 6);

});
```

- Ahora nos vamos al `home_screen.dart` y llamamos el nuevo provider `moviesSlideshowProvider`

- Agregamos el código:
```
@override
  Widget build(BuildContext context) {

    // final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final slideShowMovies = ref.watch(moviesSlideshowProvider);

    return Column(
      children: [

        const CustomAppbar(),
        MoviesSlideshow(movies: slideShowMovies),

      ]
    );
  }
```

####  - CustomBottomNavigationBar -

- creamos el archivo `custom_bottom_navigationbar.dart`, en la carpeta `presentation -> widgets -> shared` y agregamos el código:

```
import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_max),
          label: 'Inicio'
        ),
         BottomNavigationBarItem(
          icon: Icon(Icons.label_outline),
          label: 'Categorías'
        ),
         BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          label: 'Favoritos'
        )
      ],
    );
  }
}
```

- Y en el `home_screen.dart` usamos el  `CustombottomNavigation`
```
@override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: _HomeView(),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
```

####  - Movie Horizontal ListView -

- Creamos el archivo `movie_horizontal_listview.dart`, en la carpeta `presentation -> widgets -> movies`, y agregamos el código:

```
import 'package:flutter/material.dart';

import '../../../domain/entities/movie.dart';

class MovieHorizontalListview extends StatelessWidget {

  // Propiedades
  final List<Movie> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;

  const MovieHorizontalListview({
    super.key, 
    required this.movies, 
    this.title, 
    this.subTitle, 
    this.loadNextPage
  });

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
```

- Ahora agregamos ese `MovieHorizontalListview` al `home_screen.dart`

```
@override
  Widget build(BuildContext context) {

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final slideShowMovies = ref.watch(moviesSlideshowProvider);

    return Column(
      children: [

        const CustomAppbar(),

        MoviesSlideshow(movies: slideShowMovies),

        MovieHorizontalListview(
          movies: nowPlayingMovies,
          title: 'En Cine',
          subTitle: 'Lunes 20',
        ),
      ]
    );
  }
```

- Ahora vamos a agregar el titulo y subtitulo al `MovieHorizontalListview`, creanndo el widget `_Title`

```
import 'package:flutter/material.dart';
import '../../../domain/entities/movie.dart';

class MovieHorizontalListview extends StatelessWidget {

  // Propiedades
  final List<Movie> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;

  const MovieHorizontalListview({
    super.key, 
    required this.movies, 
    this.title, 
    this.subTitle, 
    this.loadNextPage
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: SizedBox(
        height: 350,
        child: Column(
          children: [

            if ( title != null || subTitle != null )
            _Title(title: title, subTitle: subTitle,)
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {

  final String? title;
  final String? subTitle; 

  const _Title({
    this.title, 
    this.subTitle
  });

  @override
  Widget build(BuildContext context) {

    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      color: Colors.blue,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [

          if ( title !=  null )
            Text(title!, style: titleStyle),

          const Spacer(),

          if ( subTitle !=  null )
            FilledButton(
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              onPressed: (){}, 
              child: Text(subTitle!),
            )
            
        ],
      ),
    );
  }
}
```

####  - Mostrar peliculas en el Movie Horizontal ListView -

- Creamos el widget `_Slide` creamos  `Imagen, Title, Rating`, en el `MovieHorizontalListview`, y removemos los constainer que usamos para el diseño, agregamos el código:

```


import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/movie.dart';

class MovieHorizontalListview extends StatelessWidget {

  // Propiedades
  final List<Movie> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;

  const MovieHorizontalListview({
    super.key, 
    required this.movies, 
    this.title, 
    this.subTitle, 
    this.loadNextPage
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Column(
        children: [

          if ( title != null || subTitle != null )
          _Title(title: title, subTitle: subTitle),

          Expanded(
            child: ListView.builder(
              itemCount: movies.length,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return FadeInRight(child: _Slide( movie: widget.movies[index]));
              },
            )
          )


        ],
      ),
    );
  }
}

// Widget _Slide
class _Slide extends StatelessWidget {

  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;

    return Container(
      // color: Colors.yellow,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // * Imagen
          SizedBox(
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                width: 150,
                loadingBuilder: (context, child, loadingProgress) {
                  
                  if ( loadingProgress != null ) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center( child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }

                  return FadeIn(child: child);
                },
              ),
            ),
          ),

          const SizedBox(height: 5),

          // * Title
          SizedBox(
            width: 150,
            child: Text(
              movie.title,
              maxLines: 2,
              style: textStyles.titleSmall,
            ),
          ),

          // * Rating
          Row(
            children: [
              Icon(Icons.star_half_outlined, color: Colors.yellow.shade800),
              const SizedBox(width: 3),
              Text('${ movie.voteAverage }', style: textStyles.bodyMedium?.copyWith( color: Colors.yellow.shade800)),
              const SizedBox(width: 10),
              Text('${ movie.popularity }', style: textStyles.bodySmall),
            ],
          )
        ],
      ),
    );
  }
}

// Widget _Title
class _Title extends StatelessWidget {

  final String? title;
  final String? subTitle; 

  const _Title({
    this.title, 
    this.subTitle
  });

  @override
  Widget build(BuildContext context) {

    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      // color: Colors.blue,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [

          if ( title !=  null )
            Text(title!, style: titleStyle),

          const Spacer(),

          if ( subTitle !=  null )
            FilledButton(
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              onPressed: (){}, 
              child: Text(subTitle!),
            )
            
        ],
      ),
    );
  }
}
```

####  - HummanFormats - Numeros cortos -
Documentación: https://pub.dev/packages/intl

- Instalamos la libreria `intl`
- Dentro de la carpeta `config` creamos la carpeta `helpers`
- Dentro de la carpeta `helpers`, creo el archivo `human_formats.dart`
- Agregamos el código:
```
import 'package:intl/intl.dart';

class HumanFormats {

  static String number ( double number ) {

    final formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: 0,
      symbol: '',
      locale: 'en'
    ).format(number);

    return formattedNumber;
  }
}
```

- Ahora lo usamos en el Rating, con el siguiente código en el `MovieHorizontalListview`

```
 // * Rating
  SizedBox(
    width: 150,
    child: Row(
      children: [
        Icon(Icons.star_half_outlined, color: Colors.yellow.shade800),
        const SizedBox(width: 3),
        Text('${ movie.voteAverage }', style: textStyles.bodyMedium?.copyWith( color: Colors.yellow.shade800)),
        const Spacer(),
        Text(HumanFormats.number(movie.popularity), style: textStyles.bodySmall),
      ],
    ),
  )
```

####  - InfiniteScroll Horizontal -

- Vamos a cambiar el widget `MovieHorizontalListview` de `StatelessWidget` a `StatefulWidget`, ya que vamos a agregar un listener.

- Agregamos el `initState()`, `dispose()` y el `final scrollController = ScrollController();`

```
// * El controller es como la barrita de youtube, que se puede saber cuando esta en pausa,
  // * cuando se esta al final del video etc.
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if ( widget.loadNextPage == null ) return;

      if ( (scrollController.position.pixels + 200) >= scrollController.position.maxScrollExtent  ) {
        print('Load next movier');

        widget.loadNextPage!();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
```

- Luego asociamos el ListView.Builder con el controller `controller: scrollController, //* Asociamos el controller del ListView al listener`

```
 Expanded(
    child: ListView.builder(
      controller: scrollController, //* Asociamos el controller del ListView al listener
      itemCount: widget.movies.length,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return _Slide( movie: widget.movies[index]);
      },
    )
  )
```

- Y en el `home_screen.dart` agregamos `loadNextPage` :
```
MovieHorizontalListview(
  movies: nowPlayingMovies,
  title: 'En Cine',
  subTitle: 'Lunes 20',
  loadNextPage: () {print('Llamado del padre');},
),
```

####  - Evitar peticiones simultaneas -

- Obtimizamos el archivo `movies_providers.dart`, que se encuentre en la carpeta `presentation -> providers -> movies`

- Agregamos el código:
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
```

####  - SingleChildScrollView y CustomScrollView -

- Para mostrar todas las `MovieHorizontalListview` de populare, proximamente, y mejor calificadas, envolvemos el widget `Column()` en un `SingleChildScrollView` y de esa forma se muestra todos los `MovieHorizontalListview`

- el código queddaria asi:
```
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';


class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: _HomeView(),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}

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

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final slideShowMovies = ref.watch(moviesSlideshowProvider);

    return CustomScrollView(
      slivers: [

        const SliverAppBar(
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Column(
                children: [
            
                  // const CustomAppbar(),
            
                  MoviesSlideshow(movies: slideShowMovies),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'En Cine',
                    subTitle: 'Lunes 20',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'Proximamente',
                    subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'Populares',
                    // subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'Mejor calificadas',
                    subTitle: 'Desde siempre',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),

                  const SizedBox(height: 10),
                ]
              );
            },
            childCount: 1,
          )
        )
      ],
    );
  }
}
```

- Ahora vamos a utilizar el `CustomScrollView` y los `slivers` y el código quedaria asi:

- Quitamos el `const CustomAppbar()` y lo sustituimos por un `SliverAppBar`

```
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';


class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: _HomeView(),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}

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

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final slideShowMovies = ref.watch(moviesSlideshowProvider);

    return CustomScrollView(
      slivers: [

        const SliverAppBar(
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Column(
                children: [
            
                  // const CustomAppbar(),
            
                  MoviesSlideshow(movies: slideShowMovies),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'En Cine',
                    subTitle: 'Lunes 20',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'Proximamente',
                    subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'Populares',
                    // subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'Mejor calificadas',
                    subTitle: 'Desde siempre',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),

                  const SizedBox(height: 10),
                ]
              );
            },
            childCount: 1,
          )
        )
      ],
    );
  }
}
```

####  - Obtener peliculas populares -

- Vamos al archivo `movies_datasource.dart`, que se encuentra en 'domain -> datasources`.
- Agregamos `getPopular`, el código quedaria asi:

```
import '../entities/movie.dart';

abstract class MoviesDatasource {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });
}
```
- Tambien agregamos `getPopular`, en el archivo `movies_repository.dart` que se encuentra en la carpeta `domain -> repositories` y agregamos el sigueinte código:

```
import '../entities/movie.dart';

abstract class MoviesRepository {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });

}
```

- Ahora vamos a resolver el problema en el archivo `moviedb_datasource.dart`, que se encuentra en la carpeta `infrastructure -> datasources`

- Modificamos el archivo con el siguiente código:

```
import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_response.dart';
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

    List<Movie> _jsonToMovies( Map<String, dynamic> json ) {

      final movieDBResponse = MovieDbResponse.fromJson(json);

      // El where => nos ayuda a filtrar si no tenemos imagen del poster, no se crea la movie
      final List<Movie> movies = movieDBResponse.results
      .where((moviedb) => moviedb.posterPath != 'no-poster')
      .map(
        (moviedb) => MovieMapper.movieDBToEntity(moviedb)
      ).toList();

      return movies;  

    }


  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {

    final response = await dio.get('/movie/now_playing',
      queryParameters: {
        'page': page
      }
    );

    return _jsonToMovies(response.data);
  }
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) async {

    final response = await dio.get('/movie/popular',
      queryParameters: {
        'page': page
      }
    );

   return _jsonToMovies(response.data);
  
  }
}
```

- Ahora vamos a resolver el problema en el archivo `movie_repository_impl.dart`, que se encuentra en la carpeta `infrastructure -> repositories`

- Modificamos el archivo con el siguiente código:

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
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) {
    return datasource.getPopular(page: page);
  }

}
```

- Ahora nos vamos al archivo `movies_providers.dart`, que se encuentra en la carpeta `presentation -> providers -> movies` y agregamos el siguiente codigo:

- Copiamos la misma funcion y la sustituimos

```
final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetcMoreMovies = ref.watch( movieRepositoryProvider ).getPopular;
  return MoviesNotifier(
    fetchMoreMovies: fetcMoreMovies
  );
});

```

- Ahora vamos al `home_screen.dart`

- Agregamos el siguiente código:

```
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';


class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: _HomeView(),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}

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
    ref.read( popularMoviesProvider.notifier ).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final slideShowMovies = ref.watch(moviesSlideshowProvider);
    final popularMovies = ref.watch( popularMoviesProvider );

    return CustomScrollView(
      slivers: [

        const SliverAppBar(
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Column(
                children: [
            
                  // const CustomAppbar(),
            
                  MoviesSlideshow(movies: slideShowMovies),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'En Cine',
                    subTitle: 'Lunes 20',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'Proximamente',
                    subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: popularMovies,
                    title: 'Populares',
                    // subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(popularMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'Mejor calificadas',
                    subTitle: 'Desde siempre',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),

                  const SizedBox(height: 10),
                ]
              );
            },
            childCount: 1,
          )
        )
      ],
    );
  }
}
```

####  - Obtener peliculas mejores calificadar y proximamente -

- Vamos al archivo `movies_datasource.dart`, que se encuentra en 'domain -> datasources`.
- Agregamos `getUpcoming` y `getTopRated`, el código quedaria asi:

```
import '../entities/movie.dart';

abstract class MoviesDatasource {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });

  Future<List<Movie>> getUpcoming({ int page = 1 });

  Future<List<Movie>> getTopRated({ int page = 1 });
}
```
- Tambien agregamos `getUpcoming` y `getTopRated`, en el archivo `movies_repository.dart` que se encuentra en la carpeta `domain -> repositories` y agregamos el siguiente código:

```
import '../entities/movie.dart';

abstract class MoviesRepository {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });

  Future<List<Movie>> getUpcoming({ int page = 1 });

  Future<List<Movie>> getTopRated({ int page = 1 });

}
```

- Ahora vamos a resolver el problema en el archivo `moviedb_datasource.dart`, que se encuentra en la carpeta `infrastructure -> datasources`

- Modificamos el archivo con el siguiente código:

```
import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_response.dart';
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

    List<Movie> _jsonToMovies( Map<String, dynamic> json ) {

      final movieDBResponse = MovieDbResponse.fromJson(json);

      // El where => nos ayuda a filtrar si no tenemos imagen del poster, no se crea la movie
      final List<Movie> movies = movieDBResponse.results
      .where((moviedb) => moviedb.posterPath != 'no-poster')
      .map(
        (moviedb) => MovieMapper.movieDBToEntity(moviedb)
      ).toList();

      return movies;  

    }


  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {

    final response = await dio.get('/movie/now_playing',
      queryParameters: {
        'page': page
      }
    );

    return _jsonToMovies(response.data);
  }
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) async {

    final response = await dio.get('/movie/popular',
      queryParameters: {
        'page': page
      }
    );

   return _jsonToMovies(response.data);
  
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
   final response = await dio.get('/movie/top_rated',
      queryParameters: {
        'page': page
      }
    );

   return _jsonToMovies(response.data);
  }
  
  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final response = await dio.get('/movie/upcoming',
      queryParameters: {
        'page': page
      }
    );

   return _jsonToMovies(response.data);
  }
}
```

- Ahora vamos a resolver el problema en el archivo `movie_repository_impl.dart`, que se encuentra en la carpeta `infrastructure -> repositories`

- Modificamos el archivo con el siguiente código:

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
  
  @override
  Future<List<Movie>> getPopular({int page = 1}) {
    return datasource.getPopular(page: page);
  }

   @override
  Future<List<Movie>> getTopRated({int page = 1}) {
    return datasource.getTopRated(page: page);
  }
  
  @override
  Future<List<Movie>> getUpcoming({int page = 1}) {
    return datasource.getUpcoming(page: page);
  }

}
```

- Ahora nos vamos al archivo `movies_providers.dart`, que se encuentra en la carpeta `presentation -> providers -> movies` y agregamos el siguiente codigo:

- Copiamos la misma funcion y la sustituimos

```
final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetcMoreMovies = ref.watch( movieRepositoryProvider ).getPopular;
  return MoviesNotifier(
    fetchMoreMovies: fetcMoreMovies
  );
});

final topRatedMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetcMoreMovies = ref.watch( movieRepositoryProvider ).getTopRated;
  return MoviesNotifier(
    fetchMoreMovies: fetcMoreMovies
  );
});

final upcomingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetcMoreMovies = ref.watch( movieRepositoryProvider ).getUpcoming;
  return MoviesNotifier(
    fetchMoreMovies: fetcMoreMovies
  );
});

```

- Ahora vamos al `home_screen.dart`

- Agregamos el siguiente código:

```
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';


class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: _HomeView(),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}

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
    ref.read( popularMoviesProvider.notifier ).loadNextPage();
    ref.read( topRatedMoviesProvider.notifier ).loadNextPage();
    ref.read( upcomingMoviesProvider.notifier ).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final slideShowMovies = ref.watch(moviesSlideshowProvider);
    final popularMovies = ref.watch( popularMoviesProvider );
    final topRatedMovies = ref.watch( topRatedMoviesProvider );
    final upcomingMovies = ref.watch( upcomingMoviesProvider );

    return CustomScrollView(
      slivers: [

        const SliverAppBar(
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Column(
                children: [
            
                  // const CustomAppbar(),
            
                  MoviesSlideshow(movies: slideShowMovies),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'En Cine',
                    subTitle: 'Lunes 20',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: upcomingMovies,
                    title: 'Proximamente',
                    subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(upcomingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: popularMovies,
                    title: 'Populares',
                    // subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(popularMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: topRatedMovies,
                    title: 'Mejor calificadas',
                    subTitle: 'Desde siempre',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(topRatedMoviesProvider.notifier).loadNextPage();
                    },
                  ),

                  const SizedBox(height: 10),
                ]
              );
            },
            childCount: 1,
          )
        )
      ],
    );
  }
}
```

####  - FullScreenLoader -

- Creamos el archivo `full_screen_loader.dart`, en la carpeta `presentation -> widgets ->shared`

- Agregamos el siguiente código:

```
import 'package:flutter/material.dart';

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key});

  Stream<String> getLoadingMessages() {

    final messages = <String>[
      'Cargando películas',
      'Comprando palomitas de Maiz',
      'Cargando populares',
      'Llamando a Carola',
      'Ya casi...',
      'Esto está tardando más de lo esperado :(',
    ];

    return Stream.periodic( const Duration(milliseconds: 1200), (step) {
      return messages[step];
    }).take(messages.length);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Espere por favor'),
          const SizedBox(height: 10),
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 10),

          StreamBuilder(
            stream: getLoadingMessages(),
            builder: (context, snapshot) {
              if ( !snapshot.hasData) return const Text('Cargando...');

              return Text( snapshot.data! );
            },
          )
        ],
      ),
    );
  }
}
```

####  - Escuchar multiples provider simultáneamente -

- Se crea el archivo `initial_loading_provider.dart`, en la carpeta `presentation -> providers -> movies`.

- Se agrega el siguiente código:

```
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

final initialLoadingProvider = Provider<bool>((ref) {

  final step1 = ref.watch(moviesSlideshowProvider).isEmpty;
  final step2 = ref.watch( popularMoviesProvider ).isEmpty;
  final step3 = ref.watch( topRatedMoviesProvider ).isEmpty;
  final step4 = ref.watch( upcomingMoviesProvider ).isEmpty;

  if ( step1 || step2 || step3 || step4 ) return true;
  
  return false; // terminamos de cargar

});
```

- En el `home_screen.dart` agregamos `initialLoadingProvider` y el siguiente código:

```
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';


class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: _HomeView(),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}

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
    ref.read( popularMoviesProvider.notifier ).loadNextPage();
    ref.read( topRatedMoviesProvider.notifier ).loadNextPage();
    ref.read( upcomingMoviesProvider.notifier ).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {

    final initialLoading = ref.watch( initialLoadingProvider );
    if ( initialLoading ) return const FullScreenLoader();

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final slideShowMovies = ref.watch(moviesSlideshowProvider);
    final popularMovies = ref.watch( popularMoviesProvider );
    final topRatedMovies = ref.watch( topRatedMoviesProvider );
    final upcomingMovies = ref.watch( upcomingMoviesProvider );

    return CustomScrollView(
      slivers: [

        const SliverAppBar(
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: CustomAppbar(),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Column(
                children: [
            
                  // const CustomAppbar(),
            
                  MoviesSlideshow(movies: slideShowMovies),
            
                  MovieHorizontalListview(
                    movies: nowPlayingMovies,
                    title: 'En Cine',
                    subTitle: 'Lunes 20',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(nowPlayingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: upcomingMovies,
                    title: 'Proximamente',
                    subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(upcomingMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: popularMovies,
                    title: 'Populares',
                    // subTitle: 'En este mes',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(popularMoviesProvider.notifier).loadNextPage();
                    },
                  ),
            
                  MovieHorizontalListview(
                    movies: topRatedMovies,
                    title: 'Mejor calificadas',
                    subTitle: 'Desde siempre',
                    loadNextPage: () {
                      // * el .read se usa dentro de funciones o callback
                      ref.read(topRatedMoviesProvider.notifier).loadNextPage();
                    },
                  ),

                  const SizedBox(height: 10),
                ]
              );
            },
            childCount: 1,
          )
        )
      ],
    );
  }
}
```

