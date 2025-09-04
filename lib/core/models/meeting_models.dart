// 🎙️ LingoSphere - Meeting Models
// Comprehensive data models for meeting transcription, translation, and session management

import 'dart:typed_data';

/// Core Meeting Models
class MeetingConfiguration {
  final String title;
  final MeetingType type;
  final String primaryLanguage;
  final List<String> expectedLanguages;
  final AudioQuality audioQuality;
  final TranscriptionAccuracy transcriptionLevel;
  final bool realTimeTranslation;
  final bool recordingEnabled;
  final SecurityLevel securityLevel;
  final Map<String, dynamic> customSettings;

  MeetingConfiguration({
    required this.title,
    required this.type,
    required this.primaryLanguage,
    required this.expectedLanguages,
    required this.audioQuality,
    required this.transcriptionLevel,
    required this.realTimeTranslation,
    required this.recordingEnabled,
    required this.securityLevel,
    required this.customSettings,
  });

  static MeetingConfiguration standard() => MeetingConfiguration(
    title: 'Meeting',
    type: MeetingType.regular,
    primaryLanguage: 'en',
    expectedLanguages: ['en'],
    audioQuality: AudioQuality.high,
    transcriptionLevel: TranscriptionAccuracy.high,
    realTimeTranslation: true,
    recordingEnabled: false,
    securityLevel: SecurityLevel.standard,
    customSettings: {},
  );
}

class Languages {
  final String primary;
  final List<String> targets;
  final List<String> detected;

  Languages({
    required this.primary,
    required this.targets,
    required this.detected,
  });
}

class AudioConfiguration {
  final int sampleRate;
  final int bitDepth;
  final int channels;
  final AudioFormat format;
  final NoiseReduction noiseReduction;
  final double gainLevel;
  final bool autoGainControl;
  final bool echoCancellation;

  AudioConfiguration({
    required this.sampleRate,
    required this.bitDepth,
    required this.channels,
    required this.format,
    required this.noiseReduction,
    required this.gainLevel,
    required this.autoGainControl,
    required this.echoCancellation,
  });

  static AudioConfiguration fromMeetingConfig(MeetingConfiguration config) {
    return AudioConfiguration(
      sampleRate: config.audioQuality.sampleRate,
      bitDepth: 16,
      channels: 1,
      format: AudioFormat.pcm16,
      noiseReduction: NoiseReduction.medium,
      gainLevel: 1.0,
      autoGainControl: true,
      echoCancellation: true,
    );
  }
}

class TranscriptionConfiguration {
  final TranscriptionAccuracy accuracy;
  final bool enablePunctuation;
  final bool enableCapitalization;
  final bool enableSpeakerDiarization;
  final bool enableTimestamps;
  final List<String> customVocabulary;
  final double confidenceThreshold;
  final bool enableProfanityFilter;

  TranscriptionConfiguration({
    required this.accuracy,
    required this.enablePunctuation,
    required this.enableCapitalization,
    required this.enableSpeakerDiarization,
    required this.enableTimestamps,
    required this.customVocabulary,
    required this.confidenceThreshold,
    required this.enableProfanityFilter,
  });

  static TranscriptionConfiguration enterprise() => TranscriptionConfiguration(
    accuracy: TranscriptionAccuracy.high,
    enablePunctuation: true,
    enableCapitalization: true,
    enableSpeakerDiarization: true,
    enableTimestamps: true,
    customVocabulary: [],
    confidenceThreshold: 0.8,
    enableProfanityFilter: false,
  );
}

class TranslationConfiguration {
  final bool realTime;
  final double qualityThreshold;
  final bool preserveFormatting;
  final bool enableContextAware;
  final Map<String, String> terminologyDictionary;
  final TranslationSpeed speed;
  final bool enableCustomModels;

  TranslationConfiguration({
    required this.realTime,
    required this.qualityThreshold,
    required this.preserveFormatting,
    required this.enableContextAware,
    required this.terminologyDictionary,
    required this.speed,
    required this.enableCustomModels,
  });

