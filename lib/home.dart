import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class HomeScene extends StatefulWidget {
  const HomeScene({super.key});

  @override
  State<HomeScene> createState() => _HomeSceneState();
}

class _HomeSceneState extends State<HomeScene> {
  Weather? weatherToday;
  HourlyWeather? hourlyWeatherToday;
  HourlyWeather? hourlyWeatherTomorrow;
  List<FutureWeather?> futureWeatherList = [];
  DateTime today = DateTime.now();

  List<String> months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  List<String> weekdays = [
    'вс',
    'пн',
    'вт',
    'ср',
    'чт',
    'пт',
    'сб',
  ];

  List<String> cities = [
    'Ханты-Мансийск',
    'Москва',
    'Нижневартовск',
    'Симферополь',
    'Радужный',
    'Владивосток'
  ];

  List<String> timePeriod = [
    'На завтра',
    'На три дня',
    'На неделю',
  ];

  Map<String, Map<String, String>> descriptions = { // описание погоды на русском + иконки
    'clear sky': {'description': 'ясно', 'icon': 'sunny'},
    'few clouds': {
      'description': 'небольшая облачность',
      'icon': 'cloud_outlined'
    },
    'light snow': {'description': 'небольшой снег', 'icon': 'cloudy_snowing'},
    'scattered clouds': {
      'description': 'рассеянная облачность',
      'icon': 'cloud_off'
    },
    'broken clouds': {'description': 'облачно', 'icon': 'cloud'},
    'overcast clouds': {
      'description': 'плотная облачность',
      'icon': 'cloud_circle'
    },
    'shower rain': {
      'description': 'небольшой дождь',
      'icon': 'water_drop_outlined'
    },
    'rain': {'description': 'дождь', 'icon': 'water_drop'},
    'thunderstorm': {'description': 'гроза', 'icon': 'thunderstorm'},
    'snow': {'description': 'снег', 'icon': 'cloudy_snowing'},
    'mist': {'description': 'туман', 'icon': 'foggy'},
    'smoke': {'description': 'дым', 'icon': 'air'},
    'haze': {'description': 'пелена', 'icon': 'cloud_circle'},
    'dust': {'description': 'пыль', 'icon': 'wind_power'},
    'fog': {'description': 'туман', 'icon': 'foggy'},
    'sand': {'description': 'песок', 'icon': 'beach_access'},
    'ash': {'description': 'пепел', 'icon': 'air'},
    'squall': {'description': 'штормовой ветер', 'icon': 'air'},
    'tornado': {'description': 'торнадо', 'icon': 'tornado'},
    'drizzle': {'description': 'мелкий дождь', 'icon': 'water_drop_outlined'},
    'freezing rain': {
      'description': 'замерзающий дождь',
      'icon': 'invert_colors'
    },
    'rain and snow': {
      'description': 'дождь со снегом',
      'icon': 'cloudy_snowing'
    },
    'snow and rain': {'description': 'снег с дождем', 'icon': 'cloudy_snowing'},
    'sleet': {'description': 'слякоть', 'icon': 'water'},
  };

  IconData getWeatherIcon(String? description) { // получаем иконку
    if (description == null || !descriptions.containsKey(description)) {
      return Icons.error;
    }

    String iconKey = descriptions[description]!['icon'] ?? 'error';
    switch (iconKey) {
      case 'sunny':
        return Icons.sunny;
      case 'cloud_outlined':
        return Icons.cloud_outlined;
      case 'cloud_off':
        return Icons.cloud_off;
      case 'cloud':
        return Icons.cloud;
      case 'cloud_circle':
        return Icons.cloud_circle;
      case 'water_drop_outlined':
        return Icons.water_drop_outlined;
      case 'water_drop':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'cloudy_snowing':
        return Icons.cloudy_snowing;
      case 'foggy':
        return Icons.foggy;
      case 'air':
        return Icons.air;
      case 'wind_power':
        return Icons.wind_power;
      case 'beach_access':
        return Icons.beach_access;
      case 'tornado':
        return Icons.tornado;
      case 'invert_colors':
        return Icons.invert_colors;
      default:
        return Icons.error;
    }
  }

  String selectedCity = 'Ханты-Мансийск';
  String selectedPeriod = 'На три дня';

  @override
  void initState() {
    super.initState();
    _loadWeatherToday();
  }

