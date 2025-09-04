// 📊 LingoSphere - Analytics Models
// Comprehensive data models for advanced analytics, business intelligence, and insights

import 'package:flutter/material.dart';

/// Core Analytics Models
class AnalyticsEvent {
  final String id;
  final String userId;
  final String eventType;
  final String category;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String sessionId;
  final String? deviceId;
  final String? ipAddress;
  final String? userAgent;

  AnalyticsEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.category,
    required this.properties,
    required this.metadata,
    required this.timestamp,
    required this.sessionId,
    this.deviceId,
    this.ipAddress,
    this.userAgent,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'eventType': eventType,
    'category': category,
    'properties': properties,
    'metadata': metadata,
    'timestamp': timestamp.toIso8601String(),
    'sessionId': sessionId,
    'deviceId': deviceId,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
  };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => AnalyticsEvent(
    id: json['id'],
    userId: json['userId'],
    eventType: json['eventType'],
    category: json['category'],
    properties: Map<String, dynamic>.from(json['properties']),
    metadata: Map<String, dynamic>.from(json['metadata']),
    timestamp: DateTime.parse(json['timestamp']),
    sessionId: json['sessionId'],
    deviceId: json['deviceId'],
    ipAddress: json['ipAddress'],
    userAgent: json['userAgent'],
  );
}

class UserBehaviorMetrics {
  final String userId;
  final double sessionDuration;
  final int translationCount;
  final double averageTranslationTime;
  final Map<String, int> languagePairUsage;
  final double engagementScore;
  final int streakDays;
  final double qualityScore;
  final DateTime lastActiveDate;
  final Map<String, dynamic> behaviorPatterns;

  UserBehaviorMetrics({
    required this.userId,
    required this.sessionDuration,
    required this.translationCount,
    required this.averageTranslationTime,
    required this.languagePairUsage,
    required this.engagementScore,
    required this.streakDays,
    required this.qualityScore,
    required this.lastActiveDate,
    required this.behaviorPatterns,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'sessionDuration': sessionDuration,
    'translationCount': translationCount,
    'averageTranslationTime': averageTranslationTime,
    'languagePairUsage': languagePairUsage,
    'engagementScore': engagementScore,
    'streakDays': streakDays,
    'qualityScore': qualityScore,
    'lastActiveDate': lastActiveDate.toIso8601String(),
    'behaviorPatterns': behaviorPatterns,
  };
}

class PerformanceMetrics {
  final double responseTime;
  final double throughput;
  final double errorRate;
  final double availability;
  final Map<String, double> serviceTimes;
  final int concurrentUsers;
  final double memoryUsage;
  final double cpuUsage;
  final DateTime measuredAt;
  
  // Additional properties needed by insights dashboard
  final double averageResponseTime;
  final double successRate;
  final double cacheHitRate;
  final List<ResponseTimePoint> responseTimeTrend;
  final double highConfidenceRate;
  final double mediumConfidenceRate;
  final double lowConfidenceRate;

  PerformanceMetrics({
    required this.responseTime,
    required this.throughput,
    required this.errorRate,
    required this.availability,
    required this.serviceTimes,
    required this.concurrentUsers,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.measuredAt,
    required this.averageResponseTime,
    required this.successRate,
    required this.cacheHitRate,
    required this.responseTimeTrend,
    required this.highConfidenceRate,
    required this.mediumConfidenceRate,
    required this.lowConfidenceRate,
  });

  static PerformanceMetrics optimal() => PerformanceMetrics(
    responseTime: 150.0,
    throughput: 1000.0,
    errorRate: 0.01,
    availability: 99.9,
    serviceTimes: {'translation': 200.0, 'analysis': 100.0},
    concurrentUsers: 50,
    memoryUsage: 75.5,
    cpuUsage: 25.3,
    measuredAt: DateTime.now(),
    averageResponseTime: 150.0,
    successRate: 98.5,
    cacheHitRate: 85.2,
    responseTimeTrend: [],
    highConfidenceRate: 75.0,
    mediumConfidenceRate: 20.0,
    lowConfidenceRate: 5.0,
  );
}

class BusinessIntelligenceData {
  final String organizationId;
  final Map<String, double> kpiMetrics;
  final Map<String, dynamic> trends;
  final List<String> insights;
  final Map<String, int> usageStatistics;
  final double roi;
  final double growthRate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, dynamic> recommendations;

  BusinessIntelligenceData({
    required this.organizationId,
    required this.kpiMetrics,
    required this.trends,
    required this.insights,
    required this.usageStatistics,
    required this.roi,
    required this.growthRate,
    required this.periodStart,
    required this.periodEnd,
    required this.recommendations,
  });

  static BusinessIntelligenceData empty() => BusinessIntelligenceData(
    organizationId: '',
    kpiMetrics: {},
    trends: {},
    insights: [],
    usageStatistics: {},
    roi: 0.0,
    growthRate: 0.0,
    periodStart: DateTime.now(),
    periodEnd: DateTime.now(),
    recommendations: {},
  );
}

class PredictiveAnalyticsResult {
  final String modelId;
  final String predictionType;
  final Map<String, double> predictions;
  final double confidence;
  final Map<String, dynamic> features;
  final List<String> factors;
  final DateTime validUntil;
  final Map<String, dynamic> metadata;

