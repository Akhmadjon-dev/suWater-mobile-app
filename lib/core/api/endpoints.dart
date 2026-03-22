class Endpoints {
  Endpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';

  // Users
  static const String users = '/users';
  static String user(String id) => '/users/$id';

  // Events
  static const String events = '/events';
  static String event(String id) => '/events/$id';
  static String eventTransition(String id) => '/events/$id/transition';

  // Event assignments
  static String assignments(String eventId) => '/events/$eventId/assignments';
  static String assignment(String eventId, String assignmentId) =>
      '/events/$eventId/assignments/$assignmentId';

  // Event comments
  static String comments(String eventId) => '/events/$eventId/comments';

  // Event resources
  static String labor(String eventId) => '/events/$eventId/labor';
  static String laborById(String eventId, String laborId) =>
      '/events/$eventId/labor/$laborId';
  static String equipment(String eventId) => '/events/$eventId/equipment';
  static String equipmentById(String eventId, String equipmentId) =>
      '/events/$eventId/equipment/$equipmentId';
  static String materials(String eventId) => '/events/$eventId/materials';
  static String materialById(String eventId, String materialId) =>
      '/events/$eventId/materials/$materialId';

  // Documents
  static const String documentsUpload = '/documents/upload';
  static String documentFile(String id) => '/documents/$id/file';
  static String eventDocuments(String eventId) => '/documents/event/$eventId';
  static String documentLink(String id) => '/documents/$id/link';
  static String document(String id) => '/documents/$id';

  // Geometry
  static const String geometry = '/geometry';
  static const String geometryBbox = '/geometry/bbox';

  // Citizen Profile
  static const String citizenProfile = '/citizen-profile';
  static const String citizenProfileMeterPhoto = '/citizen-profile/meter-photo';
  static const String citizenReadings = '/citizen-profile/readings';
  static const String citizenReadingsLatest = '/citizen-profile/readings/latest';
  static String citizenReading(String id) => '/citizen-profile/readings/$id';
}
