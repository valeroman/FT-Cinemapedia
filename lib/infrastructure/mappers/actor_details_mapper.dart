




import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:cinemapedia/infrastructure/models/actors/actor_details.dart';

class ActorDetailsMapper {

  static ActorDetails actorDetailToEntry(ActorDetailsDB actorDetailsdb) => 
  ActorDetails(
    biography: actorDetailsdb.biography,
    birthday: actorDetailsdb.birthday != null ? actorDetailsdb.birthday! : DateTime.now(),
    // moviedb.releaseDate != null ? moviedb.releaseDate! : DateTime.now()
    deathday: actorDetailsdb.deathday,
    id: actorDetailsdb.id,
    imdbId: actorDetailsdb.imdbId,
    name: actorDetailsdb.name,
    placeOfBirth: actorDetailsdb.placeOfBirth,
    profilePath: actorDetailsdb.profilePath != ''
      ? 'https://image.tmdb.org/t/p/w500/${ actorDetailsdb.profilePath }'
      : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTC0HlQ_ckX6HqCAlqroocyRDx_ZRu3x3ezoA&usqp=CAU'
  );
}