  Future<void> _loadWeatherToday() async {
    try {
      Weather fetchedWeather = await fetchWeather(selectedCity);
      setState(() {
        weatherToday = fetchedWeather;
      });
      await _loadHourlyWeather(0); // загрузка погоды на сегодня по часам
      await _loadFutureWeather(); // загрузка погоды на следующие дни
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки погоды: $e')),
      );
    }
  }

  Future<void> _loadHourlyWeather(int i) async {
    try {
      HourlyWeather fetchedHourlyWeather =
          await fetchHourlyWeather(selectedCity, i);
      setState(() {
        i == 0
            ? hourlyWeatherToday = fetchedHourlyWeather // погода по часам на СЕГОДНЯ
            : hourlyWeatherTomorrow = fetchedHourlyWeather; // погода по часам на ЗАВТРА
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки погоды: $e')),
      );
    }
  }

  Future<void> _loadFutureWeather() async {
    futureWeatherList.clear();
    int days = _getForecastDays(); // к-во дней для прогноза в будущем
    for (int i = 1; i <= days; i++) {
      try {
        FutureWeather fetchedFutureWeather =
            await fetchFutureWeather(selectedCity, i);
        futureWeatherList.add(fetchedFutureWeather);
      } catch (e) {
        futureWeatherList.add(null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки погоды на день $i: $e')),
        );
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Weather',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 103, 71, 136),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildCitySelector(),
                SizedBox(height: 20),
                _buildCurrentWeather(),
                SizedBox(height: 20),
                _buildWeatherForecast(width, 0),
                SizedBox(height: 20),
                _buildWeatherDetails(),
                _buildPeriodSelector(),
                if (selectedPeriod != 'На завтра') ...[ // если смотрим погоду на завтра, то выводим погоду по часам
                  for (int i = 0; i < futureWeatherList.length; i++)
                    _buildDailyForecast(width, today.add(Duration(days: i + 1)),
                        futureWeatherList[i]),
                ] else ...[  // иначе выводим среднюю погоду на день для каждого дня недели
                  _buildWeatherForecast(width, 1)
                ],
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? engToRus(String? str) { // переводим описание погоды
    if (str == null) return null;
    if (descriptions.containsKey(str)) {
      return descriptions[str]?['description'];
    } else {
      return 'Неизвестно';
    }
  }

  int _getForecastDays() { // получаем к-во дней для прогноза (завтра, 3 дня или неделя)
    return selectedPeriod == 'На завтра'
        ? 1
        : selectedPeriod == 'На три дня'
            ? 3
            : 7;
  }

  Widget _buildCitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: selectedCity,
          style: TextStyle(color: Colors.white, fontSize: 20),
          dropdownColor: Color.fromARGB(255, 103, 71, 136),
          items: cities.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCity = newValue!;
              _loadWeatherToday();
              if (selectedPeriod == 'На завтра') _loadHourlyWeather(1); // загрузка погоды на завтра по часам
            });
          },
        ),
        Text(
          '${today.day} ${months[today.month - 1]}, ${weekdays[(today.weekday - 1) % 7 + 1]}', // сегодняшняя дата справа сверху
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildCurrentWeather() { // погода на данный момент
    return Container(
      width: 266,
      height: 149,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 103, 71, 136),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '${weatherToday?.temperature.toStringAsFixed(1)}°C',
                  style: TextStyle(color: Colors.white, fontSize: 50),
                ),
              ],
            ),
            Icon(
              getWeatherIcon(weatherToday?.description),
              color: Colors.white,
              size: 40,
            ),
            Text(
              '${engToRus(weatherToday?.description)}', // описание погоды
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherForecast(double width, int i) { // погода по часам
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildWeatherCard(width, 'Утро', i == 0 // если выводим почасовую погоду на СЕГОДНЯ
            ? '${hourlyWeatherToday?.morningTemp.toStringAsFixed(1)}°C'
            : '${hourlyWeatherTomorrow?.morningTemp.toStringAsFixed(1)}°C', // почасовая погода на завтра
            i == 0 ? hourlyWeatherToday?.morningDescription : hourlyWeatherTomorrow?.morningDescription),
        _buildWeatherCard(width, 'День', i == 0
            ? '${hourlyWeatherToday?.dayTemp.toStringAsFixed(1)}°C'
            : '${hourlyWeatherTomorrow?.dayTemp.toStringAsFixed(1)}°C',
            i == 0 ? hourlyWeatherToday?.dayDescription : hourlyWeatherTomorrow?.dayDescription),
        _buildWeatherCard(width, 'Вечер', i == 0
            ? '${hourlyWeatherToday?.eveningTemp.toStringAsFixed(1)}°C'
            : '${hourlyWeatherTomorrow?.eveningTemp.toStringAsFixed(1)}°C',
            i == 0 ? hourlyWeatherToday?.eveningDescription : hourlyWeatherTomorrow?.eveningDescription),
      ],
    );
  }


  Widget _buildWeatherCard(double width, String dayTime, String temp, String? description) { // карточки для утра, дня и вечера
    return Container(
      width: (width / 3.5),
      height: 100,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 103, 71, 136),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(dayTime, style: TextStyle(color: Colors.white, fontSize: 18)),
            Icon(
              getWeatherIcon(description),
              color: Colors.white,
              size: 40,
            ),
            Text(temp, style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() { // доп. инфа по погоде на данный момент
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 103, 71, 136),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Скорость ветра', '${weatherToday?.windSpeed} м/с'),
            _buildDetailRow('Давление', '${weatherToday?.pressure} мм рт. ст.'),
            _buildDetailRow('Влажность', '${weatherToday?.humidity}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white, fontSize: 18)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() { // селектор периода (на завтра, на 3 дня и на неделю)
    return Align(
      alignment: Alignment.bottomLeft,
      child: DropdownButton<String>(
        value: selectedPeriod,
        style: TextStyle(color: Colors.white, fontSize: 20),
        dropdownColor: Color.fromARGB(255, 103, 71, 136),
        items: timePeriod.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedPeriod = newValue!;
            selectedPeriod == 'На завтра'
                ? _loadHourlyWeather(1)
                : _loadFutureWeather();
          });
        },
      ),
    );
  }

  Widget _buildDailyForecast(
      double width, DateTime date, FutureWeather? futureWeather) {
    String dayOfWeek = weekdays[(date.weekday) % 7];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 103, 71, 136),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${date.day}, $dayOfWeek',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text('${futureWeather?.midTemperature.toStringAsFixed(1)}°C',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
