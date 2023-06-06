

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

        GoRoute(
          path: 'person/:id',
          name: ActorScreen.name,
          builder: (context, state) {
            final personId = state.params['id'] ?? 'no-id';
            return ActorScreen(personId: personId,);
            // return MovieScreen(movieId: movieId);
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