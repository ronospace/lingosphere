// 📄 LingoSphere - Document Models
// Comprehensive data models for document processing, translation, and format preservation

import 'dart:typed_data';

/// Core Document Models
class Document {
  final String id;
  final String fileName;
  final DocumentType type;
  final String mimeType;
  final int sizeInBytes;
  final Uint8List content;
  final DocumentMetadata metadata;
  final DateTime uploadedAt;
  final String uploadedBy;
  final DocumentStatus status;
  final Map<String, dynamic> properties;

  Document({
    required this.id,
    required this.fileName,
    required this.type,
    required this.mimeType,
    required this.sizeInBytes,
    required this.content,
    required this.metadata,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.status,
    required this.properties,
  });

  static Document empty() => Document(
    id: '',
    fileName: '',
    type: DocumentType.pdf,
    mimeType: '',
    sizeInBytes: 0,
    content: Uint8List(0),
    metadata: DocumentMetadata.empty(),
    uploadedAt: DateTime.now(),
    uploadedBy: '',
    status: DocumentStatus.uploaded,
    properties: {},
  );
}

class DocumentMetadata {
  final String title;
  final String? author;
  final String? subject;
  final String? description;
  final List<String> keywords;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final String? creator;
  final String? producer;
  final int? pageCount;
  final String? language;
  final Map<String, dynamic> customProperties;

  DocumentMetadata({
    required this.title,
    this.author,
    this.subject,
    this.description,
    required this.keywords,
    this.createdAt,
    this.modifiedAt,
    this.creator,
    this.producer,
    this.pageCount,
    this.language,
    required this.customProperties,
  });

  static DocumentMetadata empty() => DocumentMetadata(
    title: '',
    keywords: [],
    customProperties: {},
  );
}

class DocumentProcessingJob {
  final String id;
  final String documentId;
  final DocumentProcessingType type;
  final ProcessingJobStatus status;
  final ProcessingConfiguration config;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double progress;
  final String? errorMessage;
  final Map<String, dynamic> results;
  final List<ProcessingStep> steps;

  DocumentProcessingJob({
    required this.id,
    required this.documentId,
    required this.type,
    required this.status,
    required this.config,
    required this.startedAt,
    this.completedAt,
    required this.progress,
    this.errorMessage,
    required this.results,
    required this.steps,
  });

  static DocumentProcessingJob empty() => DocumentProcessingJob(
    id: '',
    documentId: '',
    type: DocumentProcessingType.translation,
    status: ProcessingJobStatus.pending,
    config: ProcessingConfiguration.standard(),
    startedAt: DateTime.now(),
    progress: 0.0,
    results: {},
    steps: [],
  );
}

class ProcessingConfiguration {
  final String sourceLanguage;
  final List<String> targetLanguages;
  final bool preserveFormatting;
  final QualityLevel qualityLevel;
  final Map<String, dynamic> options;
  final List<String> processingSteps;

  ProcessingConfiguration({
    required this.sourceLanguage,
    required this.targetLanguages,
    required this.preserveFormatting,
    required this.qualityLevel,
    required this.options,
    required this.processingSteps,
  });

  static ProcessingConfiguration standard() => ProcessingConfiguration(
    sourceLanguage: 'auto-detect',
    targetLanguages: ['en'],
    preserveFormatting: true,
    qualityLevel: QualityLevel.high,
    options: {},
    processingSteps: ['extract', 'translate', 'reconstruct'],
  );
}

class ProcessingStep {
  final String name;
  final String description;
  final ProcessingStepStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double progress;
  final String? errorMessage;
  final Map<String, dynamic> output;

  ProcessingStep({
    required this.name,
    required this.description,
    required this.status,
    this.startedAt,
    this.completedAt,
    required this.progress,
    this.errorMessage,
    required this.output,
  });
}

class DocumentTranslationResult {
  final String id;
  final String documentId;
  final String sourceLanguage;
  final String targetLanguage;
  final Document translatedDocument;
  final TranslationQualityMetrics quality;
  final FormatPreservationReport formatting;
  final DateTime completedAt;
  final Duration processingTime;
  final Map<String, dynamic> metadata;

  DocumentTranslationResult({
    required this.id,
    required this.documentId,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.translatedDocument,
    required this.quality,
    required this.formatting,
    required this.completedAt,
    required this.processingTime,
    required this.metadata,
  });
}

class TranslationQualityMetrics {
  final double overallScore;
  final double accuracyScore;
  final double fluencyScore;
  final double consistencyScore;
  final double terminologyScore;
  final Map<String, double> segmentScores;
  final List<QualityIssue> issues;
  final int totalSegments;
  final int reviewedSegments;

