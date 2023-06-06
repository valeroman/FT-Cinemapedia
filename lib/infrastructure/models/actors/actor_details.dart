
class ActorDetailsDB {
    ActorDetailsDB({
        required this.biography,
        required this.birthday,
        this.deathday,
        required this.id,
        required this.imdbId,
        required this.name,
        required this.placeOfBirth,
        this.profilePath,
    });

    final String biography;
    final DateTime? birthday;
    final dynamic deathday;
    final int id;
    final String imdbId;
    final String name;
    final String placeOfBirth;
    final String? profilePath;

    factory ActorDetailsDB.fromJson(Map<String, dynamic> json) => ActorDetailsDB(
        biography: json["biography"],
        birthday: json["birthday"] != null && json["birthday"].toString().isNotEmpty
          ? DateTime.parse(json["birthday"])
          : null,
        // birthday: DateTime.parse(json ["birthday"]),
        deathday: json["deathday"] ?? '',
        id: json["id"],
        imdbId: json["imdb_id"] ?? '',
        name: json["name"],
        placeOfBirth: json["place_of_birth"] ?? '',
        profilePath: json["profile_path"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "biography": biography,
        "birthday": "${birthday!.year.toString().padLeft(4, '0')}-${birthday!.month.toString().padLeft(2, '0')}-${birthday!.day.toString().padLeft(2, '0')}",
        "deathday": deathday,
        "id": id,
        "imdb_id": imdbId,
        "name": name,
        "place_of_birth": placeOfBirth,
        "profile_path": profilePath,
    };
}
