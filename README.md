# cinemapedia

A new Flutter project.

## Dev

1. Copiar el .env.template y renombrarlo a .env
2. Cambiar las variables de entorno (The MovieDB)
3. Cambios en la entidad, hay que ejecutar el comando
```
flutter pub run build_runner build
```


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

### Peliculas Individuales y Actores:

#### Navegar a otra pantalla con parametros

- Creamos un nnuevo archivo `movie_screen.dart`, en la carpeta `presentattion -> screens -> movies`

```
import 'package:flutter/material.dart';

class MovieScreen extends StatelessWidget {

  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({
    super.key, 
    required this.movieId
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MovieId: $movieId'),
      ),
    );
  }
}
```

- en el archivo `app_router.dart`, que se encuentra en la carpeta `config -> router`, agregamos un nuevo `Go_Route`.

- El `id` que recibo siempre va a hacer string, para obtener el id usamos el `final movieId = state.params['id'] ?? 'no-id';`, los `querys parameters y los segmentos de url` siempre van a hacer string.

```
GoRoute(
  path: '/movie/:id',
  name: MovieScreen.name,
  builder: (context, state) {
    final movieId = state.params['id'] ?? 'no-id';
    return MovieScreen(movieId: movieId);
  },
),
```

- Ahora abrimos el archivo `movie_horizontal_listview.dart` y buscamos en donde tenemos las imagenes para que al tocar la imagen nos lleve a la siguiente pantalla y le pasamos el movieId como parametro, para hacer eso agregamos el `GestureDetector` el siguiente código:

```
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

        return GestureDetector(
          onTap: () => context.push('/movie/${ movie.id }'),
          child: FadeIn(child: child),
        );
        
      },
    ),
  ),
),
```

- Ahora necitamos configurar el archiv `app_router.dart`, ya que si vamos a usar deep linking, para navegar a otra pantalla y compartir el link, no queremos que desaparezca el boton del back para regresar al home, para ellos realizamos los siguientes cambios:

- Al la ruta principal que es el `home_screen`, le definimos los `routes`, que son conicidos como rutas hijas y agregamos la ruta del `movie/:id` , el código seria asi:

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
      routes: [
        GoRoute(
          path: 'movie/:id',
          name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.params['id'] ?? 'no-id';
            return MovieScreen(movieId: movieId);
          },
        ),
      ]
    ),
  ]
);
```
#### Obtener películas por ID - Datasource

- Abrimos el archivo `movies_datasource.dart`, que se encuentra en la carpeta `domain -> datasources` y agregamos un nuevo Future `getMovieById`.

```
import '../entities/movie.dart';

abstract class MoviesDatasource {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });

  Future<List<Movie>> getUpcoming({ int page = 1 });

  Future<List<Movie>> getTopRated({ int page = 1 });

  Future<Movie> getMovieById( String id );

}
```

- Tambien lo agregamos en el archivo `movies_repository.dart`, que se encuentra en la carpeta `domain -> repositories`

```
import '../entities/movie.dart';

abstract class MoviesRepository {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });

  Future<List<Movie>> getUpcoming({ int page = 1 });

  Future<List<Movie>> getTopRated({ int page = 1 });

  Future<Movie> getMovieById( String id );
}
```

- Ahora nos vamos al archivo `moviedb_datasource,dart`, que se encuentra en la carpeta `infrastructure -> datasources` y ahi es  donde vamos a hacer la implementación, agregamos el nuevo metodo `getMovieById`, por el momento no esta completo, falta crear la entity

```
@override
Future<Movie> getMovieById(String id) async {
  final response = await dio.get('movie/$id');

  return;
}
```

- Ahora nos vamos a `quicktype.io`, para generar tener el `MovieDetail` del api, pegamos la respuesta en el archivo `movie_details.dart`, que se encuentra en la carpeta `infrastructure -> models -> moviedb`

```
class MovieDetails {
    MovieDetails({
        required this.adult,
        required this.backdropPath,
        required this.belongsToCollection,
        required this.budget,
        required this.genres,
        required this.homepage,
        required this.id,
        required this.imdbId,
        required this.originalLanguage,
        required this.originalTitle,
        required this.overview,
        required this.popularity,
        required this.posterPath,
        required this.productionCompanies,
        required this.productionCountries,
        required this.releaseDate,
        required this.revenue,
        required this.runtime,
        required this.spokenLanguages,
        required this.status,
        required this.tagline,
        required this.title,
        required this.video,
        required this.voteAverage,
        required this.voteCount,
    });

    final bool adult;
    final String backdropPath;
    final BelongsToCollection? belongsToCollection;
    final int budget;
    final List<Genre> genres;
    final String homepage;
    final int id;
    final String imdbId;
    final String originalLanguage;
    final String originalTitle;
    final String overview;
    final double popularity;
    final String posterPath;
    final List<ProductionCompany> productionCompanies;
    final List<ProductionCountry> productionCountries;
    final DateTime releaseDate;
    final int revenue;
    final int runtime;
    final List<SpokenLanguage> spokenLanguages;
    final String status;
    final String tagline;
    final String title;
    final bool video;
    final double voteAverage;
    final int voteCount;

    factory MovieDetails.fromJson(Map<String, dynamic> json) => MovieDetails(
        adult: json["adult"],
        backdropPath: json["backdrop_path"] ?? '',
        belongsToCollection: json["belongs_to_collection"] == null ? null : BelongsToCollection.fromJson(json["belongs_to_collection"]),
        budget: json["budget"],
        genres: List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
        homepage: json["homepage"],
        id: json["id"],
        imdbId: json["imdb_id"],
        originalLanguage: json["original_language"],
        originalTitle: json["original_title"],
        overview: json["overview"],
        popularity: json["popularity"]?.toDouble(),
        posterPath: json["poster_path"],
        productionCompanies: List<ProductionCompany>.from(json["production_companies"].map((x) => ProductionCompany.fromJson(x))),
        productionCountries: List<ProductionCountry>.from(json["production_countries"].map((x) => ProductionCountry.fromJson(x))),
        releaseDate: DateTime.parse(json["release_date"]),
        revenue: json["revenue"],
        runtime: json["runtime"],
        spokenLanguages: List<SpokenLanguage>.from(json["spoken_languages"].map((x) => SpokenLanguage.fromJson(x))),
        status: json["status"],
        tagline: json["tagline"],
        title: json["title"],
        video: json["video"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
    );

    Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "belongs_to_collection": belongsToCollection?.toJson(),
        "budget": budget,
        "genres": List<dynamic>.from(genres.map((x) => x.toJson())),
        "homepage": homepage,
        "id": id,
        "imdb_id": imdbId,
        "original_language": originalLanguage,
        "original_title": originalTitle,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "production_companies": List<dynamic>.from(productionCompanies.map((x) => x.toJson())),
        "production_countries": List<dynamic>.from(productionCountries.map((x) => x.toJson())),
        "release_date": "${releaseDate.year.toString().padLeft(4, '0')}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}",
        "revenue": revenue,
        "runtime": runtime,
        "spoken_languages": List<dynamic>.from(spokenLanguages.map((x) => x.toJson())),
        "status": status,
        "tagline": tagline,
        "title": title,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
    };
}

class BelongsToCollection {
    BelongsToCollection({
        required this.id,
        required this.name,
        required this.posterPath,
        required this.backdropPath,
    });

    final int id;
    final String name;
    final String posterPath;
    final String backdropPath;

    factory BelongsToCollection.fromJson(Map<String, dynamic> json) => BelongsToCollection(
        id: json["id"],
        name: json["name"],
        posterPath: json["poster_path"],
        backdropPath: json["backdrop_path"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "poster_path": posterPath,
        "backdrop_path": backdropPath,
    };
}

class Genre {
    Genre({
        required this.id,
        required this.name,
    });

    final int id;
    final String name;

    factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class ProductionCompany {
    ProductionCompany({
        required this.id,
        this.logoPath,
        required this.name,
        required this.originCountry,
    });

    final int id;
    final String? logoPath;
    final String name;
    final String originCountry;

    factory ProductionCompany.fromJson(Map<String, dynamic> json) => ProductionCompany(
        id: json["id"],
        logoPath: json["logo_path"],
        name: json["name"],
        originCountry: json["origin_country"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "logo_path": logoPath,
        "name": name,
        "origin_country": originCountry,
    };
}

class ProductionCountry {
    ProductionCountry({
        required this.iso31661,
        required this.name,
    });

    final String iso31661;
    final String name;

    factory ProductionCountry.fromJson(Map<String, dynamic> json) => ProductionCountry(
        iso31661: json["iso_3166_1"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "iso_3166_1": iso31661,
        "name": name,
    };
}

class SpokenLanguage {
    SpokenLanguage({
        required this.englishName,
        required this.iso6391,
        required this.name,
    });

    final String englishName;
    final String iso6391;
    final String name;

    factory SpokenLanguage.fromJson(Map<String, dynamic> json) => SpokenLanguage(
        englishName: json["english_name"],
        iso6391: json["iso_639_1"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "english_name": englishName,
        "iso_639_1": iso6391,
        "name": name,
    };
}

```

- Necesitamos crea un nuevo `Mapper`, en el archivo `movie_mapper.dart`, que se encuentra en la carpeta `infrastructure -> mappers`, y colocamos el siguiente código:

```
static Movie movieDetailsToEntity(MovieDetails moviedb) => 
  Movie(
    adult: moviedb.adult,
      backdropPath: (moviedb.backdropPath != '')
        ? 'https://image.tmdb.org/t/p/w500/${ moviedb.backdropPath }'
        : 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
      genreIds: moviedb.genres.map((e) => e.name).toList(),
      id: moviedb.id,
      originalLanguage: moviedb.originalLanguage,
      originalTitle: moviedb.originalTitle,
      overview: moviedb.overview,
      popularity: moviedb.popularity,
      posterPath: (moviedb.posterPath != '')
         ? 'https://image.tmdb.org/t/p/w500/${ moviedb.posterPath }'
        : 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
      releaseDate: moviedb.releaseDate,
      title: moviedb.title,
      video: moviedb.video,
      voteAverage: moviedb.voteAverage,
      voteCount: moviedb.voteCount
  );
```

- Ahora nos vamos al archivo `moviedb_datasource,dart`, que se encuentra en la carpeta `infrastructure -> datasource,dart` y agregamos el sigueinte código:

```
@override
Future<Movie> getMovieById(String id) async {
  final response = await dio.get('/movie/$id');
  if ( response.statusCode != 200 ) throw Exception('Movie with id: $id not found ');

  final movieDetails = MovieDetails.fromJson(response.data);
  final Movie movie = MovieMapper.movieDetailsToEntity(movieDetails);
  return movie;
}
```

- Ahora agregamos el metodo que le falta al repository en el archivo `movie_repository_impl.dart`, que se encuentra en la carpeta `infrastructure -> repositories`.

```
@override
Future<Movie> getMovieById(String id) {
  return datasource.getMovieById(id);
}
```

- Vamos a agregar un nuevo provider para que llame las implementaciones y tener un cache local para que no se vuelva a disparar una petición si ya antes la hice.

- Creamos el archivo `movie_info_provider.dart`, en la carpeta `presentation -> providers -> movies`
- Colocamos el siguiente código:

```

import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/movie.dart';

// * Crear el provider
final movieInfoProvider = StateNotifierProvider<MovieMapNotifier, Map<String, Movie>>((ref) {
  final movieRepository = ref.watch( movieRepositoryProvider );
  return MovieMapNotifier(getMovie: movieRepository.getMovieById);
});

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
```

#### Realizar petición HTTP y probar cache

- Ahora no vamos al archivo `movie_screen.dart`, que se encuentra en la carpeta `presentation -> screens -> movies`, y transformamos el `StatelessWidget` por un `StatefulWidget`

- Ahora cambiamos el `StatelessWidget` por un `ConsumerStatefulWidget` y otros cambios.

- Agregamos el código:

```
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';

class MovieScreen extends ConsumerStatefulWidget {

  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({
    super.key, 
    required this.movieId
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {

  @override
  void initState() {
    super.initState();

    // * Si estamos dentro del initState, metodos, callback, onTap, onPress etc.
    // * se usa el ref.read()
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);

  }

  @override
  Widget build(BuildContext context) {

    final Movie? movie = ref.watch( movieInfoProvider )[widget.movieId];

    if ( movie == null ) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('MovieId: ${widget.movieId}'),
      ),
    );
  }
}
```

#### Diseño de pantalla películas

- Vamos a utilizar `CustomScrollView` para trabajar con `slivers` en el archivo `movie_screen.dart`

- En el `_CustomSliverAppBar, `vamos a agregar la imagen, gradientes para el titulo y la flechita del back 

```
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';

class MovieScreen extends ConsumerStatefulWidget {

  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({
    super.key, 
    required this.movieId
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {

  @override
  void initState() {
    super.initState();

    // * Si estamos dentro del initState, metodos, callback, onTap, onPress etc.
    // * se usa el ref.read()
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);

  }

  @override
  Widget build(BuildContext context) {

    final Movie? movie = ref.watch( movieInfoProvider )[widget.movieId];

    if ( movie == null ) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(), // evita el rebote del scrollView
        slivers: [
          _CustomSliverAppBar(movie: movie)
        ],
      ),
    );
  }
}

class _CustomSliverAppBar extends StatelessWidget {

  final Movie movie;

  const _CustomSliverAppBar({
    required this.movie
  });

  @override
  Widget build(BuildContext context) {

    // * Tengo las dimensiones del dispositivo fisico conel MediaQuery
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      shadowColor: Colors.red,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        title: Text(
          movie.title,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.start,
        ),
        background: Stack(
          children: [

            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
              ),
            ),

            // * Aplicar gradientes para fondos claros de la imagen
            const SizedBox.expand(
              child: DecoratedBox(

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.7, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black87
                    ]
                  ),
                )
              ),
            ),

            // * Aplicar gradientes para la flechita del back
            const SizedBox.expand(
              child: DecoratedBox(

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    stops: [0.0, 0.3],
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ]
                  ),
                )
              ),
            ),

          ],
        ),
      ),
    );
  }
}
```

#### Descripción de la película

- Vamos a agregar el `SliverList` y el widget `_MovieDetails`

- Agregamos el llamado del widget `_MovieDetails`

```
 return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(), // evita el rebote del scrollView
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(delegate: SliverChildBuilderDelegate(
            (context, index) => _MovieDetails(movie: movie),
            childCount: 1
          ))
        ],
      ),
    );