  PredictiveAnalyticsResult({
    required this.modelId,
    required this.predictionType,
    required this.predictions,
    required this.confidence,
    required this.features,
    required this.factors,
    required this.validUntil,
    required this.metadata,
  });

  static PredictiveAnalyticsResult empty() => PredictiveAnalyticsResult(
    modelId: '',
    predictionType: '',
    predictions: {},
    confidence: 0.0,
    features: {},
    factors: [],
    validUntil: DateTime.now(),
    metadata: {},
  );
}

class DashboardWidget {
  final String id;
  final String title;
  final WidgetType type;
  final Map<String, dynamic> config;
  final Map<String, dynamic> data;
  final List<String> dataSources;
  final DateTime lastUpdated;
  final bool isVisible;
  final int displayOrder;

  DashboardWidget({
    required this.id,
    required this.title,
    required this.type,
    required this.config,
    required this.data,
    required this.dataSources,
    required this.lastUpdated,
    required this.isVisible,
    required this.displayOrder,
  });
}

class AnomalyDetectionResult {
  final String id;
  final AnomalyType type;
  final String description;
  final double severity;
  final Map<String, dynamic> affectedMetrics;
  final DateTime detectedAt;
  final List<String> possibleCauses;
  final List<String> recommendations;
  final bool isResolved;
  final Map<String, dynamic> context;

  AnomalyDetectionResult({
    required this.id,
    required this.type,
    required this.description,
    required this.severity,
    required this.affectedMetrics,
    required this.detectedAt,
    required this.possibleCauses,
    required this.recommendations,
    required this.isResolved,
    required this.context,
  });

  static AnomalyDetectionResult empty() => AnomalyDetectionResult(
    id: '',
    type: AnomalyType.performance,
    description: '',
    severity: 0.0,
    affectedMetrics: {},
    detectedAt: DateTime.now(),
    possibleCauses: [],
    recommendations: [],
    isResolved: false,
    context: {},
  );
}

class ABTestExperiment {
  final String id;
  final String name;
  final String description;
  final ExperimentStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<ExperimentVariant> variants;
  final Map<String, dynamic> targetingRules;
  final List<String> successMetrics;
  final double trafficAllocation;
  final Map<String, double> results;
  final double confidence;
  final bool isWinner;

  ABTestExperiment({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.variants,
    required this.targetingRules,
    required this.successMetrics,
    required this.trafficAllocation,
    required this.results,
    required this.confidence,
    required this.isWinner,
  });

  static ABTestExperiment empty() => ABTestExperiment(
    id: '',
    name: '',
    description: '',
    status: ExperimentStatus.draft,
    startDate: DateTime.now(),
    variants: [],
    targetingRules: {},
    successMetrics: [],
    trafficAllocation: 0.0,
    results: {},
    confidence: 0.0,
    isWinner: false,
  );
}

class ExperimentVariant {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> configuration;
  final double trafficWeight;
  final Map<String, double> metrics;
  final int userCount;

  ExperimentVariant({
    required this.id,
    required this.name,
    required this.description,
    required this.configuration,
    required this.trafficWeight,
    required this.metrics,
    required this.userCount,
  });
}

class UserSegment {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> criteria;
  final int userCount;
  final Map<String, double> characteristics;
  final List<String> behaviors;
  final DateTime lastUpdated;
  final bool isActive;

  UserSegment({
    required this.id,
    required this.name,
    required this.description,
    required this.criteria,
    required this.userCount,
    required this.characteristics,
    required this.behaviors,
    required this.lastUpdated,
    required this.isActive,
  });

  static UserSegment empty() => UserSegment(
    id: '',
    name: '',
    description: '',
    criteria: {},
    userCount: 0,
    characteristics: {},
    behaviors: [],
    lastUpdated: DateTime.now(),
    isActive: true,
  );
}

class AnalyticsReport {
  final String id;
  final String title;
  final ReportType type;
  final Map<String, dynamic> data;
  final List<String> insights;
  final Map<String, String> visualizations;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, dynamic> filters;
  final bool isScheduled;
  final String? scheduleConfig;

  AnalyticsReport({
    required this.id,
    required this.title,
    required this.type,
    required this.data,
    required this.insights,
    required this.visualizations,
    required this.generatedAt,
    required this.generatedBy,
    required this.filters,
    required this.isScheduled,
    this.scheduleConfig,
  });

  static AnalyticsReport empty() => AnalyticsReport(
    id: '',
    title: '',
    type: ReportType.usage,
    data: {},
    insights: [],
    visualizations: {},
    generatedAt: DateTime.now(),
    generatedBy: '',
    filters: {},
    isScheduled: false,
  );
}

/// Enums
enum WidgetType {
  chart,
  table,
  metric,
  gauge,
  map,
  timeline,
  heatmap,
  funnel,
  histogram,
  scatter
}

enum AnomalyType {
  performance,
  usage,
  error,
  security,
  business,
  technical
}

enum ExperimentStatus {
  draft,
  running,
  paused,
  completed,
  cancelled
}

enum ReportType {
  usage,
  performance,
  business,
  user,
  revenue,
  quality,
  engagement,
  conversion
}

/// Daily usage data point
class DailyUsage {
  final DateTime date;
  final int translations;
  final int textTranslations;
  final int voiceTranslations;
  final int cameraTranslations;
  
