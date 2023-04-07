# cinemapedia

A new Flutter project.

## Dev

1. Copiar el .env.template y renombrarlo a .env
2. Cambiar las variables de entorno (The MovieDB)


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

- Creamos el archivo `movies_datasource.dart` dentro de la carpeta `datasources`, la clase abstracta `MovieDatasource`, la cual no crea instancia de ella.

- Aqui defino como lucen los origenes de datos que pueden traer peliculas, normalmente son los métodos que voy a llamar para traer la data.

- La clase `MovieDatasource` defino el primer metodo `getNowPlaying`

```
import '../entities/movie.dart';

abstract class MovieDatasource {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

}
```

#### Repository

- Creamos el archivo `movies_repository.dart` dentro de la carpeta `repositories`, la clase abstracta `MovieRepository`, la cual no crea instancia de ella.

- El repositorio es quien llama al datasource, el repositorio es el que permite cambiar el datasource.

- La clase `MovieRepository` defino el primer metodo `getNowPlaying`

```
import '../entities/movie.dart';

abstract class MovieRepository {

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