```

- Y agregamos el codigo del widget `_MovieDetails`, falta agregar los actores, pero ya se muestra el titulo y descripción, generos e imagen del poster

```
class _MovieDetails extends StatelessWidget {

  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding:  const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // * Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                ),
              ),

              const SizedBox( width: 10 ),

              // * Titulo y Descripción
              SizedBox(
                width: (size.width - 40) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( movie.title, style: textStyle.titleLarge ),
                    Text( movie.overview ),
                  ],
                ),
              )
            ],
          ),
        ),

        // * Generos de la película
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map((gender) => Container(
                margin: const EdgeInsets.only(right: 10),
                child: Chip(
                  label: Text(gender),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ))
            ],
          ),
        ),

        // TODO: Mostrar actores

        const SizedBox(height: 100)
      ],
    );
  }
}
```

#### Actore de película

- Creamos una nueva entidad `actor.dart` en la carpeta `domain -> entities`

```
class Actor {

  final int id;
  final String name;
  final String profilePath;
  final String? character;

  Actor({
    required this.id, 
    required this.name, 
    required this.profilePath, 
    required this.character,
  });

}
```

- Creamos un nuevo datasource de `actors` en la carpeta `domain -> datasources`, llamado `actors_datasource.dart`

```
// * Definimos las reglas que necesito para trabajar este datasource
import '../entities/actor.dart';

abstract class ActorsDatasource {

  Future<List<Actor>> getActorsByMovie( String movieId );
}
```

- Creamos un nuevo repository de `actors` en la carpeta `domain -> repositories`, llamado `actors_repository.dart`

```
import '../entities/actor.dart';

abstract class ActorsRepository {
  
  Future<List<Actor>> getActorsByMovies( String movieId );
}
```

- creamos el nuevo modelo vamos al postman y compiamos le respuesta del endpoint `GET https://api.themoviedb.org/3/movie/505642/credits` y la copiamos en `quiecktype.io` y le colocamos el nombre de `CreditsResponse` y los colocamos en el archivo `credits_response.dart`, en la carpeta `infrastructure -> models -> moviedb`

```
class CreditsResponse {
    CreditsResponse({
        required this.id,
        required this.cast,
        required this.crew,
    });

    final int id;
    final List<Cast> cast;
    final List<Cast> crew;

    factory CreditsResponse.fromJson(Map<String, dynamic> json) => CreditsResponse(
        id: json["id"],
        cast: List<Cast>.from(json["cast"].map((x) => Cast.fromJson(x))),
        crew: List<Cast>.from(json["crew"].map((x) => Cast.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "cast": List<dynamic>.from(cast.map((x) => x.toJson())),
        "crew": List<dynamic>.from(crew.map((x) => x.toJson())),
    };
}

class Cast {
    Cast({
        required this.adult,
        required this.gender,
        required this.id,
        required this.knownForDepartment,
        required this.name,
        required this.originalName,
        required this.popularity,
        this.profilePath,
        this.castId,
        this.character,
        required this.creditId,
        this.order,
        this.department,
        this.job,
    });

    final bool adult;
    final int gender;
    final int id;
    final String knownForDepartment;
    final String name;
    final String originalName;
    final double popularity;
    final String? profilePath;
    final int? castId;
    final String? character;
    final String creditId;
    final int? order;
    final String? department;
    final String? job;

    factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        adult: json["adult"],
        gender: json["gender"],
        id: json["id"],
        knownForDepartment: json["known_for_department"],
        name: json["name"],
        originalName: json["original_name"],
        popularity: json["popularity"]?.toDouble(),
        profilePath: json["profile_path"],
        castId: json["cast_id"],
        character: json["character"],
        creditId: json["credit_id"],
        order: json["order"],
        department: json["department"],
        job: json["job"],
    );

    Map<String, dynamic> toJson() => {
        "adult": adult,
        "gender": gender,
        "id": id,
        "known_for_department": knownForDepartment,
        "name": name,
        "original_name": originalName,
        "popularity": popularity,
        "profile_path": profilePath,
        "cast_id": castId,
        "character": character,
        "credit_id": creditId,
        "order": order,
        "department": department,
        "job": job,
    };
}


```

- Necesitamos crear el mapper, `actor_mapper.dart`, en la carpeta `infrastructure -> mappers`

```
import '../../domain/entities/actor.dart';
import '../models/moviedb/credits_response.dart';

class ActorMapper {

  static Actor castToEntity( Cast cast) => 
  Actor(
    id: cast.id, 
    character: cast.character, 
    name: cast.name, 
    profilePath: cast.profilePath != null
      ? 'https://image.tmdb.org/t/p/w500/${ cast.profilePath }'
      : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTC0HlQ_ckX6HqCAlqroocyRDx_ZRu3x3ezoA&usqp=CAU'

  );
}
```

- Creamos la implementacion del datasource `actor_moviedb_datasource.dart`, en la carpeta `infrastructure -> datasources`

```

import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/infrastructure/mappers/actor_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';
import 'package:dio/dio.dart';

import '../../config/constants/environment.dart';

class ActorMovieDbDatasource extends ActorsDatasource {

  // Propiedades de la clase MoviedbDatasource
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      queryParameters: {
        'api_key': Environment.theMovieDbKey,
        'language': 'es-ES' // es-MX
      }
    ));

  @override
  Future<List<Actor>> getActorsByMovie(String movieId) async {

    final response = await dio.get('/movie/$movieId/credits');

    final castResponse = CreditsResponse.fromJson(response.data);

    List<Actor> actors = castResponse.cast.map(
      (cast) => ActorMapper.castToEntity(cast)
    ).toList();

    return actors;

  }

}

```

- Creamos el archivo `actors_repository_provider.dart`, en la carpeta `presentation -> providers -> actors`

```
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/datasources/actor_moviedb_datasource.dart';
import '../../../infrastructure/repositories/actor_repository_impl.dart';

final actorsRepositoryProvider = Provider((ref) {
  return ActorRepositoryImpl(ActorMovieDbDatasource()); 
});
```

#### Creamos la implementacion del Repositorio y Prpvider

- Creamos el archivo `actor_repository_impl.dart`, en la carpeta `infrastructure -> repositories`.

```
import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/repositories/actors_repository.dart';

class ActorRepositoryImpl extends ActorsRepository  {

  final ActorsDatasource datasource;

  ActorRepositoryImpl(this.datasource);

  @override
  Future<List<Actor>> getActorsByMovies(String movieId) {
    return datasource.getActorsByMovie(movieId);
  }
}
```

- Creamos el nuevo Providers `actors_by_movie_provider.dart`, en la carpeta `presentation -> providers -> actors`

```
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
```

#### Probar la obtención de Actores

- Agregamos en el `movie_screen.dart` lo siguiente

```
 @override
  void initState() {
    super.initState();

    // * Si estamos dentro del initState, metodos, callback, onTap, onPress etc.
    // * se usa el ref.read()
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);

    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);

  }
```

#### Mostrar Actores en pantalla diseño

- Agregamoe le código en el archivo `movie_screen.dart`

```
import 'package:cinemapedia/presentation/providers/movies/movie_info_provider.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';

class MovieScreen extends ConsumerStatefulWidget {

  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({
    super.key, 
    required this.movieId
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {

  @override
  void initState() {
    super.initState();

    // * Si estamos dentro del initState, metodos, callback, onTap, onPress etc.
    // * se usa el ref.read()
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);

    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);

  }

  @override
  Widget build(BuildContext context) {

    final Movie? movie = ref.watch( movieInfoProvider )[widget.movieId];

    if ( movie == null ) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(), // evita el rebote del scrollView
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(delegate: SliverChildBuilderDelegate(
            (context, index) => _MovieDetails(movie: movie),
            childCount: 1
          ))
        ],
      ),
    );
  }
}

class _CustomSliverAppBar extends StatelessWidget {

  final Movie movie;

  const _CustomSliverAppBar({
    required this.movie
  });

  @override
  Widget build(BuildContext context) {

    // * Tengo las dimensiones del dispositivo fisico conel MediaQuery
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      shadowColor: Colors.red,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [

            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
              ),
            ),

            // * Aplicar gradientes para fondos claros de la imagen
            const SizedBox.expand(
              child: DecoratedBox(

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.7, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black87
                    ]
                  ),
                )
              ),
            ),

            // * Aplicar gradientes para la flechita del back
            const SizedBox.expand(
              child: DecoratedBox(

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    stops: [0.0, 0.3],
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ]
                  ),
                )
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _MovieDetails extends StatelessWidget {

  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding:  const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // * Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  movie.posterPath,
                  width: size.width * 0.3,
                ),
              ),

              const SizedBox( width: 10 ),

              // * Titulo y Descripción
              SizedBox(
                width: (size.width - 40) * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( movie.title, style: textStyle.titleLarge ),
                    Text( movie.overview ),
                  ],
                ),
              )
            ],
          ),
        ),

        // * Generos de la película
        // * Se podria cambiar el widget Chip por un button
        // * y al darle click al genero llamar al endpoint
        // * Get movie/{movie_id}/similar
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map((gender) => Container(
                margin: const EdgeInsets.only(right: 10),
                child: Chip(
                  label: Text(gender),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ))
            ],
          ),
        ),

        // * Mostrar Actores
        _ActorByMovie(movieId: movie.id.toString(),),

        const SizedBox(height: 50)
      ],
    );
  }
}

class _ActorByMovie extends ConsumerWidget {

  final String movieId; 

  const _ActorByMovie({required this.movieId});

  @override
  Widget build(BuildContext context, ref) {

    final actorsByMovie = ref.watch( actorsByMovieProvider );

    if ( actorsByMovie[movieId] == null ) {
      return const CircularProgressIndicator(strokeWidth: 2);
    }

    final actors = actorsByMovie[movieId]!;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];

          return Container(
            padding: const EdgeInsets.all(8.0),
            width: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // * Actor photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    actor.profilePath,
                    height: 180,
                    width: 135,
                    fit: BoxFit.cover,
                  ),
                ),

                // * Nombre
                const SizedBox(height: 5),

                Text(actor.name, maxLines: 2),
                Text(
                  actor.character ?? '', 
                  maxLines: 2,
                  style: const TextStyle( fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                )
              ],
            ),
          );
        },
      ),
    );

    return const Placeholder();
  }
}
```