  static TranslationConfiguration realtime() => TranslationConfiguration(
    realTime: true,
    qualityThreshold: 0.85,
    preserveFormatting: true,
    enableContextAware: true,
    terminologyDictionary: {},
    speed: TranslationSpeed.balanced,
    enableCustomModels: false,
  );
}

class TranscriptionSegment {
  final String id;
  final String text;
  final String? speakerId;
  final String? speakerName;
  final DateTime startTime;
  final DateTime endTime;
  final double confidence;
  final String language;
  final Map<String, String> translations;
  final List<TranscriptionWord> words;
  final Map<String, dynamic> metadata;

  TranscriptionSegment({
    required this.id,
    required this.text,
    this.speakerId,
    this.speakerName,
    required this.startTime,
    required this.endTime,
    required this.confidence,
    required this.language,
    required this.translations,
    required this.words,
    required this.metadata,
  });
}

class TranscriptionWord {
  final String word;
  final DateTime startTime;
  final DateTime endTime;
  final double confidence;
  final String? phonetic;

  TranscriptionWord({
    required this.word,
    required this.startTime,
    required this.endTime,
    required this.confidence,
    this.phonetic,
  });
}

class AudioProcessor {
  final String id;
  final AudioConfiguration config;
  final ProcessingState state;
  final Map<String, dynamic> settings;
  final DateTime createdAt;

  AudioProcessor({
    required this.id,
    required this.config,
    required this.state,
    required this.settings,
    required this.createdAt,
  });
}

class AudioChunk {
  final String id;
  final Uint8List audioData;
  final int sampleRate;
  final int channels;
  final DateTime timestamp;
  final double duration;
  final AudioFormat format;
  final Map<String, dynamic> metadata;

  AudioChunk({
    required this.id,
    required this.audioData,
    required this.sampleRate,
    required this.channels,
    required this.timestamp,
    required this.duration,
    required this.format,
    required this.metadata,
  });
}

class SpeakerDiarization {
  final String sessionId;
  final Map<String, SpeakerProfile> speakers;
  final List<SpeakerSegment> segments;
  final DateTime lastUpdated;
  final double confidence;

  SpeakerDiarization({
    required this.sessionId,
    required this.speakers,
    required this.segments,
    required this.lastUpdated,
    required this.confidence,
  });
}

class SpeakerProfile {
  final String id;
  final String? name;
  final VoiceCharacteristics voiceprint;
  final double confidence;
  final int segmentCount;
  final DateTime firstDetected;
  final DateTime lastActive;

  SpeakerProfile({
    required this.id,
    this.name,
    required this.voiceprint,
    required this.confidence,
    required this.segmentCount,
    required this.firstDetected,
    required this.lastActive,
  });
}

class VoiceCharacteristics {
  final double pitch;
  final double tone;
  final double pace;
  final double volume;
  final Map<String, double> features;

  VoiceCharacteristics({
    required this.pitch,
    required this.tone,
    required this.pace,
    required this.volume,
    required this.features,
  });
}

class SpeakerSegment {
  final String speakerId;
  final DateTime startTime;
  final DateTime endTime;
  final double confidence;

  SpeakerSegment({
    required this.speakerId,
    required this.startTime,
    required this.endTime,
    required this.confidence,
  });
}

class TranslationPipeline {
  final String id;
  final String sourceLanguage;
  final String targetLanguage;
  final PipelineStatus status;
  final TranslationConfiguration config;
  final Map<String, dynamic> metrics;
  final DateTime createdAt;

  TranslationPipeline({
    required this.id,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.status,
    required this.config,
    required this.metrics,
    required this.createdAt,
  });

  static TranslationPipeline empty() => TranslationPipeline(
    id: '',
    sourceLanguage: '',
    targetLanguage: '',
    status: PipelineStatus.inactive,
    config: TranslationConfiguration.realtime(),
    metrics: {},
    createdAt: DateTime.now(),
  );
}

class LiveTranslationCache {
  final String sessionId;
  final Map<String, TranslationCacheEntry> entries;
  final int maxSize;
  final DateTime lastCleanup;
  final Map<String, dynamic> statistics;

  LiveTranslationCache({
    required this.sessionId,
    required this.entries,
    required this.maxSize,
    required this.lastCleanup,
    required this.statistics,
  });
}

