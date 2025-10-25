// lib/utils/models/weather_response.dart
class WeatherResponse {
  final double latitude;
  final double longitude;
  final CurrentWeather current;
  final DailyWeather daily;

  WeatherResponse({
    required this.latitude,
    required this.longitude,
    required this.current,
    required this.daily,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      current: CurrentWeather.fromJson(json['current']),
      daily: DailyWeather.fromJson(json['daily']),
    );
  }
}

class CurrentWeather {
  final String time;
  final int interval;
  final double temperature2m;
  final int relativeHumidity2m;
  final double precipitation;
  final double surfacePressure;
  final double windSpeed10m;
  final double windDirection10m;
  final int weatherCode;

  CurrentWeather({
    required this.time,
    required this.interval,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.precipitation,
    required this.surfacePressure,
    required this.windSpeed10m,
    required this.windDirection10m,
    required this.weatherCode,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: json['time'] as String,
      interval: json['interval'] as int,
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num).toInt(),
      precipitation: (json['precipitation'] as num).toDouble(),
      surfacePressure: (json['surface_pressure'] as num).toDouble(),
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
      windDirection10m: (json['wind_direction_10m'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
    );
  }
}

class DailyWeather {
  final List<String> time;               // date ISO
  final List<double> temperature2mMax;
  final List<double> temperature2mMin;
  final List<int> weatherCode;           // <--- lista cerută

  DailyWeather({
    required this.time,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.weatherCode,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    List<T> castList<T>(List<dynamic> xs) => xs.map((e) => (e as num).toDouble()).cast<T>().toList();

    return DailyWeather(
      time: (json['time'] as List).cast<String>(),
      temperature2mMax: (json['temperature_2m_max'] as List).map((e) => (e as num).toDouble()).toList(),
      temperature2mMin: (json['temperature_2m_min'] as List).map((e) => (e as num).toDouble()).toList(),
      weatherCode: (json['weather_code'] as List).map((e) => (e as num).toInt()).toList(),
    );
  }
}