#### Detalles esteticos

- Agregamos el `FadeIn` en la imagen, en el archivo `movie_screen`, en el `_CustomSliverAppBar`

```
// * Imagen
SizedBox.expand(
  child: Image.network(
    movie.posterPath,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if ( loadingProgress != null ) return const SizedBox();
      return FadeIn(child: child);
    },
  ),
),
```

- Agregamos un `FadeInRight` en la imagen de actor en el archivo `movie_screen`, en el `_ActorByMovie`

```
// * Actor photo
FadeInRight(
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.network(
      actor.profilePath,
      height: 180,
      width: 135,
      fit: BoxFit.cover,
    ),
  ),
),

```

### SearchDelegate - Busquedas

#### Datasource y Repository - SearchMovies

- Vamos a la carpeta `domain -> datasources`, abrimos el archivo `movies_datasources.dart` y agregamos el `searchMovies`

```
Future<List<Movie>> searchMovies( String query );
```

- Vamos a la carpeta `domain -> repositories`, abrimos el archivo `movies_repository.dart` y agregamos el `searchMovies`

```
Future<List<Movie>> searchMovies( String query );
```

- Ahora vamos a hacer la implementación de la busqueda en el datasources, para eso vamos al archivo `moviedb_datasoruce.dart`, en la carpeta `infrastructure -> datasources`.

```
@override
Future<List<Movie>> searchMovies(String query) async {
  
  if( query.isEmpty) return [];

  final response = await dio.get('/search/movie',
    queryParameters: {
      'query': query
    }
  );

  return _jsonToMovies(response.data);
}
```

- Vamos a hacer la implementación de la busqueda en el repositories, para eso vamos al archivo `movie_repository_impl.dart`, en la carpeta `infrastructure -> repositories`.

```
@override
Future<List<Movie>> searchMovies(String query) {
  return datasource.searchMovies(query);
}
```

#### SearchDelegate

- Vamos al archivo `custom_appbar.dart`, que se encuentra en la carpeta `presentation -> widgets -> shared`, ahi buscamos el icono de la lupita y en el `onPressed` agregamos lo siguiente:
```
onPressed: (){
  showSearch(
    context: context, 
    delegate: delegate
  );
}, 
```

- El delegate es el encargado de trabajar la busqueda y creamos una carpeta llamada `delegates`, en `presentation` y creamos el archivo `search_movie_delegate.dart`.

- Agregamos el siguiente código, para saber como funcionan cada una de sus metodos de la clase  `SearchMovieDelegate`

```
import 'package:flutter/material.dart';

class SearchMovieDelegate extends SearchDelegate {

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      const Text('buildActions')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return const Text('buildLeading');
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Text('buildSuggestions');
  }

}
```

- Ahora agregamos `SearchMovieDelegate` a la función `onPress`, en el archivo `custom_appbar.dart`

```
 IconButton(
  onPressed: (){
    showSearch(
      context: context, 
      delegate: SearchMovieDelegate()
    );
  }, 
  icon: const Icon(Icons.search)
)
```

- Ahora gregamos un  nuevo metodo en el `search_movie_deletage.dart`, para sustituir la palabre `Search`, por `Buscar película`

```
@override
  String get searchFieldLabel => 'Buscar película';
```

#### Leading y Actions SerchDelegate

- El buildLeading sirve para salir de la busqueda
- El buildActions sirve para borrar el dato que ingresamos para realizar la busqueda
- Tambien el `SearchDelegate` va a regresar una `Movie` opcional

```
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';

class SearchMovieDelegate extends SearchDelegate<Movie?> {

  @override
  String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [

      FadeIn(
        animate: query.isNotEmpty,
        child: IconButton(
          onPressed: () => query = '', 
          icon: const Icon(Icons.clear)
        ),
      ),


    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null), 
      icon: const Icon(Icons.arrow_back_ios_new_rounded)
    )
    ;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Text('buildSuggestions');
  }

}
```

#### Construir Sugerencias - Petición Http

- En el archivo `search_movie_delegate.dart`, agregamos un tipo de funcion que me va a permitir buscar las peliculas, agrego esa nueva propiedad y creo el constructor

```
// * Definir un tipo de función para hacer el searchMovie
// * que traiga una lista de movies
typedef SearchMoviesCallback = Future<List<Movie>> Function( String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {

  final SearchMoviesCallback searchMovies;

  SearchMovieDelegate({
    required this.searchMovies
  });

......
}
```

- Ahora en el archivo `custom_appbar`, da error por que tenemos que agregar el parametro a la funcion `SearchMovieDelegate`, pero tenemos que cambiar el `StatelessWidget` por `ConsumerWidget`, para tener acceso al `Widget ref`

```
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/presentation/delegates/search_movie_delegate.dart';
import '../../providers/movies/movies_repository_provider.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

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
                onPressed: (){

                  final movieRepository = ref.read(movieRepositoryProvider);

                  showSearch(
                    context: context, 
                    delegate: SearchMovieDelegate(
                      searchMovies: movieRepository.searchMovies
                    )
                  );
                }, 
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

- Ahora regresamos al archivo `search_movie_delegate.dart`, en la función de `buildSuggestions`, agregamos el siguiente código:

```
@override
Widget buildSuggestions(BuildContext context) {

  return FutureBuilder(
    future: searchMovies(query),
    builder: (context, snapshot) {

      final movies = snapshot.data ?? [];

      return ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return ListTile(
            title: Text( movie.title ),
          );
        },
      );
    },
  );
}
```

#### Mostrar las Películas en la busqueda

- En el archivo `search_movie_delegate.dart`, creamos el widget `_MovieItem`, para mostrar la foto, titulo y descripción de las peliculas usando el siguiente código:

```
class _MovieItem extends StatelessWidget {

  final Movie movie;

  const _MovieItem({
    required this.movie
  });

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [

          // * Image
          SizedBox(
            width: size.width * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                movie.posterPath,
                loadingBuilder: (context, child, loadingProgress) => FadeIn(child: child),
              ),
            ),
          ),

          const SizedBox( width: 10),

          // * Description
          SizedBox(
            width: size.width * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( movie.title, style: textStyles.titleMedium),

                (movie.overview.length > 100)
                  ? Text( '${movie.overview.substring(0,100)}...' )
                  : Text( movie.overview ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Mostrar calificación de peliculas

- Agregamos el siguiente código en el archivo `search_movie_delegate.dart`, en el widget `_MovieItem`

```
// * Description
SizedBox(
  width: size.width * 0.7,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text( movie.title, style: textStyles.titleMedium),

      (movie.overview.length > 100)
        ? Text( '${movie.overview.substring(0,100)}...' )
        : Text( movie.overview ),

      Row(
        children: [
          Icon(Icons.star_half_rounded, color: Colors.yellow.shade800),
          const SizedBox(width: 5),
          Text( 
            HumanFormats.number(movie.voteAverage, 1),
            style: textStyles.bodyMedium!.copyWith(color: Colors.yellow.shade900),
          )
        ],
      )

    ],
  ),
),
```

#### Regresar a la busqueda con argumentos

- En el `_MovieItem` envolvemos en un nuevo widget el `Padding`  y agregamos un `GestureDetector`

- Ahora voy a recibir una funcion en mi widget `_MovieItem`, para pasar la función `close` global que tengo en el searchDelegate

- El código quedaria asi:

```


import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';

// * Definir un tipo de función para hacer el searchMovie
// * que traiga una lista de movies
typedef SearchMoviesCallback = Future<List<Movie>> Function( String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {

  final SearchMoviesCallback searchMovies;

  SearchMovieDelegate({
    required this.searchMovies
  });

  @override
  String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [

      FadeIn(
        animate: query.isNotEmpty,
        child: IconButton(
          onPressed: () => query = '', 
          icon: const Icon(Icons.clear)
        ),
      ),


    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null), 
      icon: const Icon(Icons.arrow_back_ios_new_rounded)
    )
    ;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    return FutureBuilder(
      future: searchMovies(query),
      builder: (context, snapshot) {

        final movies = snapshot.data ?? [];

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie: movies[index],
            onMovieSelected: close,
          ),
        );
      },
    );
  }

}

class _MovieItem extends StatelessWidget {

  final Movie movie;
  final Function onMovieSelected;

  const _MovieItem({
    required this.movie, 
    required this.onMovieSelected
  });

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
    
            // * Image
            SizedBox(
              width: size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  loadingBuilder: (context, child, loadingProgress) => FadeIn(child: child),
                ),
              ),
            ),
    
            const SizedBox( width: 10),
    
            // * Description
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( movie.title, style: textStyles.titleMedium),
    
                  (movie.overview.length > 100)
                    ? Text( '${movie.overview.substring(0,100)}...' )
                    : Text( movie.overview ),
    
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded, color: Colors.yellow.shade800),
                      const SizedBox(width: 5),
                      Text( 
                        HumanFormats.number(movie.voteAverage, 1),
                        style: textStyles.bodyMedium!.copyWith(color: Colors.yellow.shade900),
                      )
                    ],
                  )
    
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- Ahora nos vamos al archivo `custom_appbar.dat` y en el `showSearch`, le decimos que vamos a trabajar con un Movie opcional `showSearch<Movie?>`

```
 showSearch<Movie?>(
  context: context, 
  delegate: SearchMovieDelegate(
    searchMovies: movieRepository.searchMovies
  )
).then((movie) {
  if (movie == null) return;

  context.push('/movie/${ movie.id }');
});
```

#### Debounce Manual

- Vamos a usar un `Stream`, para cotrolar las peticiones, agregamos esta nueva propieda `StreamController<List<Movie>> debouncedMovie = StreamController.broadcast();`

- En el `FutureBuilder` lo cambiamos por un `StreamBuilder` y ya no tenemos el `future: searchMovies(query)` lo comentamos y agregamos el `stream: debounceMovie.stream,`

```


import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';

// * Definir un tipo de función para hacer el searchMovie
// * que traiga una lista de movies
typedef SearchMoviesCallback = Future<List<Movie>> Function( String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {

  final SearchMoviesCallback searchMovies;
  StreamController<List<Movie>> debouncedMovie = StreamController.broadcast();
  Timer? _debouncerTimer;

  SearchMovieDelegate({
    required this.searchMovies
  });

  void _onQueryChanged( String query) {

    print('Query string cambió');

    // * funcion encargada de emitir el nuevo resultado del las películas
    if (  _debouncerTimer?.isActive ?? false ) _debouncerTimer!.cancel();

    _debouncerTimer = Timer( const Duration( milliseconds: 500 ), () {
      print('Buscando peliculas');
    });
  }

  @override
  String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [

      FadeIn(
        animate: query.isNotEmpty,
        child: IconButton(
          onPressed: () => query = '', 
          icon: const Icon(Icons.clear)
        ),
      ),


    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null), 
      icon: const Icon(Icons.arrow_back_ios_new_rounded)
    )
    ;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    // * Cada vez que toque una tecla se llama o emite el _onQueryChanged
    _onQueryChanged(query);

    return StreamBuilder(
      // future: searchMovies(query),
      stream: debouncedMovie.stream,
      builder: (context, snapshot) {

        final movies = snapshot.data ?? [];

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie: movies[index],
            onMovieSelected: close,
          ),
        );
      },
    );
  }

}