class TranslationCacheEntry {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;
  final DateTime cachedAt;
  final int hitCount;

  TranslationCacheEntry({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
    required this.cachedAt,
    required this.hitCount,
  });
}

class ParticipantAudioConfig {
  final bool micEnabled;
  final bool speakerEnabled;
  final double micGain;
  final double speakerVolume;
  final NoiseReduction noiseReduction;
  final bool echoCancellation;

  ParticipantAudioConfig({
    required this.micEnabled,
    required this.speakerEnabled,
    required this.micGain,
    required this.speakerVolume,
    required this.noiseReduction,
    required this.echoCancellation,
  });

  static ParticipantAudioConfig standard() => ParticipantAudioConfig(
    micEnabled: true,
    speakerEnabled: true,
    micGain: 1.0,
    speakerVolume: 1.0,
    noiseReduction: NoiseReduction.medium,
    echoCancellation: true,
  );
}

class ParticipantPermissions {
  final bool canSpeak;
  final bool canTranslate;
  final bool canRecord;
  final bool canManageParticipants;
  final bool canEndMeeting;
  final bool canAccessTranscript;
  final List<String> allowedLanguages;

  ParticipantPermissions({
    required this.canSpeak,
    required this.canTranslate,
    required this.canRecord,
    required this.canManageParticipants,
    required this.canEndMeeting,
    required this.canAccessTranscript,
    required this.allowedLanguages,
  });

  static ParticipantPermissions standard() => ParticipantPermissions(
    canSpeak: true,
    canTranslate: true,
    canRecord: false,
    canManageParticipants: false,
    canEndMeeting: false,
    canAccessTranscript: true,
    allowedLanguages: [],
  );
}

class ParticipantPresence {
  final String participantId;
  final PresenceStatus status;
  final DateTime lastSeen;
  final String? deviceInfo;
  final NetworkQuality networkQuality;
  final Map<String, dynamic> metadata;

  ParticipantPresence({
    required this.participantId,
    required this.status,
    required this.lastSeen,
    this.deviceInfo,
    required this.networkQuality,
    required this.metadata,
  });
}

class SecurityConfiguration {
  final bool encryptionEnabled;
  final EncryptionLevel encryptionLevel;
  final bool complianceRecordingRequired;
  final List<String> allowedDomains;
  final bool requireAuthentication;
  final int maxParticipants;
  final bool watermarkTranscripts;
  final Map<String, dynamic> customPolicies;

  SecurityConfiguration({
    required this.encryptionEnabled,
    required this.encryptionLevel,
    required this.complianceRecordingRequired,
    required this.allowedDomains,
    required this.requireAuthentication,
    required this.maxParticipants,
    required this.watermarkTranscripts,
    required this.customPolicies,
  });

  static SecurityConfiguration standard() => SecurityConfiguration(
    encryptionEnabled: true,
    encryptionLevel: EncryptionLevel.aes256,
    complianceRecordingRequired: false,
    allowedDomains: [],
    requireAuthentication: true,
    maxParticipants: 50,
    watermarkTranscripts: false,
    customPolicies: {},
  );
}

class SecurityEvent {
  final String id;
  final SecurityEventType type;
  final String description;
  final SecurityEventSeverity severity;
  final String? participantId;
  final DateTime occurredAt;
  final Map<String, dynamic> details;
  final bool resolved;

  SecurityEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.severity,
    this.participantId,
    required this.occurredAt,
    required this.details,
    required this.resolved,
  });
}

class EncryptionState {
  final String sessionId;
  final EncryptionLevel level;
  final String algorithm;
  final String keyId;
  final DateTime keyRotatedAt;
  final bool isActive;
  final Map<String, dynamic> parameters;

  EncryptionState({
    required this.sessionId,
    required this.level,
    required this.algorithm,
    required this.keyId,
    required this.keyRotatedAt,
    required this.isActive,
    required this.parameters,
  });
}

class ComplianceRecording {
  final String id;
  final String sessionId;
  final RecordingStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int fileSizeBytes;
  final String storageLocation;
  final RetentionPolicy retentionPolicy;
  final Map<String, dynamic> metadata;

