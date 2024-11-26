import 'dart:convert';
import 'package:http/http.dart' as http;

class Weather {
  Weather({
    required this.city,
    required this.temperature,
    required this.description,
    required this.windSpeed,
    required this.pressure,
    required this.humidity,
  });

  final String city;
  final double temperature;
  final String description;
  final double windSpeed;
  final int pressure;
  final int humidity;

  factory Weather.fromJson(Map<String, dynamic> json) {
    final cityName = json['city']['name'];
    final temp = json['list'][0]['main']['temp'];
    final description = json['list'][0]['weather'][0]['description'];
    final wind = json['list'][0]['wind']['speed'];
    final press = json['list'][0]['main']['pressure'];
    final humid = json['list'][0]['main']['humidity'];

    return Weather(
      city: cityName,
      temperature: temp.toDouble(),
      description: description,
      windSpeed: wind.toDouble(),
      pressure: press,
      humidity: humid,
    );
  }
}

Future<Weather> fetchWeather(String city) async {
  final apiKey = 'd24a1819fb593ae3ba8f1ad9edcaca51';
  final url = 'https://api.openweathermap.org/data/2.5/forecast?q=${city}&appid=${apiKey}&units=metric';

  print(url);
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    print('Ответ: ${response.body}');
    return Weather.fromJson(json.decode(response.body));
  } else {
    print('Ошибка: ${response.body}');
    throw Exception('Не удалось загрузить данные о погоде');
  }
}

class FutureWeather {
  FutureWeather({
    required this.city,
    required this.midTemperature,
  });

  final String city;
  final double midTemperature; // средняя температура за день

  factory FutureWeather.fromJson(Map<String, dynamic> json, int i) {
    final cityName = json['city']['name'];
    final morTemp = json['list'][i]['main']['temp'];
    final dayTemp = json['list'][i + 4]['main']['temp'];
    final eveTemp = json['list'][i + 7]['main']['temp'];
    final midTemp = (morTemp + dayTemp + eveTemp)/3;

    return FutureWeather(
      city: cityName,
      midTemperature: midTemp,
    );
  }
}


Future<FutureWeather> fetchFutureWeather(String city, int day) async {
  final apiKey = 'd24a1819fb593ae3ba8f1ad9edcaca51';
  final url = 'https://api.openweathermap.org/data/2.5/forecast?q=${city}&appid=${apiKey}&units=metric';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    return FutureWeather.fromJson(data, day);
  } else {
    throw Exception('Не удалось загрузить данные о погоде');
  }
}

class HourlyWeather { // погода утром, днем и вечером
  HourlyWeather({
    required this.city,
    required this.morningTemp,
    required this.morningDescription,
    required this.dayTemp,
    required this.dayDescription,
    required this.eveningTemp,
    required this.eveningDescription,
  });

  final String city;
  final double morningTemp;
  final String morningDescription;
  final double dayTemp;
  final String dayDescription;
  final double eveningTemp;
  final String eveningDescription;

  factory HourlyWeather.fromJson(Map<String, dynamic> json, int day) {
    final cityName = json['city']['name'];
    final list = json['list'];
    int baseIndex = day == 0 ? 0 : 8;

    // индексы в пределах диапазона
    final morningTemp = (list.isNotEmpty && baseIndex < list.length)
        ? list[baseIndex]['main']['temp']
        : null;
    final morDesc = (list.isNotEmpty && baseIndex < list.length)
        ? list[baseIndex]['weather'][0]['description']
        : null;
    final dayTemp = (list.isNotEmpty && baseIndex + 4 < list.length)
        ? list[baseIndex + 4]['main']['temp']
        : null;
    final dayDesc = (list.isNotEmpty && baseIndex + 4 < list.length)
        ? list[baseIndex + 4]['weather'][0]['description']
        : null;
    final eveningTemp = (list.isNotEmpty && baseIndex + 7 < list.length)
        ? list[baseIndex + 7]['main']['temp']
        : null;
    final eveDesc = (list.isNotEmpty && baseIndex + 7 < list.length)
        ? list[baseIndex + 7]['weather'][0]['description']
        : null;

    return HourlyWeather(
      city: cityName,
      morningTemp: morningTemp?.toDouble() ?? 0.0,
      morningDescription: morDesc ?? 'Нет данных',
      dayTemp: dayTemp?.toDouble() ?? 0.0,
      dayDescription: dayDesc ?? 'Нет данных',
      eveningTemp: eveningTemp?.toDouble() ?? 0.0,
      eveningDescription: eveDesc ?? 'Нет данных',
    );
  }
}

Future<HourlyWeather> fetchHourlyWeather(String city, int day) async {
  final apiKey = 'd24a1819fb593ae3ba8f1ad9edcaca51';
  final url = 'https://api.openweathermap.org/data/2.5/forecast?q=${city}&appid=${apiKey}&units=metric';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return HourlyWeather.fromJson(data, day);
  } else {
    throw Exception('Не удалось загрузить данные о погоде');
  }
}

//final apiKey = '35962457b60543f8a65bb437cef8cce1';
//final url = 'https://api.weatherbit.io/v2.0/current?city=$city&key=$apiKey&units=metric';