class _MovieItem extends StatelessWidget {

  final Movie movie;
  final Function onMovieSelected;

  const _MovieItem({
    required this.movie, 
    required this.onMovieSelected
  });

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
    
            // * Image
            SizedBox(
              width: size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  loadingBuilder: (context, child, loadingProgress) => FadeIn(child: child),
                ),
              ),
            ),
    
            const SizedBox( width: 10),
    
            // * Description
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( movie.title, style: textStyles.titleMedium),
    
                  (movie.overview.length > 100)
                    ? Text( '${movie.overview.substring(0,100)}...' )
                    : Text( movie.overview ),
    
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded, color: Colors.yellow.shade800),
                      const SizedBox(width: 5),
                      Text( 
                        HumanFormats.number(movie.voteAverage, 1),
                        style: textStyles.bodyMedium!.copyWith(color: Colors.yellow.shade900),
                      )
                    ],
                  )
    
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Debounced Movie - Stream

- Realizamos una validaciones `query.isEmpty` y agregamos una lista vacia de peliculas
- Si tenemos algun valor en el query que no es vacio, llamo al `searchMovies` y tendriamos una pelicula o movie y la agregamos al `debouncedMovies`
- Creamos una fucion para limpiar los streams `clearStreams` y lo agrego en el `buildLeading`

```
import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';

// * Definir un tipo de función para hacer el searchMovie
// * que traiga una lista de movies
typedef SearchMoviesCallback = Future<List<Movie>> Function( String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {

  final SearchMoviesCallback searchMovies;
  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();
  Timer? _debouncerTimer;

  SearchMovieDelegate({
    required this.searchMovies
  });

  void clearStreams() {
    debouncedMovies.close();
  }

  void _onQueryChanged( String query) {

    // * funcion encargada de emitir el nuevo resultado del las películas
    if (  _debouncerTimer?.isActive ?? false ) _debouncerTimer!.cancel();

    _debouncerTimer = Timer( const Duration( milliseconds: 500 ), () async {
      if ( query.isEmpty ) {
        debouncedMovies.add([]);
        return;
      }

      final movies = await searchMovies( query );
      debouncedMovies.add(movies);

    });
  }

  @override
  String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [

      FadeIn(
        animate: query.isNotEmpty,
        child: IconButton(
          onPressed: () => query = '', 
          icon: const Icon(Icons.clear)
        ),
      ),


    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();
        close(context, null);
      }, 
      icon: const Icon(Icons.arrow_back_ios_new_rounded)
    )
    ;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    // * Cada vez que toque una tecla se llama o emite el _onQueryChanged
    _onQueryChanged(query);

    return StreamBuilder(
      // future: searchMovies(query),
      stream: debouncedMovies.stream,
      builder: (context, snapshot) {

        final movies = snapshot.data ?? [];

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie: movies[index],
            onMovieSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            }
          ),
        );
      },
    );
  }

}

class _MovieItem extends StatelessWidget {

  final Movie movie;
  final Function onMovieSelected;

  const _MovieItem({
    required this.movie, 
    required this.onMovieSelected
  });

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
    
            // * Image
            SizedBox(
              width: size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  loadingBuilder: (context, child, loadingProgress) => FadeIn(child: child),
                ),
              ),
            ),
    
            const SizedBox( width: 10),
    
            // * Description
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( movie.title, style: textStyles.titleMedium),
    
                  (movie.overview.length > 100)
                    ? Text( '${movie.overview.substring(0,100)}...' )
                    : Text( movie.overview ),
    
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded, color: Colors.yellow.shade800),
                      const SizedBox(width: 5),
                      Text( 
                        HumanFormats.number(movie.voteAverage, 1),
                        style: textStyles.bodyMedium!.copyWith(color: Colors.yellow.shade900),
                      )
                    ],
                  )
    
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Search Movies Providers
- Para mantener los resultados de la busqueda se tiene 2 formas:
- En el `custom_appbar.dart`, agregamos en el `showSearch`, el `query: 'antman',` , pero no mantenemos los resultados en memoria, siempre realizamos peticioes http.

```
  showSearch<Movie?>(
  query: 'antman',
  context: context, 
  delegate: SearchMovieDelegate(
    searchMovies: movieRepository.searchMovies
  )
).then((movie) {
  if (movie == null) return;

  context.push('/movie/${ movie.id }');
});
```

- Creamos una nueva carpeta `search` dentro de `presentation -> providers`
- Agregamos un nuevo archivo `search_movies_provider.dart`

```
// * El primer provider que se va a manejar es el Stream
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = StateProvider<String>((ref) => 'null');
```

- Regresamos al archivo `custom_appbar.dart`, y agregamos el siguiente codigo:

```
IconButton(
  onPressed: () {
    
    final movieRepository = ref.read( movieRepositoryProvider );
    final searchQuery = ref.read( searchQueryProvider );

    showSearch<Movie?>(
      query: searchQuery,
      context: context, 
      delegate: SearchMovieDelegate(
        searchMovies: (query) {
          ref.read(searchQueryProvider.notifier).update((state) => query);
          return movieRepository.searchMovies(query);
        }
      )
    ).then((movie) {
      if (movie == null) return;

      context.push('/movie/${ movie.id }');
    });
    
  }, 
  icon: const Icon(Icons.search)
)
```

#### Mantener un estado con las películas buscadas

- Regresamos al archivo `search_movies_provider.dart` y creamos la nueva classe `SearchedMoviesNotifier` agregamos las propiedades ` final SearchMoviesCallback searchMovies;` y `final Ref ref` 

- Definimos la funcionn `typedef SearchMoviesCallback = Future<List<Movie>> Function( String query );`

- Implementamos el `searchedMoviesProvider`

```
// * El primer provider que se va a manejar es el Stream
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

// * Este provider va a manejar las pelicuals previamente buscadas o implementacion del searchedMoviesProvider
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
```

- Ahora hacemos referencia a nuestro nuevo provider en el archivo `custom_appbar.dart`

```
 IconButton(
  onPressed: () {
    
    // final movieRepository = ref.read( movieRepositoryProvider );
    final searchQuery = ref.read( searchQueryProvider );

    showSearch<Movie?>(
      query: searchQuery,
      context: context, 
      delegate: SearchMovieDelegate(
        searchMovies: ref.read( searchedMoviesProvider.notifier).searchMoviesByQuery
      )
    ).then((movie) {
      if (movie == null) return;

      context.push('/movie/${ movie.id }');
    });
    
  }, 
  icon: const Icon(Icons.search)
)
```

#### Mostrar las películas previamente almacenadas

- en el archivo `search_movie_delegate.dart`, agregamos una nueva propiedad `final List<Movie> initialMovies;` y agregamos esa propiedad al constructor 

```


import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';

// * Definir un tipo de función para hacer el searchMovie
// * que traiga una lista de movies
typedef SearchMoviesCallback = Future<List<Movie>> Function( String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {

  final SearchMoviesCallback searchMovies;
  final List<Movie> initialMovies;

  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();
  Timer? _debouncerTimer;

  SearchMovieDelegate({
    required this.searchMovies,
    required this.initialMovies,
  });

  void clearStreams() {
    debouncedMovies.close();
  }

  void _onQueryChanged( String query) {

    // * funcion encargada de emitir el nuevo resultado del las películas
    if (  _debouncerTimer?.isActive ?? false ) _debouncerTimer!.cancel();

    _debouncerTimer = Timer( const Duration( milliseconds: 500 ), () async {

      final movies = await searchMovies( query );
      debouncedMovies.add(movies);

    });
  }

  @override
  String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [

      FadeIn(
        animate: query.isNotEmpty,
        child: IconButton(
          onPressed: () => query = '', 
          icon: const Icon(Icons.clear)
        ),
      ),


    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();
        close(context, null);
      }, 
      icon: const Icon(Icons.arrow_back_ios_new_rounded)
    )
    ;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    // * Cada vez que toque una tecla se llama o emite el _onQueryChanged
    _onQueryChanged(query);

    return StreamBuilder(
      // future: searchMovies(query),
      initialData: initialMovies,
      stream: debouncedMovies.stream,
      builder: (context, snapshot) {

        final movies = snapshot.data ?? [];

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie: movies[index],
            onMovieSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            }
          ),
        );
      },
    );
  }

}

class _MovieItem extends StatelessWidget {

  final Movie movie;
  final Function onMovieSelected;

  const _MovieItem({
    required this.movie, 
    required this.onMovieSelected
  });

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
    
            // * Image
            SizedBox(
              width: size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  loadingBuilder: (context, child, loadingProgress) => FadeIn(child: child),
                ),
              ),
            ),
    
            const SizedBox( width: 10),
    
            // * Description
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( movie.title, style: textStyles.titleMedium),
    
                  (movie.overview.length > 100)
                    ? Text( '${movie.overview.substring(0,100)}...' )
                    : Text( movie.overview ),
    
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded, color: Colors.yellow.shade800),
                      const SizedBox(width: 5),
                      Text( 
                        HumanFormats.number(movie.voteAverage, 1),
                        style: textStyles.bodyMedium!.copyWith(color: Colors.yellow.shade900),
                      )
                    ],
                  )
    
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### BuildResults

- En el archivo `search_movie_delegate.dart`, copiamos el `StreamBuilder` y lo copiamos en `buildResults`, le quitamos el final y queda asi `List<Movie> initialMovies;`, ahora agregamos el `initialMovies = movies;` en la funcion `_onQueryChanged`

- Creamos un nuevo metodo que se llama `buildResultsAndSuggestions` para no repetir código.

```
  Widget buildResultsAndSuggestions() {

    return StreamBuilder(
      initialData: initialMovies,
      stream: debouncedMovies.stream,
      builder: (context, snapshot) {

        final movies = snapshot.data ?? [];

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie: movies[index],
            onMovieSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            }
          ),
        );
      },
    );

  }
```
- Ahora sustituimos el `buildResults` y `buildSuggestions`, el código total quda asi:

