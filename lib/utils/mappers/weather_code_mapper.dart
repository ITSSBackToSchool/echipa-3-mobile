// lib/utils/mappers/weather_code_mapper.dart
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter/material.dart';

IconData iconForCode(int code, {bool isDay = true}) {
  // WMO codes (Open-Meteo):
  // 0 clear, 1-3 clouds, 45/48 fog, 51-57 drizzle, 61-67 rain,
  // 71-77 snow, 80-82 rain showers, 85-86 snow showers,
  // 95 thunderstorm, 96-99 thunder + hail
  if (code == 0) return isDay ? WeatherIcons.day_sunny : WeatherIcons.night_clear;
  if (code == 1 || code == 2 || code == 3) return isDay ? WeatherIcons.day_cloudy : WeatherIcons.night_alt_cloudy;
  if (code == 45 || code == 48) return WeatherIcons.fog;
  if (code >= 51 && code <= 57) return WeatherIcons.sprinkle;        // drizzle
  if (code >= 61 && code <= 67) return WeatherIcons.rain;
  if (code >= 71 && code <= 77) return WeatherIcons.snow;
  if (code >= 80 && code <= 82) return WeatherIcons.showers;
  if (code == 85 || code == 86) return WeatherIcons.snow_wind;
  if (code == 95) return WeatherIcons.thunderstorm;
  if (code == 96 || code == 99) return WeatherIcons.storm_showers;
  return WeatherIcons.na;
}
