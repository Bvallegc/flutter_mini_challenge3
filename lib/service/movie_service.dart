import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api_config.dart';
import '../models/models.dart';


class MovieService {
  Future<ExploreData> getExploreData() async {
    final popMovies = await fetchMovies();

    return ExploreData(popMovies);
  }
  
  static Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse(
      '${ApiConfig.baseUrl}/movie/popular?api_key=${ApiConfig.apiKey}',
    ));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }

  static Future<List<Movie>> fetchPopMovies() async {
    final response = await http.get(Uri.parse(
      '${ApiConfig.baseUrl}/movie/popular?api_key=${ApiConfig.apiKey}',
    ));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }

   static Future<List<Movie>> fetchTopMovies() async {
    final response = await http.get(Uri.parse(
      '${ApiConfig.baseUrl}/movie/top_rated?api_key=${ApiConfig.apiKey}',
    ));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }
  static Future<List<Movie>> fetchNowPlayingMovies() async {
    final response = await http.get(Uri.parse(
      '${ApiConfig.baseUrl}/movie/now_playing?api_key=${ApiConfig.apiKey}',
    ));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }
  
  static Future<List<Movie>> fetchUpcomingMovies() async {
    final response = await http.get(Uri.parse(
      '${ApiConfig.baseUrl}/movie/upcoming?api_key=${ApiConfig.apiKey}',
    ));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }

  static Future<List<Movie>> movieSuggestion(String query) async {
  final response = await http.get(Uri.parse(
    '${ApiConfig.baseUrl}/search/movie?api_key=${ApiConfig.apiKey}&query=$query',
  ));
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> results = data['results'];
    return results.map((json) => Movie.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch movies');
  }
}

  Future<dynamic> searchMovies(String query) async {
    var url = Uri.parse('https://api.themoviedb.org/3/search/multi?api_key=${ApiConfig.apiKey}&query=$query');
    var response = await http.get(url);

    if (response.statusCode == 200) {
        return json.decode(response.body);
    } else {
        print('Failed to search');
        }
    }

  static Future<dynamic> actorDetails(int id) async {
    var url = Uri.parse('https://api.themoviedb.org/3/person/$id?api_key=${ApiConfig.apiKey}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
        return json.decode(response.body);
    } else {
        print('Failed to search');
        }
    }

  static Future<dynamic> movieDetails(int id) async {
    var url = Uri.parse('https://api.themoviedb.org/3/movie/$id?api_key=${ApiConfig.apiKey}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
        return json.decode(response.body);
    } else {
        print('Failed to search');
        }
    }
}