```


import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';

// * Definir un tipo de función para hacer el searchMovie
// * que traiga una lista de movies
typedef SearchMoviesCallback = Future<List<Movie>> Function( String query);

class SearchMovieDelegate extends SearchDelegate<Movie?> {

  final SearchMoviesCallback searchMovies;
  List<Movie> initialMovies;

  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();
  Timer? _debouncerTimer;

  SearchMovieDelegate({
    required this.searchMovies,
    required this.initialMovies,
  });

  void clearStreams() {
    debouncedMovies.close();
  }

  void _onQueryChanged( String query) {

    // * funcion encargada de emitir el nuevo resultado del las películas
    if (  _debouncerTimer?.isActive ?? false ) _debouncerTimer!.cancel();

    _debouncerTimer = Timer( const Duration( milliseconds: 500 ), () async {

      final movies = await searchMovies( query );
      initialMovies = movies;
      debouncedMovies.add(movies);

    });
  }

  Widget buildResultsAndSuggestions() {

    return StreamBuilder(
      initialData: initialMovies,
      stream: debouncedMovies.stream,
      builder: (context, snapshot) {

        final movies = snapshot.data ?? [];

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie: movies[index],
            onMovieSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            }
          ),
        );
      },
    );

  }

  @override
  String get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [

      FadeIn(
        animate: query.isNotEmpty,
        child: IconButton(
          onPressed: () => query = '', 
          icon: const Icon(Icons.clear)
        ),
      ),


    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();
        close(context, null);
      }, 
      icon: const Icon(Icons.arrow_back_ios_new_rounded)
    )
    ;
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    // * Cada vez que toque una tecla se llama o emite el _onQueryChanged
    _onQueryChanged(query);

    return buildResultsAndSuggestions();
  }

}

class _MovieItem extends StatelessWidget {

  final Movie movie;
  final Function onMovieSelected;

  const _MovieItem({
    required this.movie, 
    required this.onMovieSelected
  });

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
    
            // * Image
            SizedBox(
              width: size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  loadingBuilder: (context, child, loadingProgress) => FadeIn(child: child),
                ),
              ),
            ),
    
            const SizedBox( width: 10),
    
            // * Description
            SizedBox(
              width: size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( movie.title, style: textStyles.titleMedium),
    
                  (movie.overview.length > 100)
                    ? Text( '${movie.overview.substring(0,100)}...' )
                    : Text( movie.overview ),
    
                  Row(
                    children: [
                      Icon(Icons.star_half_rounded, color: Colors.yellow.shade800),
                      const SizedBox(width: 5),
                      Text( 
                        HumanFormats.number(movie.voteAverage, 1),
                        style: textStyles.bodyMedium!.copyWith(color: Colors.yellow.shade900),
                      )
                    ],
                  )
    
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Go Router - Tabs - Preservar el estado

####  Creación de Vistas

- Creamos la carpeta `views -> movies` dentro de ``presentation
- Creamos los archivos `home_view.dart` y `favorites_view.dart`
- En el archivo `favorites_view.dart`, agregamos

```
import 'package:flutter/material.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites View'),
      ),
      body: const Center(child: Text('Favoritos')),
    );
  }
}
```

- Ahora vamos al archivo `home_screen.dart` y cortamos todo el `_HomeView` y lo pegamos en el archivo `home_view.dart`

```
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class HomeView extends ConsumerStatefulWidget {
  const HomeView({ super.key });

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> {

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

- Creamos el archivo de barril `views.dart`

- Modificamos el archivo `home_screen.dart`

```
import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

import '../../views/views.dart';


class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: HomeView(),
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}

```

#### Configuración de rutas

- Abrimos el archivo `home_screen.dart` y colocamos el siguiente código:
- El `IndexedStack`, permite mantener el estado de la aplicación, se maniene el `momentun` por ejemplo los los scroll de las peliculas

```
import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

import '../../views/views.dart';


class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';
  final int pageIndex;

  const HomeScreen({
    super.key, 
    required this.pageIndex
  });

  final viewRouters = const <Widget>[
    HomeView(),
    SizedBox(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: viewRouters,
      ),
      bottomNavigationBar: CustomBottomNavigation(),
    );
  }
}

```

- Abrimos el archivo `app_router.dart` y colocamos el siguiente código:

```
import 'package:cinemapedia/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/home/0',
  routes: [

    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {

        final pageIndex = int.parse(state.params['page'] ?? '0');

        return HomeScreen( pageIndex: pageIndex );
      },
      routes: [
        GoRoute(
          path: 'movie/:id',
          name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.params['id'] ?? 'no-id';
            return MovieScreen(movieId: movieId);
          },
        ),
      ]
    ),
  ]
);
```

#### Funcionamiento del Bottom Navigation Bar

- en el archivo `custom_bottom_navigation.dart`, agregamos una nueva propiedad `final int currentIndex;` y el metodo `onItemTapped`

```
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatelessWidget {

  final int currentIndex;

  const CustomBottomNavigation({
    super.key, 
    required this.currentIndex
  });

  // Metodos
  void onItemTapped( BuildContext context, int index ) {

    switch (index) {
      case 0:
        context.go('/home/0');
      break;
      case 1:
        context.go('/home/1');
      break;
      case 2:
        context.go('/home/2');
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      currentIndex: currentIndex,
      onTap: (value) => onItemTapped(context, value),
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

- ahora en el archivo `home_screen`, le mandamos el nuevo argumento `currentIndex` al `CustomBottomNavigation`

```
import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

import '../../views/views.dart';


class HomeScreen extends StatelessWidget {

  static const name = 'home-screen';
  final int pageIndex;

  const HomeScreen({
    super.key, 
    required this.pageIndex
  });

  final viewRouters = const <Widget>[
    HomeView(),
    SizedBox(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: viewRouters,
      ),
      bottomNavigationBar: CustomBottomNavigation( currentIndex: pageIndex ),
    );
  }
}


```

#### Resolver la navegación

- Abrimos el archivo `app_router.dart` y agregamos una nueva configuracion de un `GoRoute` `redirect`.

```
import 'package:cinemapedia/presentation/screens/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/home/0',
  routes: [

    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {

        final pageIndex = int.parse(state.params['page'] ?? '0');

        return HomeScreen( pageIndex: pageIndex );
      },
      routes: [
        GoRoute(
          path: 'movie/:id',
          name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.params['id'] ?? 'no-id';
            return MovieScreen(movieId: movieId);
          },
        ),
      ]
    ),

    GoRoute(
      path: '/',
      redirect: ( _, __ ) => '/home/0'
    )
  ]
);
```

- Para navegar al detalle de la pelicula hacemos lo siguiente:
- Abrimos el archivo `movie_horizontal_listview.dart`, ahi es donde le damos click a la imagen de la pelicula y nos lleva a la pagina movie
- Actualizamos la ruta:

```
return GestureDetector(
  onTap: () => context.push('/home/0/movie/${ movie.id }'),
  child: FadeIn(child: child),
);
```
- En el archivo `custom_appbar.dart` para que se haga la navegacion a la pantalla de `movie_screen.dart`, actualizamos `context.push('/home/0/movie/${ movie.id }');`.

```
IconButton(
  onPressed: () {
    
    final searchedMovies = ref.read(searchedMoviesProvider);
    final searchQuery = ref.read( searchQueryProvider );

    showSearch<Movie?>(
      query: searchQuery,
      context: context, 
      delegate: SearchMovieDelegate(
        initialMovies: searchedMovies,
        searchMovies: ref.read( searchedMoviesProvider.notifier).searchMoviesByQuery
      )
    ).then((movie) {
      if (movie == null) return;

      context.push('/home/0/movie/${ movie.id }');
    });
    
  }, 
  icon: const Icon(Icons.search)
)
```


### Local Database

####  Boton para marcar como favorito

- abrimos el archivo `movie_screen.dart`, para agregar el icono de favoritos y crear un widget para reutilizar el gradiente `_CustomGradient`

```
class _CustomGradient extends StatelessWidget {

  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;


  const _CustomGradient({
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    required this.stops,
    required this.colors
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end, 
            stops: stops,
            colors: colors
          ),
        )
      ),
    );
  }
}
```

- Ahora utilizamos el `_CustomGradient` en el `_CustomSliverAppBar`

```
class _CustomSliverAppBar extends StatelessWidget {

  final Movie movie;

  const _CustomSliverAppBar({
    required this.movie
  });

  @override
  Widget build(BuildContext context) {

    // * Tengo las dimensiones del dispositivo fisico conel MediaQuery
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () {}, 
          icon: const Icon(Icons.favorite_border),
          // icon: const Icon(Icons.favorite_rounded, color: Colors.red)
        ),
      ],
      shadowColor: Colors.red,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [

            // * Imagen
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if ( loadingProgress != null ) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),

            // * Aplicar gradientes para el icono de favoritos
            const _CustomGradient(
              begin: Alignment.topRight, 
              end: Alignment.bottomLeft,
              stops: [0.0, 0.2], 
              colors: [
                Colors.black54,
                Colors.transparent,
              ]
            ),
            

            // * Aplicar gradientes para fondos claros de la imagen
            const _CustomGradient(
              begin: Alignment.topCenter, 
              end: Alignment.bottomCenter, 
              stops: [0.8, 1.0], 
              colors: [
                Colors.transparent,
                Colors.black54
              ]
            ),

            // * Aplicar gradientes para la flechita del back
            const _CustomGradient(
              begin: Alignment.topLeft,
              stops: [0.0, 0.3], 
              colors: [
                Colors.black87,
                Colors.transparent,
              ]
            ),

          ],
        ),
      ),
    );
  }
}
```

#### Isar Database

Documentación: https://isar.dev/es/

- Instalacion de unos paquetes `isar isar_flutter_libs` y `isar_generator build_runner`
- Instalación de paquetes de desarrollo `-d` `isar_generator build_runner`

- Agregamos en cada una de las `entities` -> `actor.dart` y `movie.dart`, los decoradores `@collection`

- Agregamos un identificador unico para la base de datos `id`  `Id? isarId;` y es opcional.

- Agregamos `part 'movie.g.dart';`, este es un archivo que se va a generar de manera automatica y por es marca un error.

- `movie.dart`

```
import 'package:isar/isar.dart';

part 'movie.g.dart';

@collection
class Movie {

