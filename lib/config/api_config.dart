/// Matches [pos_test/src/config/api.js] — production APS Pro API.
class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://suzanpro.com',
  );

  static const timeout = Duration(seconds: 30);
  static const syncTimeout = Duration(minutes: 3);

  static const authLogin = '/api/v1/auth/login';
  static const authMe = '/api/v1/auth/me';

  static const syncInitial = '/api/v1/sync/initial';
  static const syncInitialAll = '/api/v1/sync/initial_all';
  static const syncInitialAllV2 = '/api/v1/sync/initial_all_v2';
  static const syncInitialAllBusinesses = '/api/v1/sync/initial_all_businesses';
  static const syncInitialAllBusinessesV2 =
      '/api/v1/sync/initial_all_businesses_v2';
  static const syncPush = '/api/v1/sync/push';

  static const salesTodaySummary = '/api/v1/sales/today-summary';

  /// Prefer lightweight `/initial` first on mobile (products only, faster).
  static List<String> initialSyncPaths({required bool hasBusinessId}) {
    const fast = [syncInitial];
    if (hasBusinessId) {
      return [
        ...fast,
        syncInitialAllV2,
        syncInitialAll,
        syncInitialAllBusinessesV2,
        syncInitialAllBusinesses,
      ];
    }
    return [
      ...fast,
      syncInitialAllBusinessesV2,
      syncInitialAllBusinesses,
      syncInitialAllV2,
      syncInitialAll,
    ];
  }
}