  ComplianceRecording({
    required this.id,
    required this.sessionId,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.fileSizeBytes,
    required this.storageLocation,
    required this.retentionPolicy,
    required this.metadata,
  });

  static ComplianceRecording empty() => ComplianceRecording(
    id: '',
    sessionId: '',
    status: RecordingStatus.stopped,
    startedAt: DateTime.now(),
    fileSizeBytes: 0,
    storageLocation: '',
    retentionPolicy: RetentionPolicy.standard(),
    metadata: {},
  );
}

class RetentionPolicy {
  final Duration retentionPeriod;
  final bool autoDelete;
  final List<String> allowedAccessRoles;
  final Map<String, dynamic> complianceRules;

  RetentionPolicy({
    required this.retentionPeriod,
    required this.autoDelete,
    required this.allowedAccessRoles,
    required this.complianceRules,
  });

  static RetentionPolicy standard() => RetentionPolicy(
    retentionPeriod: Duration(days: 30),
    autoDelete: true,
    allowedAccessRoles: ['admin', 'compliance'],
    complianceRules: {},
  );
}

class BusinessIntegration {
  final String id;
  final IntegrationType type;
  final String name;
  final IntegrationStatus status;
  final Map<String, dynamic> configuration;
  final DateTime createdAt;
  final DateTime? lastSyncAt;
  final Map<String, dynamic> syncResults;

  BusinessIntegration({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    required this.configuration,
    required this.createdAt,
    this.lastSyncAt,
    required this.syncResults,
  });
}

class CalendarIntegration {
  final String sessionId;
  final String calendarEventId;
  final String provider;
  final Map<String, dynamic> eventDetails;
  final bool autoScheduled;
  final DateTime? reminderTime;

  CalendarIntegration({
    required this.sessionId,
    required this.calendarEventId,
    required this.provider,
    required this.eventDetails,
    required this.autoScheduled,
    this.reminderTime,
  });
}

class SlackIntegration {
  final String sessionId;
  final String channelId;
  final String teamId;
  final bool notificationsEnabled;
  final bool transcriptSharing;
  final Map<String, dynamic> settings;

  SlackIntegration({
    required this.sessionId,
    required this.channelId,
    required this.teamId,
    required this.notificationsEnabled,
    required this.transcriptSharing,
    required this.settings,
  });
}

class TeamsIntegration {
  final String sessionId;
  final String teamId;
  final String channelId;
  final bool adaptiveCards;
  final bool botIntegration;
  final Map<String, dynamic> botConfig;

  TeamsIntegration({
    required this.sessionId,
    required this.teamId,
    required this.channelId,
    required this.adaptiveCards,
    required this.botIntegration,
    required this.botConfig,
  });
}

class MeetingAnalytics {
  final String sessionId;
  final Duration totalDuration;
  final Map<String, Duration> participantSpeakingTime;
  final Map<String, int> languageUsage;
  final double averageConfidence;
  final int totalSegments;
  final Map<String, int> translationCounts;
  final EngagementMetrics engagement;
  final QualityMetrics quality;

  MeetingAnalytics({
    required this.sessionId,
    required this.totalDuration,
    required this.participantSpeakingTime,
    required this.languageUsage,
    required this.averageConfidence,
    required this.totalSegments,
    required this.translationCounts,
    required this.engagement,
    required this.quality,
  });

  static MeetingAnalytics empty() => MeetingAnalytics(
    sessionId: '',
    totalDuration: Duration.zero,
    participantSpeakingTime: {},
    languageUsage: {},
    averageConfidence: 0.0,
    totalSegments: 0,
    translationCounts: {},
    engagement: EngagementMetrics.neutral(),
    quality: QualityMetrics.empty(),
  );
}

class EngagementMetrics {
  final double overallScore;
  final Map<String, double> participantEngagement;
  final int interruptionCount;
  final double silenceRatio;
  final double conversationBalance;

  EngagementMetrics({
    required this.overallScore,
    required this.participantEngagement,
    required this.interruptionCount,
    required this.silenceRatio,
    required this.conversationBalance,
  });