    Id? isarId;

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

#### - Ahora vamos a ejecutar el generador de código

- Abrimos la terminal y corremos el comando`flutter pub run build_runner build`

- Una vez ejecutado el comando, se quita el error en el archivo `movie.dart` y nos crea un archivo `movie.g.dart`


#### Repositorio y Datasource

- Creamos un nuevo datasource `local_storage_datasource.dart` en la carpeta `domain -> datasources`

```
import '../entities/movie.dart';

abstract class LocalStorageDatasource {

  Future<void> toggleFavorite( Movie movie );

  Future<bool> isMovieFavorite( int movieId );

  Future<List<Movie>> loadMovies({ int limit = 10, int offset = 0 });

} 
```

- Creamos un nuevo repositorio `local_storage_repository.dart` en la carpeta `domain -> repositories`

```
import '../entities/movie.dart';

abstract class LocalStorageRepository {

  Future<void> toggleFavorite( Movie movie );

  Future<bool> isMovieFavorite( int movieId );

  Future<List<Movie>> loadMovies({ int limit = 10, int offset = 0 });

}
```

- Ahora vamos a hacer la implementacion del datasource y repositorio en la carpeta `infrstructure -> datasources -> repositories`

- Creamos el archivo `isar_datasource.dart`, dentro de la carpeta `datasources`, por ahora no tiene mucha funcionalidad

```


import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

class IsarDatasource extends LocalStorageDatasource {
  @override
  Future<bool> isMovieFavorite(int movieId) {
    // TODO: implement isMovieFavorite
    throw UnimplementedError();
  }

  @override
  Future<List<Movie>> loadMovies({int limit = 10, int offset = 0}) {
    // TODO: implement loadMovies
    throw UnimplementedError();
  }

  @override
  Future<void> toggleFavorite(Movie movie) {
    // TODO: implement toggleFavorite
    throw UnimplementedError();
  }



}
```

- Creamos el archivo `local_storage_repository_impl.dart`, dentro de la carpeta `repositories`

```
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/repositories/local_starage_repository.dart';
import '../../domain/datasources/local_storage_datasource.dart';

class LocalStorageRepositoryImpl extends LocalStorageRepository {

  final LocalStorageDatasource datasource;

  LocalStorageRepositoryImpl(this.datasource);

  @override
  Future<bool> isMovieFavorite(int movieId) {
    return datasource.isMovieFavorite(movieId);
  }

  @override
  Future<List<Movie>> loadMovies({int limit = 10, int offset = 0}) {
    return datasource.loadMovies( limit: limit, offset: offset );
  }

  @override
  Future<void> toggleFavorite(Movie movie) {
    return datasource.toggleFavorite(movie);
  }

}
```

#### Isar Datasource Implementation

- Abrimos el archivo `isar_datasource.dart` y agregamos el metodo para abrir la bd

```


import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:isar/isar.dart';

class IsarDatasource extends LocalStorageDatasource {

  late Future<Isar> db;

  IsarDatasource() {
    db = openDB();
  }

  Future<Isar> openDB() async {

    if (Isar.instanceNames.isEmpty ) {
      return await Isar.open([ MovieSchema ], inspector: true);
    }

    return Future.value(Isar.getInstance());
  }

  @override
  Future<bool> isMovieFavorite(int movieId) {
    // TODO: implement isMovieFavorite
    throw UnimplementedError();
  }


  @override
  Future<void> toggleFavorite(Movie movie) {
    // TODO: implement toggleFavorite
    throw UnimplementedError();
  }


  @override
  Future<List<Movie>> loadMovies({int limit = 10, int offset = 0}) {
    // TODO: implement loadMovies
    throw UnimplementedError();
  }

}
```

#### Implementación de los métodos necesariios

- Abrimos el archivo `isar_datasource.dart` y agragamos los métodos para interactuar con la base de datos

```
import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:isar/isar.dart';

class IsarDatasource extends LocalStorageDatasource {

  late Future<Isar> db;

  IsarDatasource() {
    db = openDB();
  }

  Future<Isar> openDB() async {

    if (Isar.instanceNames.isEmpty ) {
      return await Isar.open([ MovieSchema ], inspector: true);
    }

    return Future.value(Isar.getInstance());
  }

  @override
  Future<bool> isMovieFavorite(int movieId) async {

    final isar = await db;

    final Movie? isFavoriteMovie = await isar.movies
      .filter()
      .idEqualTo(movieId)
      .findFirst();

    return isFavoriteMovie != null;

  }


  @override
  Future<void> toggleFavorite(Movie movie) async {
    
    final isar = await db;

    final favoriteMovie = await isar.movies
      .filter()
      .idEqualTo(movie.id)
      .findFirst();

    if ( favoriteMovie != null ) {
      // Borrar
      isar.writeTxnSync(() => isar.movies.deleteSync(favoriteMovie.isarId!));
      return;
    }

    // Insertar
    isar.writeTxnSync(() => isar.movies.putSync(movie));
  }


  @override
  Future<List<Movie>> loadMovies({int limit = 10, int offset = 0}) async {
    
    final isar = await db;

    return isar.movies.where()
      .offset(offset)
      .limit(limit)
      .findAll();
  }

}
```

#### Provider y grabar en Base de datos

- Tenemos que crear un nuevo provider para ello creamos un archivo `local_storage_provider.dart`  y la carpeta `storage`, dentro de `presentation -> providers` 

```
import 'package:cinemapedia/infrastructure/datasources/isar_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/local_storage_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageRepositoryProvider = Provider((ref) {
  return LocalStorageRepositoryImpl(IsarDatasource());
});
```

- Ahora abrimos el archivo `movie_screen.dart`, para hacer la implementacion cuando se pesiiona el iconno del corazón para agregar o quitar de favorito.

- El `_CustomSliverAppBar` lo cambiamos de `StatelessWidget` a `ConsumerWidget`
- En el `SliverAppBar` agregamos el llamado del provider `localStorageRepositoryProvider`

```
IconButton(
  onPressed: () {

    ref.watch(localStorageRepositoryProvider).toggleFavorite(movie);

  }, 
  icon: const Icon(Icons.favorite_border),
  // icon: const Icon(Icons.favorite_rounded, color: Colors.red)
),
```

- Ahora le damos un `Stop` boton cuadrado rojo a la aplicacion para que tome los cambios de la bd

- Le damos al icono del corazón y en el debug console nos aparece el mensaje de `ISAR CONECT STARTED` y le damos click a la direccion https y podemos ver los registros de la base de datos


#### Future Provider  - Family modifier

- En el archivo `movie_screen.dart` creamos un provider `isFavoriteProvider` para verificar si esa pelicula esta en favorito o no y tambien utilizamos el `invalidate`, para invalidarlo y volver hacer la peticion y confirme, todo eso lo hacemos en el `_CustomSliverAppBar`

```
// * FutureProvider.family => me permite mandar un argumento que es el id de la pelicula

final isFavoriteProvider = FutureProvider.family.autoDispose((ref, int movieId) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return localStorageRepository.isMovieFavorite(movieId); // si esta en favorito
});

class _CustomSliverAppBar extends ConsumerWidget {

  final Movie movie;

  const _CustomSliverAppBar({
    required this.movie
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));

    // * Tengo las dimensiones del dispositivo fisico conel MediaQuery
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () {

            ref.watch(localStorageRepositoryProvider).toggleFavorite(movie);

            ref.invalidate(isFavoriteProvider(movie.id));

          }, 
          icon: isFavoriteFuture.when(
            data: (isFavorite) => isFavorite
              ? const Icon(Icons.favorite_rounded, color: Colors.red)
              : const Icon(Icons.favorite_border), 
            error: ( _, __) => throw UnimplementedError(), 
            loading: () => const CircularProgressIndicator(strokeWidth: 2)
          ),
          // icon: const Icon(Icons.favorite_border),
          // icon: const Icon(Icons.favorite_rounded, color: Colors.red)
        ),
      ],
      shadowColor: Colors.red,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [

            // * Imagen
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if ( loadingProgress != null ) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),

            // * Aplicar gradientes para el icono de favoritos
            const _CustomGradient(
              begin: Alignment.topRight, 
              end: Alignment.bottomLeft,
              stops: [0.0, 0.2], 
              colors: [
                Colors.black54,
                Colors.transparent,
              ]
            ),
            

            // * Aplicar gradientes para fondos claros de la imagen
            const _CustomGradient(
              begin: Alignment.topCenter, 
              end: Alignment.bottomCenter, 
              stops: [0.8, 1.0], 
              colors: [
                Colors.transparent,
                Colors.black54
              ]
            ),

            // * Aplicar gradientes para la flechita del back
            const _CustomGradient(
              begin: Alignment.topLeft,
              stops: [0.0, 0.3], 
              colors: [
                Colors.black87,
                Colors.transparent,
              ]
            ),

          ],
        ),
      ),
    );
  }
}
```

#### Favorite MoviesProvider

- Creamos un nuevo archivo provider `favorite_movies_provider.dart`, en la carpeta `presentation -> providers -> storage`

```
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

  Future<void> loadNextPage() async {

    final movies = await localStorageRepository.loadMovies(offset: page * 10); //TODO: limit 20
    page++;

    final tempMoviesMap = <int, Movie>{};
    for(final movie in movies) {
      tempMoviesMap[movie.id] = movie;
    }

    state = { ...state, ...tempMoviesMap };
  }

}
```


#### Mostrar Peliculas Favoritas

- Abrimos el archivo `favorites_view.dart`, cambiamos `StatelessWidget` por `StatefulWidget` y lo volvemos a cambiar por un `ConsumerStatefulWidget`

- Cargamos de bd las peliculas favoritas y tambien cambiamos el `Map<int, Movie>>`  a `List<Movie>` usando el `.value.toList()`

```
import 'package:cinemapedia/presentation/providers/storage/favorite_movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> {

  @override
  void initState() {
    super.initState();

    // Cargamos las peliculas
    ref.read( favoriteMoviesProvider.notifier).loadNextPage();
  }


  @override
  Widget build(BuildContext context) {

    // * Cambiamos el Map<int, Movie>>  a List<Movie> usando el .value.toList()
    final favoritesMovies = ref.watch(favoriteMoviesProvider).values.toList();
    

    return Scaffold(
      body: ListView.builder(
        itemCount: favoritesMovies.length,
        itemBuilder: (context, index) {
          final movie = favoritesMovies[index];
          
          return ListTile(
            title: Text(movie.title),
          );
        },
      ),
    );
  }
}
```

#### StaggeredGridView - MasonryGridView

Documentación: https://pub.dev/packages/flutter_staggered_grid_view

- Instalación del paquete: `flutter_staggered_grid_view`

- Creamos el archivo `movie_masonry.dart`, en la carpeta `presentation -> widgets -> movies`

```
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../domain/entities/movie.dart';
import 'movie_poster_link.dart';

class MovieMasonry extends StatefulWidget {

  final List<Movie> movies;
  final VoidCallback? loadNextPage;

  const MovieMasonry({
    super.key, 
    required this.movies, 
    this.loadNextPage
  });

  @override
  State<MovieMasonry> createState() => _MovieMasonryState();
}

class _MovieMasonryState extends State<MovieMasonry> {

  // todo: initState

  // todo: dispose

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MasonryGridView.count(
        crossAxisCount: 3, // 3 columnas
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          
          if ( index == 1 ) {
            return Column(
              children: [
                const SizedBox(height: 40),
                MoviePosterLink( movie: widget.movies[index] ),
              ],
            );
          }
          return MoviePosterLink( movie: widget.movies[index] );
        },
      ),
    );
  }
}
```

- Creamos el archivo `movie_poster_link.dart`, en la carpeta `presentation -> widgets -> movies`

```
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/movie.dart';

class MoviePosterLink extends StatelessWidget {

  final Movie movie;

  const MoviePosterLink({
    super.key, 
    required this.movie
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () => context.push('/home/0/movie/${ movie.id }'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FadeIn(
            child: Image.network(movie.posterPath),
      
          ),
        ),
      ),
    );
  }
}
```

- En el archivo `favorites_view.dart` usamos el widget `MovieMasonry`

```
import 'package:cinemapedia/presentation/providers/storage/favorite_movies_provider.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> {

  @override
  void initState() {
    super.initState();

    // Cargamos las peliculas
    ref.read( favoriteMoviesProvider.notifier).loadNextPage();
  }


  @override
  Widget build(BuildContext context) {

    // * Cambiamos el Map<int, Movie>>  a List<Movie> usando el .value.toList()
    final favoritesMovies = ref.watch(favoriteMoviesProvider).values.toList();
    
    return Scaffold(
      body: MovieMasonry(movies: favoritesMovies),
    );
  }
}
```


#### Masonry Infinite Scroll

- Abrimos el archivo `movie_masonry.dart` 
- Creamos `final scrollController = ScrollController();` y el metodo `initState` y `dispose` 

```
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../domain/entities/movie.dart';
import 'movie_poster_link.dart';

class MovieMasonry extends StatefulWidget {

  final List<Movie> movies;
  final VoidCallback? loadNextPage;

  const MovieMasonry({
    super.key, 
    required this.movies, 
    this.loadNextPage
  });

  @override
  State<MovieMasonry> createState() => _MovieMasonryState();
}

class _MovieMasonryState extends State<MovieMasonry> {

  final scrollController = ScrollController();

  // todo: initState
  @override
  void initState() {
    super.initState();

     scrollController.addListener(() {
      if ( widget.loadNextPage == null ) return;

      if ( (scrollController.position.pixels + 200) >= scrollController.position.maxScrollExtent  ) {
        widget.loadNextPage!();
      }
    });
  }

  // todo: dispose
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MasonryGridView.count(
        controller: scrollController,
        crossAxisCount: 3, // 3 columnas
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          
          if ( index == 1 ) {
            return Column(
              children: [
                const SizedBox(height: 40),
                MoviePosterLink( movie: widget.movies[index] ),
              ],
            );
          }
          return MoviePosterLink( movie: widget.movies[index] );
        },
      ),
    );
  }
}
```

#### Dinamicamente remover y agregar peliculas

- abrimos el archivo `favorite_movies_provider.dart` y agregamos una nueva función `toggleFavorite`


```
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
```

#### Mostrar mensaje si no hay favoritos

- Abrir el archivo `favorites_view.dart`, y agregamos un icono, texto y un boton cuando no se tienen películas en favoritos

```
import 'package:cinemapedia/presentation/providers/storage/favorite_movies_provider.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> {

  bool isLastPage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Cargamos las peliculas
    loadNextPage();
    // ref.read( favoriteMoviesProvider.notifier).loadNextPage();
  }

  void loadNextPage() async {

    if ( isLoading || isLastPage ) return;

    isLoading = true;

    final movies = await ref.read(favoriteMoviesProvider.notifier).loadNextPage();
    isLoading = false;

    if ( movies.isEmpty ) {
      isLastPage = true;
    }

  }


  @override
  Widget build(BuildContext context) {

    // * Cambiamos el Map<int, Movie>>  a List<Movie> usando el .value.toList()
    final favoritesMovies = ref.watch(favoriteMoviesProvider).values.toList();

    if ( favoritesMovies.isEmpty ) {

      final colors= Theme.of(context).colorScheme;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            Icon( Icons.favorite_outline_sharp, size: 60, color: colors.primary ),
            Text('Ohhh no!!', style: TextStyle( fontSize: 30, color: colors.primary)),
            const Text('No tienes películas favoritas', style: TextStyle( fontSize: 20, color: Colors.black45)),
            
            const SizedBox(height: 20),

            FilledButton.tonal(
              onPressed: () => context.go('/home/0'), 
              child: const Text('Empieza a buscar'),
            )

          ],
        ),
      );
    }
    
    return Scaffold(
      body: MovieMasonry(
        movies: favoritesMovies,
        loadNextPage: loadNextPage,
      ),
    );
  }
}
```


## Mejoras de la aplicación

#### 1 -  En el `home_screen.dart` vamos a realizar varios cambios, empezaremos con sustituri el `StatelessWidget` por el `StatefulWidget` , tambien cambiaremos el `IndexedStack` por un  `PageView` y se agregará `AutomaticKeepAliveClientMixin` para preservar el estado del `PageView`

```dart
import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

import '../../views/views.dart';

class HomeScreen extends StatefulWidget {   // -> Se cambio a un StatefulWidget
  static const name = 'home-screen';
  final int pageIndex;

  const HomeScreen({super.key, required this.pageIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {   // -> Se agrego AutomaticKeepAliveClientMixin para preservar el estado del PageView

  late PageController pageController;

  @override
  void initState() {    // -> Se agrego el initState para mantener PageController en true
    super.initState();
    pageController = PageController(
      keepPage: true
    );
  }

  @override
  void dispose() {    // -> Se agrego el dispose para liberar el pageController
    pageController.dispose();
    super.dispose();
  }


  final viewRouters = const <Widget>[
    HomeView(),
    SizedBox(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);   // -> Se agrego el super.build

    if ( pageController.hasClients ) {
      pageController.animateToPage(
        widget.pageIndex, 
        duration: const Duration(milliseconds: 250), 
        curve: Curves.easeInOut
      );
    }

    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: viewRouters,
      ),
      bottomNavigationBar:
          CustomBottomNavigation(currentIndex: widget.pageIndex),
    );
  }

  @override   // -> Se agrego el override
  bool get wantKeepAlive => true;
}

```


#### 2 - Quitamos del `home_view.dart` el `MovieHorizontalListview` de populares y agregamos el `AutomaticKeepAliveClientMixin` 

```dart
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class HomeView extends ConsumerStatefulWidget {
  const HomeView({ super.key });

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> with AutomaticKeepAliveClientMixin {    // -> Se agrego el AutomaticKeepAliveClientMixin

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
    super.build(context);   // -> Se agrego el super.build

    final initialLoading = ref.watch( initialLoadingProvider );
    if ( initialLoading ) return const FullScreenLoader();

    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final slideShowMovies = ref.watch(moviesSlideshowProvider);
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
  
  @override   // -> Se agrego el override
  bool get wantKeepAlive => true;
}
```

#### 3 - Agregamos `Populares` en el `CustomBottomNavigation`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatelessWidget {

  final int currentIndex;

  const CustomBottomNavigation({
    super.key, 
    required this.currentIndex
  });

  // Metodos
  void onItemTapped( BuildContext context, int index ) {

    switch (index) {
      case 0:
        context.go('/home/0');
      break;
      case 1:
        context.go('/home/1');
      break;
      case 2:
        context.go('/home/2');
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      currentIndex: currentIndex,
      onTap: (value) => onItemTapped(context, value),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_max),
          label: 'Inicio'
        ),
         BottomNavigationBarItem(
          icon: Icon(Icons.thumbs_up_down_outlined),    // -> Se cambió el icono
          label: 'Populares'    // -> Se cambió el label
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

#### 4 - Agregamos una nueva vista en `views` llamada `popular_view.dart`

```dart

import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopularView extends ConsumerStatefulWidget {
  const PopularView({super.key});

  @override
  PopularViewState createState() => PopularViewState();
}

class PopularViewState extends ConsumerState<PopularView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {

    final popularMovies = ref.watch( popularMoviesProvider );

    if ( popularMovies.isEmpty ) {
      return const CircularProgressIndicator(strokeWidth: 2);
    }

    super.build(context);
    return Scaffold(
      body: MovieMasonry(
        movies: popularMovies,
        loadNextPage: () => ref.read( popularMoviesProvider.notifier ).loadNextPage(),
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
```

#### 5 - Agregamos una nueva carpeta llamada `assets -> loders` y agregaoms el aechivo `bottle-loader.gif`

#### 6 - Agregamos una nueva carpeta `assets -> loders` el aechivo `pubspec.yaml`

``` yaml
assets:
  - .env
  - assets/loaders/
```

#### 7 - Modiificamos el archivo `movies_slideshow.dart`, el  `_Slide` para navegar al detalle de la película cuando tocamos el slide automatico, 


```dart
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
          child: GestureDetector(   // -> Se agrego el GestureDetector
            onTap: () => context.push('/home/0/movie/${ movie.id }'),   // -> Se agrego el onTap para navegar a movie
            child: FadeInImage(
              image: NetworkImage(movie.backdropPath),
              placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
              fit: BoxFit.cover,
            ),
          )
        ),
      ),
    );
  }
}
```

#### 8 - Creamos un nuevo widget llamado `movie_rating.dart`, en la carpeta `presentation -> widgets -> movies`

```dart

import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:flutter/material.dart';

class MovieRating extends StatelessWidget {

  final double voteAverage;

  const MovieRating({
    super.key, 
    required this.voteAverage
  });

  @override
  Widget build(BuildContext context) {

    final textStyle = Theme.of(context).textTheme;

    return  SizedBox(
      width: 150,
      child: Row(
        children: [
          Icon(Icons.star_half_outlined, color: Colors.yellow.shade800),
          const SizedBox(width: 3),
          Text(HumanFormats.number(voteAverage, 1),
            style: textStyle.bodyMedium?.copyWith( color: Colors.yellow.shade800 ),
          )
        ],
      ),
    );
  }
}
```


#### 9 - Modiificamos el archivo `movies_horizontal_listview.dart`, el `_Slide` para navegar al detalle de la película cuando tocamos el slide automatico, 

  ```dart
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
              child: GestureDetector(   // -> Se agrego el GestureDetector
                onTap: () => context.push('/home/0/movie/${ movie.id }'),
                child: FadeInImage(
                  height: 220,
                  image: NetworkImage(movie.posterPath),
                  placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
                  fit: BoxFit.cover,
                ),
              )
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
          MovieRating(voteAverage: movie.voteAverage)   // -> Se agrego el MovieRating
        ],
      ),
    );
  }
}
  ```

#### 10 - Modificamos el archivo `search_movie_deletage.dart` en el `_MovieItem` en el `GestureDetector`

  ```dart
   // * Image
  SizedBox(
    width: size.width * 0.2,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: FadeInImage(   // -> Se agrego el FadeInImage, para usar el loader
          height: 130,
          image: NetworkImage(movie.posterPath),
          placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
          fit: BoxFit.cover,
        )
      ),
    ),
  ```


#### 11 - Modificamos el archivo `movie_poster_link.dart`

  ```dart
  import 'package:animate_do/animate_do.dart';
  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';

  import '../../../domain/entities/movie.dart';

  class MoviePosterLink extends StatelessWidget {

    final Movie movie;

    const MoviePosterLink({
      super.key, 
      required this.movie
    });

    @override
    Widget build(BuildContext context) {
      return FadeInUp(
        child: GestureDetector(
          onTap: () => context.push('/home/0/movie/${ movie.id }'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage(   // -> Se agrego el FadeInImage para usar el loader
                height: 180,
                image: NetworkImage(movie.posterPath),
                placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
                fit: BoxFit.cover,
            ) 
          ),
        ),
      );
    }
  }
  ```

#### 12 - Modificamos el archivo `movie_screen.dart`, para colocar por separado los widgets `Titulo y Descripción`, `Genres` y `Actors`

```dart
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';

class MovieScreen extends ConsumerStatefulWidget {

  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({
    super.key, 
    required this.movieId
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {

  @override
  void initState() {
    super.initState();

    // * Si estamos dentro del initState, metodos, callback, onTap, onPress etc.
    // * se usa el ref.read()
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId);

    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId);

  }

  @override
  Widget build(BuildContext context) {

    final Movie? movie = ref.watch( movieInfoProvider )[widget.movieId];

    if ( movie == null ) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(), // evita el rebote del scrollView
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(delegate: SliverChildBuilderDelegate(
            (context, index) => _MovieDetails(movie: movie),
            childCount: 1
          ))
        ],
      ),
    );
  }
}

class _MovieDetails extends StatelessWidget {

  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //* Titulo, OverView y Rating
        _TitleAndOverview(size: size, movie: movie, textStyle: textStyle),

        // * Generos de la película
        _Genres(movie: movie),

        //* Actores de la película
        ActorsByMovie(movieId: movie.id.toString()),

        const SizedBox(height: 50)
      ],
    );
  }
}

class _Genres extends StatelessWidget {
  const _Genres({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            ...movie.genreIds.map((gender) => Container(
              margin: const EdgeInsets.only(right: 10),
              // * Se podria cambiar el widget Chip por un button
              // * y al darle click al genero llamar al endpoint
              // * Get movie/{movie_id}/similar
              child: Chip(
                label: Text(gender),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class _TitleAndOverview extends StatelessWidget {
  const _TitleAndOverview({
    required this.size,
    required this.movie,
    required this.textStyle,
  });

  final Size size;
  final Movie movie;
  final TextTheme textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // * Imagen
          ClipRRect(
            borderRadius: BorderRadiusDirectional.circular(20),
            child: Image.network(
              movie.posterPath,
              width: size.width * 0.3,
            ),
          ),

          const SizedBox(width: 10),

          // * Title, Description, Rating
          SizedBox(
            width: (size.width - 40) * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text( movie.title, style: textStyle.titleLarge ),
                Text( movie.overview ),

                const SizedBox(height: 10),

                MovieRating(voteAverage: movie.voteAverage),

                Row(
                  children: [

                    const Text('Estrenos:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    Text(HumanFormats.shortDate(movie.releaseDate))
                  ],
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}

// * FutureProvider.family => me permite mandar un argumento que es el id de la pelicula

final isFavoriteProvider = FutureProvider.family.autoDispose((ref, int movieId) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return localStorageRepository.isMovieFavorite(movieId); // si esta en favorito
});

class _CustomSliverAppBar extends ConsumerWidget {

  final Movie movie;

  const _CustomSliverAppBar({
    required this.movie
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final isFavoriteFuture = ref.watch(isFavoriteProvider(movie.id));

    // * Tengo las dimensiones del dispositivo fisico conel MediaQuery
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () async {

            // ref.read(localStorageRepositoryProvider).toggleFavorite(movie);
            await ref.read(favoriteMoviesProvider.notifier).toggleFavorite(movie);

            ref.invalidate(isFavoriteProvider(movie.id));

          }, 
          icon: isFavoriteFuture.when(
            data: (isFavorite) => isFavorite
              ? const Icon(Icons.favorite_rounded, color: Colors.red)
              : const Icon(Icons.favorite_border), 
            error: ( _, __) => throw UnimplementedError(), 
            loading: () => const CircularProgressIndicator(strokeWidth: 2)
          ),
          // icon: const Icon(Icons.favorite_border),
          // icon: const Icon(Icons.favorite_rounded, color: Colors.red)
        ),
      ],
      shadowColor: Colors.red,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        // title: Text(
        //   movie.title,
        //   style: const TextStyle(fontSize: 20),
        //   textAlign: TextAlign.start,
        // ),
        background: Stack(
          children: [

            // * Imagen
            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if ( loadingProgress != null ) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
            ),

            // * Aplicar gradientes para el icono de favoritos
            const _CustomGradient(
              begin: Alignment.topRight, 
              end: Alignment.bottomLeft,
              stops: [0.0, 0.2], 
              colors: [
                Colors.black54,
                Colors.transparent,
              ]
            ),
            

            // * Aplicar gradientes para fondos claros de la imagen
            const _CustomGradient(
              begin: Alignment.topCenter, 
              end: Alignment.bottomCenter, 
              stops: [0.8, 1.0], 
              colors: [
                Colors.transparent,
                Colors.black54
              ]
            ),

            // * Aplicar gradientes para la flechita del back
            const _CustomGradient(
              begin: Alignment.topLeft,
              stops: [0.0, 0.3], 
              colors: [
                Colors.black87,
                Colors.transparent,
              ]
            ),

          ],
        ),
      ),
    );
  }
}

class _CustomGradient extends StatelessWidget {

  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;


  const _CustomGradient({
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    required this.stops,
    required this.colors
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end, 
            stops: stops,
            colors: colors
          ),
        )
      ),
    );
  }
}
```

#### 13 - Creamos el archivo `actors_by_movie.dart` y la carpeta `actors`, dentro de `presentation -> widgets`

```dart
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActorsByMovie extends ConsumerWidget {

  final String movieId; 

  const ActorsByMovie({
    super.key, 
    required this.movieId
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final actorsByMovie = ref.watch( actorsByMovieProvider );

    // * Loadingactors
    if ( actorsByMovie[movieId] == null ) {
      return Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 50),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final actors = actorsByMovie[movieId];

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors!.length,
        itemBuilder: (context, index) {
          final actor = actors[index];

          return Container(
            padding: const EdgeInsets.all(8.0),
            width: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // * Actor photo
                FadeInRight(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FadeInImage(
                      height: 180,
                      width: 135,
                      fit: BoxFit.cover,
                      image: NetworkImage(actor.profilePath),
                      placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
                    )
                  ),
                ),

                // * Nombre
                const SizedBox(height: 5),

                Text(actor.name, maxLines: 2),
                Text(
                  actor.character ?? '', 
                  maxLines: 2,
                  style: const TextStyle( fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
```

#### 14 - Agregamos en el archivo `main.dart` el inicializar `initializeDateFormatting`


```Dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cinemapedia/config/router/app_router.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(
    const ProviderScope(child: MainApp())
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    initializeDateFormatting();   // -> Se agrego initializeDateFormatting

    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}

```

## Agregamos nuevas entity, datasource y repositorie

#### Creamos el entity Video , para ver los videos de youtube

- Creamos el archivo `video.dart`, en la carpeta `domain -> entities`

```dart
class Video {

  final String id;
  final String name;
  final String youtubeKey;
  final DateTime publishedAt;

  Video({
    required this.id,
    required this.name,
    required this.youtubeKey,
    required this.publishedAt
  });

}
```

#### Creamos el modelo `movie_video.dart`

- Copiamos el response del api en postman `https://api.themoviedb.org/3/movie/460465/videos?api_key=xxx&language=es-ES`

- Vamos a `https://app.quicktype.io/` y pegamos el response

```dart
class MoviedbVideosResponse {
    MoviedbVideosResponse({
        required this.id,
        required this.results,
    });

    final int id;
    final List<Result> results;

    factory MoviedbVideosResponse.fromJson(Map<String, dynamic> json) => MoviedbVideosResponse(
        id: json["id"],
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class Result {
    Result({
        required this.iso6391,
        required this.iso31661,
        required this.name,
        required this.key,
        required this.site,
        required this.size,
        required this.type,
        required this.official,
        required this.publishedAt,
        required this.id,
    });

    final String iso6391;
    final String iso31661;
    final String name;
    final String key;
    final String site;
    final int size;
    final String type;
    final bool official;
    final DateTime publishedAt;
    final String id;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        iso6391: json["iso_639_1"],
        iso31661: json["iso_3166_1"],
        name: json["name"],
        key: json["key"],
        site: json["site"],
        size: json["size"],
        type: json["type"],
        official: json["official"],
        publishedAt: DateTime.parse(json["published_at"]),
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "iso_639_1": iso6391,
        "iso_3166_1": iso31661,
        "name": name,
        "key": key,
        "site": site,
        "size": size,
        "type": type,
        "official": official,
        "published_at": publishedAt.toIso8601String(),
        "id": id,
    };
}

```

#### Creamos el mapper `movie_video.dart`

```dart
import 'package:cinemapedia/infrastructure/models/moviedb/movie_video.dart';

import '../../domain/entities/video.dart';

class VideoMapper {

  static moviedbVideoToEntity( Result moviedbVideo) => Video(

    id: moviedbVideo.id,
    name: moviedbVideo.name,
    publishedAt: moviedbVideo.publishedAt,
    youtubeKey: moviedbVideo.key
  );

}
```



#### Agregamos las nuevas funcionalidades de `getSimilarMovies` y `getYoutubeVideosById` en `datasources`, en `domain -> datasources`

```dart
import '../entities/entities.dart';


abstract class MoviesDatasource {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });

  Future<List<Movie>> getUpcoming({ int page = 1 });

  Future<List<Movie>> getTopRated({ int page = 1 });
  
  Future<Movie> getMovieById( String id );

  Future<List<Movie>> searchMovies( String query );

  Future<List<Movie>> getSimilarMovies( int movieId );    // -> Se agrego nueva

  Future<List<Video>> getYoutubeVideosById( int movieId );    // -> Se agrego nueva
}
```

#### Agregamos las nuevas funcionalidades de `getSimilarMovies` y `getYoutubeVideosById` en `repositories`, en `domain -> repositories`

```dart

import '../entities/entities.dart';

abstract class MoviesRepository {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });

  Future<List<Movie>> getUpcoming({ int page = 1 });

  Future<List<Movie>> getTopRated({ int page = 1 });

  Future<Movie> getMovieById( String id );

  Future<List<Movie>> searchMovies( String query );

  Future<List<Movie>> getSimilarMovies( int movieId );

  Future<List<Video>> getYoutubeVideosById( int movieId );
}
```

#### Agregamos las implementaciones de `getSimilarMovies` y `getYoutubeVideosById` en `datasources`, en `infrastructure -> datasources`

```dart

import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/entities/video.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/mappers/video_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_details.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_video.dart';
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
  
  @override
  Future<Movie> getMovieById(String id) async {
    final response = await dio.get('/movie/$id');
    if ( response.statusCode != 200 ) throw Exception('Movie with id: $id not found ');

    final movieDetails = MovieDetails.fromJson(response.data);
    final Movie movie = MovieMapper.movieDetailsToEntity(movieDetails);
    return movie;
  }
  
  @override
  Future<List<Movie>> searchMovies(String query) async {

    if( query.isEmpty) return [];
    
    final response = await dio.get('/search/movie',
      queryParameters: {
        'query': query
      }
    );

   return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    final response = await dio.get('/movie/$movieId/similar');
    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    final response = await dio.get('/movie/$movieId/videos');
    final moviedbVideoResponse = MoviedbVideosResponse.fromJson(response.data);
    final videos = <Video>[];

    for(final moviedbVideo in moviedbVideoResponse.results) {
      if ( moviedbVideo.site == 'Youtube' ) {
        final video = VideoMapper.moviedbVideoToEntity(moviedbVideo);
        videos.add(video);
      }
    }

    return videos;
  }
}
```

#### Agregamos las implementaciones de `getSimilarMovies` y `getYoutubeVideosById` en `movie_repository_impl.dart`, en `infrastructure -> repositories`

```dart


import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/entities/video.dart';
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
  
  @override
  Future<Movie> getMovieById(String id) {
    return datasource.getMovieById(id);
  }
  
  @override
  Future<List<Movie>> searchMovies(String query) {
    return datasource.searchMovies(query);
  }

  @override   // -> Se agrego getSimilarMovies
  Future<List<Movie>> getSimilarMovies(int movieId) {
    return datasource.getSimilarMovies(movieId);
  }

  @override   // -> Se agrego getYoutubeVideosById
  Future<List<Video>> getYoutubeVideosById(int movieId) {
    return datasource.getYoutubeVideosById(movieId);
  }

}
```

#### Agregamos un nuevo widget llamado `movie_similar.dart`, en la carpeta `presentation -> wisgets -> movies`

```dart
import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// * FutureProvider.family => me permite mandar un argumento que es el id de la pelicula
final similarMoviesProvider = FutureProvider.family((ref, int movieId) {
  final movieRepository = ref.watch( movieRepositoryProvider );
  return movieRepository.getSimilarMovies(movieId);
});

class SimilarMovies extends ConsumerWidget {

  final int movieId;

  const SimilarMovies({
    super.key, 
    required this.movieId
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final similarMoviesFuture = ref.watch( similarMoviesProvider(movieId) );

    return similarMoviesFuture.when(
      data: ( movies ) => _Recomendations(movies: movies), 
      error: ( _, __ ) => const Center(child: Text('No se pudo cargar películas similares'),), 
      loading: () => const Center( child: CircularProgressIndicator(strokeWidth: 2))
    );

  }
}

class _Recomendations extends StatelessWidget {

  final List<Movie> movies;

  const _Recomendations({required this.movies});

  @override
  Widget build(BuildContext context) {

    if ( movies.isEmpty ) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: MovieHorizontalListview(
        title: 'Recomendaciones',
        movies: movies,
      ),

    );
  }
}

```

#### Agregamos en el archivo `movie_screen.dart`, en el widget `_MovieDetails`, las películas similares `SimilarMovies`

```dart
return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      //* Titulo, OverView y Rating
      _TitleAndOverview(size: size, movie: movie, textStyle: textStyle),

      // * Generos de la película
      _Genres(movie: movie),

      //* Actores de la película
      ActorsByMovie(movieId: movie.id.toString()),

      //* Películas Similares
      SimilarMovies(movieId: movie.id),   // -> Se agrego SimilarMovies

      const SizedBox(height: 50)
    ],
  );
```

#### Instalación del paquete youtube_player_flutter

Documentación: https://pub.dev/packages/youtube_player_flutter

- Instalación: 
```
flutter pub add youtube_player_flutter
```