  // Alias for total translations count (used by insights dashboard)
  int get count => translations;

  DailyUsage({
    required this.date,
    required this.translations,
    required this.textTranslations,
    required this.voiceTranslations,
    required this.cameraTranslations,
  });
}

/// Additional Analytics Models for Insights Dashboard
class UsageAnalytics {
  final int totalTranslations;
  final double avgTranslationTime;
  final int activeUsers;
  final Map<String, int> languageUsage;
  final List<RecentTranslation> recentActivity;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double growthRate;
  
  // Additional properties needed by insights dashboard
  final double translationsGrowth;
  final int languagesUsed;
  final double averageConfidence;
  final double successRate;
  final List<DailyUsage> dailyUsage;
  final List<RecentTranslation> recentTranslations;
  final String peakHour;
  final String preferredMethod;
  final double methodUsagePercentage;
  final double averageSessionLength;

  UsageAnalytics({
    required this.totalTranslations,
    required this.avgTranslationTime,
    required this.activeUsers,
    required this.languageUsage,
    required this.recentActivity,
    required this.periodStart,
    required this.periodEnd,
    required this.growthRate,
    required this.translationsGrowth,
    required this.languagesUsed,
    required this.averageConfidence,
    required this.successRate,
    required this.dailyUsage,
    required this.recentTranslations,
    required this.peakHour,
    required this.preferredMethod,
    required this.methodUsagePercentage,
    required this.averageSessionLength,
  });

  static UsageAnalytics empty() => UsageAnalytics(
    totalTranslations: 0,
    avgTranslationTime: 0.0,
    activeUsers: 0,
    languageUsage: {},
    recentActivity: [],
    periodStart: DateTime.now(),
    periodEnd: DateTime.now(),
    growthRate: 0.0,
    translationsGrowth: 0.0,
    languagesUsed: 0,
    averageConfidence: 0.0,
    successRate: 0.0,
    dailyUsage: [],
    recentTranslations: [],
    peakHour: 'N/A',
    preferredMethod: 'Text',
    methodUsagePercentage: 0.0,
    averageSessionLength: 0.0,
  );
}

class RecentTranslation {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final double confidence;
  final String userId;
  final String provider;
  final String originalText;
  final String method;

  RecentTranslation({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    required this.confidence,
    required this.userId,
    required this.provider,
    String? originalText,
    String? method,
  }) : originalText = originalText ?? sourceText,
       method = method ?? 'text';
}

class LanguageUsageStats {
  final String languageCode;
  final String languageName;
  final int usage;
  final double percentage;
  final int trend;
  final DateTime lastUsed;
  final Color color;

  LanguageUsageStats({
    required this.languageCode,
    required this.languageName,
    required this.usage,
    required this.percentage,
    required this.trend,
    required this.lastUsed,
    Color? color,
  }) : color = color ?? const Color(0xFF4CAF50);
}

class ConversationInsight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final double impact;
  final List<String> recommendations;
  final Map<String, dynamic> data;
  final DateTime generatedAt;
  final bool isActionable;
  final String importance;
  final String actionSuggestion;

  ConversationInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.impact,
    required this.recommendations,
    required this.data,
    required this.generatedAt,
    required this.isActionable,
    String? importance,
    String? actionSuggestion,
  }) : importance = importance ?? (impact > 0.8 ? 'HIGH' : impact > 0.5 ? 'MEDIUM' : 'LOW'),
       actionSuggestion = actionSuggestion ?? (recommendations.isNotEmpty ? recommendations.first : '');
}

class ResponseTimePoint {
  final DateTime timestamp;
  final double responseTime;
  final String endpoint;
  final int statusCode;

  ResponseTimePoint({
    required this.timestamp,
    required this.responseTime,
    required this.endpoint,
    required this.statusCode,
  });
}

enum InsightType {
  performance,
  usage,
  quality,
  recommendation
}

/// Helper Classes
class TimeSeriesData {
  final List<DataPoint> points;
  final String metric;
  final String unit;
  final Duration interval;

  TimeSeriesData({
    required this.points,
    required this.metric,
    required this.unit,
    required this.interval,
  });
}

class DataPoint {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? metadata;

  DataPoint({
    required this.timestamp,
    required this.value,
    this.metadata,
  });
}

class MetricAggregation {
  final String metric;
  final double sum;
  final double average;
  final double min;
  final double max;
  final int count;
  final double median;
  final double p95;
  final double p99;

  MetricAggregation({
    required this.metric,
    required this.sum,
    required this.average,
    required this.min,
    required this.max,
    required this.count,
    required this.median,
    required this.p95,
    required this.p99,
  });
}