  static EngagementMetrics neutral() => EngagementMetrics(
    overallScore: 0.5,
    participantEngagement: {},
    interruptionCount: 0,
    silenceRatio: 0.2,
    conversationBalance: 0.5,
  );
}

class QualityMetrics {
  final double audioQuality;
  final double transcriptionAccuracy;
  final double translationQuality;
  final Map<String, double> languageQuality;
  final int technicalIssues;

  QualityMetrics({
    required this.audioQuality,
    required this.transcriptionAccuracy,
    required this.translationQuality,
    required this.languageQuality,
    required this.technicalIssues,
  });

  static QualityMetrics empty() => QualityMetrics(
    audioQuality: 0.0,
    transcriptionAccuracy: 0.0,
    translationQuality: 0.0,
    languageQuality: {},
    technicalIssues: 0,
  );
}

class ActionItem {
  final String id;
  final String text;
  final String? assignedTo;
  final DateTime? dueDate;
  final ActionItemPriority priority;
  final ActionItemStatus status;
  final DateTime extractedAt;
  final String segmentId;

  ActionItem({
    required this.id,
    required this.text,
    this.assignedTo,
    this.dueDate,
    required this.priority,
    required this.status,
    required this.extractedAt,
    required this.segmentId,
  });
}

class KeyTopic {
  final String topic;
  final double relevance;
  final int mentionCount;
  final List<String> relatedSegments;
  final Map<String, dynamic> context;

  KeyTopic({
    required this.topic,
    required this.relevance,
    required this.mentionCount,
    required this.relatedSegments,
    required this.context,
  });
}

class Decision {
  final String id;
  final String description;
  final String? decidedBy;
  final DateTime decidedAt;
  final DecisionConfidence confidence;
  final List<String> affectedParties;
  final String segmentId;

  Decision({
    required this.id,
    required this.description,
    this.decidedBy,
    required this.decidedAt,
    required this.confidence,
    required this.affectedParties,
    required this.segmentId,
  });
}

class ParticipantInsight {
  final String participantId;
  final Duration speakingTime;
  final double dominanceScore;
  final int contributionCount;
  final List<String> keyTopics;
  final Map<String, double> emotionalTone;

  ParticipantInsight({
    required this.participantId,
    required this.speakingTime,
    required this.dominanceScore,
    required this.contributionCount,
    required this.keyTopics,
    required this.emotionalTone,
  });
}

class MeetingSummary {
  final String id;
  final String sessionId;
  final String title;
  final String summary;
  final List<KeyTopic> keyTopics;
  final List<ActionItem> actionItems;
  final List<Decision> decisions;
  final Map<String, ParticipantInsight> participantInsights;
  final Map<String, String> translations;
  final DateTime generatedAt;
  final SummaryType type;

  MeetingSummary({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.summary,
    required this.keyTopics,
    required this.actionItems,
    required this.decisions,
    required this.participantInsights,
    required this.translations,
    required this.generatedAt,
    required this.type,
  });
}

class MeetingClosureResult {
  final String sessionId;
  final Duration duration;
  final int participantCount;
  final int transcriptSegments;
  final MeetingSummary? summary;
  final TranscriptExport transcriptExport;
  final Map<String, TranslationExport> translationExports;
  final ComplianceRecording? complianceRecording;
  final MeetingAnalytics? analytics;
  final SecurityReport securityReport;
  final DateTime processedAt;

  MeetingClosureResult({
    required this.sessionId,
    required this.duration,
    required this.participantCount,
    required this.transcriptSegments,
    this.summary,
    required this.transcriptExport,
    required this.translationExports,
    this.complianceRecording,
    this.analytics,
    required this.securityReport,
    required this.processedAt,
  });
}

class TranscriptExport {
  final String id;
  final String sessionId;
  final ExportFormat format;
  final String content;
  final Map<String, dynamic> metadata;
  final DateTime exportedAt;
  final int fileSizeBytes;

  TranscriptExport({
    required this.id,
    required this.sessionId,
    required this.format,
    required this.content,
    required this.metadata,
    required this.exportedAt,
    required this.fileSizeBytes,
  });

