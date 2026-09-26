/// A side business with its own pipeline (e.g. Carros, Viajes).
/// `closedLabel` names the winning stage in that business's words —
/// a car is "Vendido", a trip is "Reservado".
class Business {
  final String id;
  String name;
  String emoji;
  String closedLabel;

  Business({
    required this.id,
    required this.name,
    required this.emoji,
    required this.closedLabel,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'closedLabel': closedLabel,
      };

  factory Business.fromJson(Map<String, dynamic> json) => Business(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        closedLabel: json['closedLabel'] as String,
      );
}

enum LeadStage { nuevo, conversacion, cerrando, cerrado, perdido }

extension LeadStageMeta on LeadStage {
  String labelFor(Business business) => switch (this) {
        LeadStage.nuevo => 'Nuevo',
        LeadStage.conversacion => 'En conversación',
        LeadStage.cerrando => 'Cerrando',
        LeadStage.cerrado => business.closedLabel,
        LeadStage.perdido => 'Perdido',
      };

  bool get isOpen => this != LeadStage.cerrado && this != LeadStage.perdido;

  /// The next step forward in the pipeline, or null once it's closed.
  LeadStage? get next => switch (this) {
        LeadStage.nuevo => LeadStage.conversacion,
        LeadStage.conversacion => LeadStage.cerrando,
        LeadStage.cerrando => LeadStage.cerrado,
        _ => null,
      };
}

/// A quick capture ("Corolla 2018, pregunta precio") that lives in a
/// business's queue until it's attended during a business window.
class Lead {
  final String id;
  String businessId;
  String text;
  LeadStage stage;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? closedAt;

  Lead({
    required this.id,
    required this.businessId,
    required this.text,
    this.stage = LeadStage.nuevo,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
  });

  static const coolingAfterDays = 3;

  /// Already in play but untouched for a few days — about to go cold.
  bool get isCooling =>
      stage.isOpen &&
      stage != LeadStage.nuevo &&
      DateTime.now().difference(updatedAt).inDays >= coolingAfterDays;

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': businessId,
        'text': text,
        'stage': stage.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'closedAt': closedAt?.toIso8601String(),
      };

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: json['id'] as String,
        businessId: json['businessId'] as String,
        text: json['text'] as String,
        stage: LeadStage.values.byName(json['stage'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt'] as String) : null,
      );
}