  TranslationQualityMetrics({
    required this.overallScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.consistencyScore,
    required this.terminologyScore,
    required this.segmentScores,
    required this.issues,
    required this.totalSegments,
    required this.reviewedSegments,
  });

  static TranslationQualityMetrics empty() => TranslationQualityMetrics(
    overallScore: 0.0,
    accuracyScore: 0.0,
    fluencyScore: 0.0,
    consistencyScore: 0.0,
    terminologyScore: 0.0,
    segmentScores: {},
    issues: [],
    totalSegments: 0,
    reviewedSegments: 0,
  );
}

class QualityIssue {
  final String id;
  final QualityIssueType type;
  final String description;
  final QualityIssueSeverity severity;
  final String segmentId;
  final String originalText;
  final String translatedText;
  final String? suggestion;
  final Map<String, dynamic> context;

  QualityIssue({
    required this.id,
    required this.type,
    required this.description,
    required this.severity,
    required this.segmentId,
    required this.originalText,
    required this.translatedText,
    this.suggestion,
    required this.context,
  });
}

class FormatPreservationReport {
  final double overallScore;
  final Map<String, FormatElement> preservedElements;
  final List<FormatIssue> issues;
  final bool layoutPreserved;
  final bool stylingPreserved;
  final bool structurePreserved;
  final Map<String, dynamic> statistics;

  FormatPreservationReport({
    required this.overallScore,
    required this.preservedElements,
    required this.issues,
    required this.layoutPreserved,
    required this.stylingPreserved,
    required this.structurePreserved,
    required this.statistics,
  });

  static FormatPreservationReport empty() => FormatPreservationReport(
    overallScore: 0.0,
    preservedElements: {},
    issues: [],
    layoutPreserved: false,
    stylingPreserved: false,
    structurePreserved: false,
    statistics: {},
  );
}

class FormatElement {
  final String type;
  final String identifier;
  final bool preserved;
  final Map<String, dynamic> originalAttributes;
  final Map<String, dynamic> preservedAttributes;
  final String? reason;

  FormatElement({
    required this.type,
    required this.identifier,
    required this.preserved,
    required this.originalAttributes,
    required this.preservedAttributes,
    this.reason,
  });
}

class FormatIssue {
  final String id;
  final FormatIssueType type;
  final String description;
  final FormatIssueSeverity severity;
  final String elementId;
  final String? solution;

  FormatIssue({
    required this.id,
    required this.type,
    required this.description,
    required this.severity,
    required this.elementId,
    this.solution,
  });
}

class DocumentSegment {
  final String id;
  final String documentId;
  final int sequenceNumber;
  final String originalText;
  final String? translatedText;
  final SegmentType type;
  final Map<String, dynamic> formatting;
  final List<String> tags;
  final TranslationStatus status;
  final Map<String, dynamic> metadata;

  DocumentSegment({
    required this.id,
    required this.documentId,
    required this.sequenceNumber,
    required this.originalText,
    this.translatedText,
    required this.type,
    required this.formatting,
    required this.tags,
    required this.status,
    required this.metadata,
  });
}

class BatchProcessingJob {
  final String id;
  final String name;
  final List<String> documentIds;
  final ProcessingConfiguration config;
  final BatchJobStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double progress;
  final int totalDocuments;
  final int processedDocuments;
  final int failedDocuments;
  final List<BatchJobError> errors;
  final Map<String, dynamic> results;

  BatchProcessingJob({
    required this.id,
    required this.name,
    required this.documentIds,
    required this.config,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.progress,
    required this.totalDocuments,
    required this.processedDocuments,
    required this.failedDocuments,
    required this.errors,
    required this.results,
  });

  static BatchProcessingJob empty() => BatchProcessingJob(
    id: '',
    name: '',
    documentIds: [],
    config: ProcessingConfiguration.standard(),
    status: BatchJobStatus.created,
    createdAt: DateTime.now(),
    progress: 0.0,
    totalDocuments: 0,
    processedDocuments: 0,
    failedDocuments: 0,
    errors: [],
    results: {},
  );
}

class BatchJobError {
  final String documentId;
  final String errorCode;
  final String message;
  final String? stackTrace;
  final DateTime occurredAt;

  BatchJobError({
    required this.documentId,
    required this.errorCode,
    required this.message,
    this.stackTrace,
    required this.occurredAt,
  });
}

class DocumentExportOptions {
  final ExportFormat format;
  final bool includeMetadata;
  final bool preserveFormatting;
  final QualityLevel qualityLevel;
  final Map<String, dynamic> customOptions;
  final String? templateId;

  DocumentExportOptions({
    required this.format,
    required this.includeMetadata,
    required this.preserveFormatting,
    required this.qualityLevel,
    required this.customOptions,
    this.templateId,
  });