  static TranscriptExport empty() => TranscriptExport(
    id: '',
    sessionId: '',
    format: ExportFormat.txt,
    content: '',
    metadata: {},
    exportedAt: DateTime.now(),
    fileSizeBytes: 0,
  );
}

class TranslationExport {
  final String id;
  final String sessionId;
  final String language;
  final ExportFormat format;
  final String content;
  final double averageQuality;
  final DateTime exportedAt;

  TranslationExport({
    required this.id,
    required this.sessionId,
    required this.language,
    required this.format,
    required this.content,
    required this.averageQuality,
    required this.exportedAt,
  });
}

class SecurityReport {
  final String sessionId;
  final int totalEvents;
  final int securityIssues;
  final List<SecurityEvent> criticalEvents;
  final bool complianceMetrics;
  final Map<String, dynamic> encryptionStatus;
  final DateTime generatedAt;

  SecurityReport({
    required this.sessionId,
    required this.totalEvents,
    required this.securityIssues,
    required this.criticalEvents,
    required this.complianceMetrics,
    required this.encryptionStatus,
    required this.generatedAt,
  });

  static SecurityReport empty() => SecurityReport(
    sessionId: '',
    totalEvents: 0,
    securityIssues: 0,
    criticalEvents: [],
    complianceMetrics: true,
    encryptionStatus: {},
    generatedAt: DateTime.now(),
  );
}

/// Utility Classes
class TranslatedStream {
  final String sourceLanguage;
  final String targetLanguage;
  final Stream<TranscriptionSegment> segments;
  final TranslationQuality quality;

  TranslatedStream({
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.segments,
    required this.quality,
  });
}

class TranslationQuality {
  final double score;
  final String level;
  final Map<String, double> metrics;

  TranslationQuality({
    required this.score,
    required this.level,
    required this.metrics,
  });
}

class Speaker {
  final String id;
  final String? name;
  final VoiceCharacteristics characteristics;
  final double confidence;

  Speaker({
    required this.id,
    this.name,
    required this.characteristics,
    required this.confidence,
  });

  static Speaker unknown() => Speaker(
    id: 'unknown',
    characteristics: VoiceCharacteristics(
      pitch: 0.5,
      tone: 0.5,
      pace: 0.5,
      volume: 0.5,
      features: {},
    ),
    confidence: 0.0,
  );
}

class TranslatedText {
  final String text;
  final String language;
  final double confidence;
  final DateTime translatedAt;

  TranslatedText({
    required this.text,
    required this.language,
    required this.confidence,
    required this.translatedAt,
  });
}

/// Enums
enum MeetingType { regular, interview, presentation, workshop, webinar, training }
enum AudioQuality { 
  low(8000), 
  medium(16000), 
  high(44100), 
  studio(96000);
  
  const AudioQuality(this.sampleRate);
  final int sampleRate;
}
enum TranscriptionAccuracy { basic, standard, high, premium }
enum SecurityLevel { basic, standard, high, maximum }
enum AudioFormat { pcm16, mp3, wav, aac, opus }
enum NoiseReduction { none, low, medium, high, maximum }
enum TranslationSpeed { fast, balanced, quality }
enum ProcessingState { idle, processing, completed, error }
enum PipelineStatus { inactive, active, paused, error }
enum SecurityEventType { participantJoined, participantLeft, recordingStarted, recordingStopped, securityViolation }
enum SecurityEventSeverity { low, medium, high, critical }
enum EncryptionLevel { none, basic, aes128, aes256, enterprise }
enum RecordingStatus { starting, recording, paused, stopping, stopped, error }
enum IntegrationType { calendar, slack, teams, zoom, webex, custom }
enum IntegrationStatus { inactive, active, error, syncing }
enum ActionItemPriority { low, medium, high, urgent }
enum ActionItemStatus { pending, inProgress, completed, cancelled }
enum DecisionConfidence { low, medium, high, certain }
enum SummaryType { brief, detailed, executive, technical }
enum ExportFormat { txt, pdf, docx, json, srt, vtt }

/// Network quality information
enum NetworkQuality {
  poor,
  fair,
  good,
  excellent
}

/// Participant presence status
enum PresenceStatus {
  online,
  away,
  busy,
  offline,
  unknown
}
