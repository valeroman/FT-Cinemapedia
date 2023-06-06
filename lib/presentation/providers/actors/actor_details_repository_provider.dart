
import 'package:cinemapedia/infrastructure/repositories/actor_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/datasources/actor_moviedb_datasource.dart';

final actorDetailRepositoryProvider = Provider((ref) {

  return ActorRepositoryImpl(ActorMovieDbDatasource());

});