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