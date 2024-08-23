class GeoLocationCoordinates {
  final double latitude;
  final double longitude;

  GeoLocationCoordinates.raw({
    required this.latitude,
    required this.longitude,
  });

  factory GeoLocationCoordinates.fromJson(Map<String, Object?> json) {
    assert(json["latitude"] is num);
    assert(json["longitude"] is num);
    return GeoLocationCoordinates.raw(
      latitude: (json["latitude"]! as num).toDouble(),
      longitude: (json["longitude"]! as num).toDouble(),
    );
  }

  Map<String, Object?> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
