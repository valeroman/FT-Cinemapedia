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

        // * Video de la película (si tiene)
        VideoFromMovie(movieId: movie.id),

        //* Películas Similares
        SimilarMovies(movieId: movie.id),

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