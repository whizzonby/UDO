import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class HomeState {
  final bool isLoading;
  final String coupleName;
  final int? daysUntil;
  final DateTime? eventDate;
  final String? destination;
  final String? venueName;
  final String? receptionVenueName;
  final String? ceremonyTime;
  final String? receptionTime;
  final String? dressCode;
  final String? websiteUrl;
  final String? guestPortalUrl;
  final String? hashtag;
  final String? coverPhotoPath;
  final String? couplePhotoPath;
  final String? galleryPreviewPhotoPath;
  final int galleryPhotoCount;
  final Map<String, dynamic>? weather;
  final int totalGuests;
  final int confirmedGuests;
  final int pendingTasks;
  final List<Map<String, dynamic>> upcomingTasks;
  final List<Map<String, dynamic>> recentActivity;
  final Map<String, dynamic> commandCenter;
  final double? budgetSpent;
  final double? budgetTotal;
  final String? error;
  final bool isOffline;
  final DateTime? cachedAt;

  const HomeState({
    this.isLoading = false,
    this.coupleName = '',
    this.daysUntil,
    this.eventDate,
    this.destination,
    this.venueName,
    this.receptionVenueName,
    this.ceremonyTime,
    this.receptionTime,
    this.dressCode,
    this.websiteUrl,
    this.guestPortalUrl,
    this.hashtag,
    this.coverPhotoPath,
    this.couplePhotoPath,
    this.galleryPreviewPhotoPath,
    this.galleryPhotoCount = 0,
    this.weather,
    this.totalGuests = 0,
    this.confirmedGuests = 0,
    this.pendingTasks = 0,
    this.upcomingTasks = const [],
    this.recentActivity = const [],
    this.commandCenter = const {},
    this.budgetSpent,
    this.budgetTotal,
    this.error,
    this.isOffline = false,
    this.cachedAt,
  });

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  HomeState copyWith({
    bool? isLoading,
    String? coupleName,
    int? daysUntil,
    DateTime? eventDate,
    String? destination,
    String? venueName,
    String? receptionVenueName,
    String? ceremonyTime,
    String? receptionTime,
    String? dressCode,
    String? websiteUrl,
    String? guestPortalUrl,
    String? hashtag,
    String? coverPhotoPath,
    String? couplePhotoPath,
    String? galleryPreviewPhotoPath,
    int? galleryPhotoCount,
    Map<String, dynamic>? weather,
    int? totalGuests,
    int? confirmedGuests,
    int? pendingTasks,
    List<Map<String, dynamic>>? upcomingTasks,
    List<Map<String, dynamic>>? recentActivity,
    Map<String, dynamic>? commandCenter,
    double? budgetSpent,
    double? budgetTotal,
    String? error,
    bool? isOffline,
    DateTime? cachedAt,
  }) =>
      HomeState(
        isLoading: isLoading ?? this.isLoading,
        coupleName: coupleName ?? this.coupleName,
        daysUntil: daysUntil ?? this.daysUntil,
        eventDate: eventDate ?? this.eventDate,
        destination: destination ?? this.destination,
        venueName: venueName ?? this.venueName,
        receptionVenueName: receptionVenueName ?? this.receptionVenueName,
        ceremonyTime: ceremonyTime ?? this.ceremonyTime,
        receptionTime: receptionTime ?? this.receptionTime,
        dressCode: dressCode ?? this.dressCode,
        websiteUrl: websiteUrl ?? this.websiteUrl,
        guestPortalUrl: guestPortalUrl ?? this.guestPortalUrl,
        hashtag: hashtag ?? this.hashtag,
        coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
        couplePhotoPath: couplePhotoPath ?? this.couplePhotoPath,
        galleryPreviewPhotoPath:
            galleryPreviewPhotoPath ?? this.galleryPreviewPhotoPath,
        galleryPhotoCount: galleryPhotoCount ?? this.galleryPhotoCount,
        weather: weather ?? this.weather,
        totalGuests: totalGuests ?? this.totalGuests,
        confirmedGuests: confirmedGuests ?? this.confirmedGuests,
        pendingTasks: pendingTasks ?? this.pendingTasks,
        upcomingTasks: upcomingTasks ?? this.upcomingTasks,
        recentActivity: recentActivity ?? this.recentActivity,
        commandCenter: commandCenter ?? this.commandCenter,
        budgetSpent: budgetSpent ?? this.budgetSpent,
        budgetTotal: budgetTotal ?? this.budgetTotal,
        error: error,
        isOffline: isOffline ?? this.isOffline,
        cachedAt: cachedAt ?? this.cachedAt,
      );
}

class HomeNotifier extends StateNotifier<HomeState> {
  final ApiClient _api;
  HomeNotifier(this._api) : super(const HomeState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final cached = await _api.getCached('/dashboard');
      final data = cached.data as Map<String, dynamic>;
      final wedding = data['wedding'] as Map<String, dynamic>?;
      final stats = data['stats'] as Map<String, dynamic>? ?? {};
      final commandCenter =
          data['command_center'] as Map<String, dynamic>? ?? {};
      final tasks =
          (data['upcoming_tasks'] as List? ?? []).cast<Map<String, dynamic>>();
      final recentActivity =
          (data['recent_activity'] as List? ?? []).cast<Map<String, dynamic>>();
      final weather = data['weather'] as Map<String, dynamic>?;

      DateTime? eventDate;
      if (wedding?['event_date'] != null) {
        eventDate = DateTime.tryParse(wedding!['event_date'] as String);
      }

      state = state.copyWith(
        isLoading: false,
        coupleName: wedding?['couple_names'] as String? ?? '',
        daysUntil: eventDate?.difference(DateTime.now()).inDays,
        eventDate: eventDate,
        destination: wedding?['destination'] as String?,
        venueName: wedding?['venue_name'] as String?,
        receptionVenueName: wedding?['reception_venue_name'] as String?,
        ceremonyTime: wedding?['ceremony_time'] as String?,
        receptionTime: wedding?['reception_time'] as String?,
        dressCode: wedding?['dress_code'] as String?,
        websiteUrl: wedding?['website_url'] as String?,
        guestPortalUrl: wedding?['guest_portal_url'] as String?,
        hashtag: wedding?['hashtag'] as String?,
        coverPhotoPath: wedding?['cover_photo_path'] as String?,
        couplePhotoPath: wedding?['couple_photo_path'] as String?,
        galleryPreviewPhotoPath:
            wedding?['gallery_preview_photo_path'] as String?,
        galleryPhotoCount:
            (wedding?['gallery_photo_count'] as num?)?.toInt() ?? 0,
        weather: weather,
        totalGuests: (stats['total_guests'] as num?)?.toInt() ?? 0,
        confirmedGuests: (stats['confirmed_guests'] as num?)?.toInt() ?? 0,
        pendingTasks: (stats['pending_tasks'] as num?)?.toInt() ?? 0,
        upcomingTasks: tasks,
        recentActivity: recentActivity,
        commandCenter: commandCenter,
        budgetSpent: (stats['budget_spent'] as num?)?.toDouble(),
        budgetTotal: (stats['budget_total'] as num?)?.toDouble(),
        error:
            cached.fromCache ? 'Showing saved data. Connect to refresh.' : null,
        isOffline: cached.fromCache,
        cachedAt: cached.cachedAt,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "We couldn't load your dashboard right now. Please try again.",
      );
    }
  }

  Future<void> refresh() => _load();

  Future<bool> uploadCoverPhoto(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'photo': MultipartFile.fromBytes(bytes, filename: filename),
      });
      await _api.post('/wedding/cover-photo', data: formData);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.read(apiClientProvider));
});
