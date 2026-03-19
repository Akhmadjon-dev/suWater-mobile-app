enum EventStatus {
  reported('REPORTED'),
  createdAssigned('CREATED_ASSIGNED'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  archived('ARCHIVED');

  final String value;
  const EventStatus(this.value);

  static EventStatus fromString(String value) {
    return EventStatus.values.firstWhere(
      (s) => s.value == value.toUpperCase(),
      orElse: () => EventStatus.reported,
    );
  }

  String get label {
    switch (this) {
      case EventStatus.reported:
        return 'Reported';
      case EventStatus.createdAssigned:
        return 'Assigned';
      case EventStatus.inProgress:
        return 'In Progress';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.archived:
        return 'Archived';
    }
  }
}

enum EventType {
  leak('LEAK'),
  pipeBurst('PIPE_BURST'),
  contamination('CONTAMINATION'),
  valveFailure('VALVE_FAILURE'),
  hydrantDamage('HYDRANT_DAMAGE'),
  other('OTHER');

  final String value;
  const EventType(this.value);

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
      (t) => t.value == value.toUpperCase(),
      orElse: () => EventType.other,
    );
  }

  String get label {
    switch (this) {
      case EventType.leak:
        return 'Water Leak';
      case EventType.pipeBurst:
        return 'Pipe Burst';
      case EventType.contamination:
        return 'Contamination';
      case EventType.valveFailure:
        return 'Valve Failure';
      case EventType.hydrantDamage:
        return 'Hydrant Damage';
      case EventType.other:
        return 'Other';
    }
  }
}

enum EventPriority {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  critical('CRITICAL');

  final String value;
  const EventPriority(this.value);

  static EventPriority fromString(String value) {
    return EventPriority.values.firstWhere(
      (p) => p.value == value.toUpperCase(),
      orElse: () => EventPriority.medium,
    );
  }

  String get label {
    switch (this) {
      case EventPriority.low:
        return 'Low';
      case EventPriority.medium:
        return 'Medium';
      case EventPriority.high:
        return 'High';
      case EventPriority.critical:
        return 'Critical';
    }
  }
}

class WaterEvent {
  final String id;
  final EventType type;
  final EventStatus status;
  final EventPriority priority;
  final String title;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? assignedSupervisorId;
  final String? supervisorName;
  final String? scheduledDate;
  final String? details;
  final String createdAt;
  final String? completedAt;
  final String? completionNotes;

  const WaterEvent({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    required this.title,
    this.description,
    this.latitude,
    this.longitude,
    this.address,
    this.assignedSupervisorId,
    this.supervisorName,
    this.scheduledDate,
    this.details,
    required this.createdAt,
    this.completedAt,
    this.completionNotes,
  });

  factory WaterEvent.fromJson(Map<String, dynamic> json) {
    return WaterEvent(
      id: json['id'] as String,
      type: EventType.fromString(json['type'] as String),
      status: EventStatus.fromString(json['status'] as String),
      priority: EventPriority.fromString(json['priority'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      assignedSupervisorId: json['assigned_supervisor_id'] as String?,
      supervisorName: json['supervisor_name'] as String?,
      scheduledDate: json['scheduled_date'] as String?,
      details: json['details'] as String?,
      createdAt: json['created_at'] as String,
      completedAt: json['completed_at'] as String?,
      completionNotes: json['completion_notes'] as String?,
    );
  }
}

class EventsResponse {
  final List<WaterEvent> data;
  final int total;
  final int page;
  final int totalPages;

  const EventsResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      data: (json['data'] as List)
          .map((e) => WaterEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class EventAssignment {
  final String id;
  final String workerId;
  final String? userId;
  final String role; // lead | support
  final String? workerName;
  final String? workerEmail;
  final String? workerPhone;
  final String assignedAt;

  const EventAssignment({
    required this.id,
    required this.workerId,
    this.userId,
    required this.role,
    this.workerName,
    this.workerEmail,
    this.workerPhone,
    required this.assignedAt,
  });

  factory EventAssignment.fromJson(Map<String, dynamic> json) {
    return EventAssignment(
      id: json['id'] as String,
      workerId: json['worker_id'] as String,
      userId: json['user_id'] as String?,
      role: json['role'] as String,
      workerName: json['worker_name'] as String?,
      workerEmail: json['worker_email'] as String?,
      workerPhone: json['worker_phone'] as String?,
      assignedAt: json['assigned_at'] as String,
    );
  }
}
