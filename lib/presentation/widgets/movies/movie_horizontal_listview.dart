

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/movie.dart';

class MovieHorizontalListview extends StatefulWidget {

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
  State<MovieHorizontalListview> createState() => _MovieHorizontalListviewState();
}

class _MovieHorizontalListviewState extends State<MovieHorizontalListview> {

  // * El controller es como la barrita de youtube, que se puede saber cuando esta en pausa,
  // * cuando se esta al final del video etc.
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if ( widget.loadNextPage == null ) return;

      if ( (scrollController.position.pixels + 200) >= scrollController.position.maxScrollExtent  ) {
        // 
        //print('Load next movier');

        widget.loadNextPage!();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Column(
        children: [

          if ( widget.title != null || widget.subTitle != null )
          _Title(title: widget.title, subTitle: widget.subTitle),

          Expanded(
            child: ListView.builder(
              controller: scrollController, //* Asociamos el controller del ListView al listener
              itemCount: widget.movies.length,
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