

import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/helpers/human_formats.dart';
import '../../providers/actors/actor_details_repository_provider.dart';


// * FutureProvider.family => me permite mandar un argumento que es el id de la pelicula
final actorInfoProvider = FutureProvider.family((ref, String personId) {
  final actorInfoRepository = ref.watch( actorDetailRepositoryProvider );
  return actorInfoRepository.getActorDetailsById(personId);
});


class ActorScreen extends ConsumerWidget {

  static const name = 'actor-screen';

  final String personId;

  const ActorScreen({
    super.key, 
    required this.personId
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final actorInfoFutture = ref.watch( actorInfoProvider(personId) );

    return actorInfoFutture.when(
      data: ( actorDetails ) => _ActorInfo(actorDetails: actorDetails), 
      error: ( _, __ ) => const Center(child: Text('No se pudo cargar películas similares')),
      loading: () => const Center( child: CircularProgressIndicator(strokeWidth: 2))
    );

  }

}


class _ActorInfo extends StatelessWidget {
  final ActorDetails actorDetails;
  const _ActorInfo({
    required this.actorDetails
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar(actorDetails: actorDetails),
          SliverList(delegate: SliverChildBuilderDelegate(
            (context, index) => _Info(actorDetails: actorDetails),
            childCount: 1
          ))
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {

  final ActorDetails actorDetails;

  const _Info({required this.actorDetails});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //* Información personal
          SizedBox(
            width: size.width - 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text('Información Personal', style: textStyle.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 20),

                if ( actorDetails.name.isNotEmpty ) InfoDataActor(subTitle: 'Nombre', actorDetails: actorDetails.name),
                
                const SizedBox(height: 20),

                if ( actorDetails.birthday.toString().isNotEmpty ) InfoDataActor(subTitle: 'Fecha de nacimiento', actorDetails: HumanFormats.longDate(actorDetails.birthday).toString()),

                const SizedBox(height: 20),

                if ( actorDetails.placeOfBirth.isNotEmpty ) InfoDataActor(subTitle: 'Lugar de nacimiento', actorDetails: actorDetails.placeOfBirth),

                if ( actorDetails.deathday.isNotEmpty )   Column(children: [  const SizedBox(height: 20), InfoDataActor(subTitle: 'Fecha de ir al cielo', actorDetails: actorDetails.deathday)]),

                const SizedBox(height: 20),

                if ( actorDetails.biography.isNotEmpty ) InfoDataActor(subTitle: 'Biografía', actorDetails: actorDetails.biography),
                
                const SizedBox(height: 100)
                

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoDataActor extends StatelessWidget {

  final String subTitle;
  final String actorDetails;
  const InfoDataActor({
    super.key,
    required this.subTitle, 
    required this.actorDetails,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 5,
          offset: const Offset(0,3)
        )
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subTitle, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold )),
                Text(actorDetails, style: const TextStyle(color: Colors.black), textAlign: TextAlign.justify,),
              ],
            ),
          )
        ],
      ),
    );
  }
}


class _CustomSliverAppBar extends ConsumerWidget {

  final ActorDetails actorDetails;

  const _CustomSliverAppBar({
    required this.actorDetails
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // * Tengo las dimensiones del dispositivo fisico conel MediaQuery
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        background: Stack(
          children: [

            // * Imagen
            SizedBox.expand(
              child: Image.network(
                actorDetails.profilePath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if ( loadingProgress != null ) return const SizedBox();
                  return FadeIn(child: child);
                },
              ),
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