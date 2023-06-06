import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/actors/actor_details_provider.dart';



class ActorScreen extends ConsumerStatefulWidget {
  
  static const name = 'actor-screen';

  final String personId;
    
  const ActorScreen({
    super.key, 
    required this.personId
  });

  @override
  ActorScreenState createState() => ActorScreenState();
}

class ActorScreenState extends ConsumerState<ActorScreen> {

  @override
  void initState() {
    super.initState();

    ref.read(actorDetailsProvider.notifier).getActorDetail(widget.personId);
  }

  @override
  Widget build(BuildContext context) {

    final ActorDetails? actorDetail = ref.watch( actorDetailsProvider )[widget.personId];

    if ( actorDetail == null ) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return const Scaffold(
      body: Placeholder(),
    );
  }
}