  static DocumentExportOptions standard() => DocumentExportOptions(
    format: ExportFormat.pdf,
    includeMetadata: true,
    preserveFormatting: true,
    qualityLevel: QualityLevel.high,
    customOptions: {},
  );
}

class DocumentComparisonResult {
  final String id;
  final String originalDocumentId;
  final String translatedDocumentId;
  final double similarityScore;
  final Map<String, double> sectionSimilarities;
  final List<DocumentDifference> differences;
  final ComparisonMetrics metrics;
  final DateTime comparedAt;

  DocumentComparisonResult({
    required this.id,
    required this.originalDocumentId,
    required this.translatedDocumentId,
    required this.similarityScore,
    required this.sectionSimilarities,
    required this.differences,
    required this.metrics,
    required this.comparedAt,
  });
}

class DocumentDifference {
  final String id;
  final DifferenceType type;
  final String description;
  final String originalContent;
  final String translatedContent;
  final int position;
  final DifferenceConfidence confidence;

  DocumentDifference({
    required this.id,
    required this.type,
    required this.description,
    required this.originalContent,
    required this.translatedContent,
    required this.position,
    required this.confidence,
  });
}

class ComparisonMetrics {
  final int totalSegments;
  final int identicalSegments;
  final int similarSegments;
  final int differentSegments;
  final double structuralSimilarity;
  final double semanticSimilarity;
  final double lexicalSimilarity;

  ComparisonMetrics({
    required this.totalSegments,
    required this.identicalSegments,
    required this.similarSegments,
    required this.differentSegments,
    required this.structuralSimilarity,
    required this.semanticSimilarity,
    required this.lexicalSimilarity,
  });
}

/// Enums
enum DocumentType {
  pdf,
  docx,
  pptx,
  xlsx,
  txt,
  html,
  xml,
  rtf,
  odt,
  odp,
  ods
}

enum DocumentStatus {
  uploaded,
  processing,
  completed,
  failed,
  archived
}

enum DocumentProcessingType {
  translation,
  ocr,
  formatting,
  analysis,
  conversion,
  batch
}

enum ProcessingJobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled
}

enum ProcessingStepStatus {
  pending,
  running,
  completed,
  failed,
  skipped
}

enum QualityLevel {
  basic,
  standard,
  high,
  premium
}

enum QualityIssueType {
  accuracy,
  fluency,
  consistency,
  terminology,
  grammar,
  punctuation,
  formatting
}

enum QualityIssueSeverity {
  low,
  medium,
  high,
  critical
}

enum FormatIssueType {
  layout,
  styling,
  structure,
  images,
  tables,
  fonts,
  spacing
}

enum FormatIssueSeverity {
  minor,
  moderate,
  major,
  critical
}

enum SegmentType {
  text,
  heading,
  paragraph,
  list,
  table,
  image,
  formula,
  footnote,
  header,
  footer
}

enum TranslationStatus {
  pending,
  inProgress,
  completed,
  reviewed,
  approved,
  rejected
}

enum BatchJobStatus {
  created,
  queued,
  running,
  paused,
  completed,
  failed,
  cancelled
}

enum ExportFormat {
  pdf,
  docx,
  html,
  txt,
  json,
  xml
}

enum DifferenceType {
  content,
  format,
  structure,
  metadata
}

enum DifferenceConfidence {
  low,
  medium,
  high,
  certain
}

/// Utility Classes
class DocumentTemplate {
  final String id;
  final String name;
  final DocumentType type;
  final Map<String, dynamic> structure;
  final List<String> requiredFields;
  final Map<String, dynamic> defaultValues;
  final DateTime createdAt;
  final String createdBy;

  DocumentTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.structure,
    required this.requiredFields,
    required this.defaultValues,
    required this.createdAt,
    required this.createdBy,
  });
}

class OCRResult {
  final String id;
  final String documentId;
  final List<OCRTextBlock> textBlocks;
  final double confidence;
  final String detectedLanguage;
  final Map<String, dynamic> metadata;
  final DateTime processedAt;

  OCRResult({
    required this.id,
    required this.documentId,
    required this.textBlocks,
    required this.confidence,
    required this.detectedLanguage,
    required this.metadata,
    required this.processedAt,
  });

  static OCRResult empty() => OCRResult(
    id: '',
    documentId: '',
    textBlocks: [],
    confidence: 0.0,
    detectedLanguage: '',
    metadata: {},
    processedAt: DateTime.now(),
  );
}

class OCRTextBlock {
  final String text;
  final double confidence;
  final BoundingBox boundingBox;
  final Map<String, dynamic> properties;

  OCRTextBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
    required this.properties,
  });
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
