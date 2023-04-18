
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