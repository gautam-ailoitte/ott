part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeDataEntity homeData;
  final Map<String, List<VideoModel>> categoryVideos; // Updated to VideoModel
  final List<VideoModel> recentlyPlayedVideos; // Updated to VideoModel

  HomeLoaded(
    this.homeData, {
    this.categoryVideos = const {},
    this.recentlyPlayedVideos = const [],
  });
}

class HomeEmpty extends HomeState {}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
