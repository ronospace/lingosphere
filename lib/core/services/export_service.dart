// 🌐 LingoSphere - Export Service
// Comprehensive export functionality for translation history with multiple formats

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import '../models/translation_history.dart';
import '../models/translation_entry.dart';
import '../models/common_models.dart' as common;
import 'native_sharing_service.dart';

/// Export format options
enum ExportFormat {
  csv,
  json,
  pdf,
  txt,
}

/// Export content selection options
class ExportOptions {
  final bool includeOriginalText;
  final bool includeTranslatedText;
  final bool includeTimestamp;
  final bool includeLanguages;
  final bool includeConfidence;
  final bool includeSource;
  final bool includeCategory;
  final bool includeFavorites;
  final bool includeNotes;
  final bool includeUsageCount;
  final common.DateRange? dateRange;
  final List<String>? categories;
  final double? minConfidence;

  const ExportOptions({
    this.includeOriginalText = true,
    this.includeTranslatedText = true,
    this.includeTimestamp = true,
    this.includeLanguages = true,
    this.includeConfidence = false,
    this.includeSource = false,
    this.includeCategory = false,
    this.includeFavorites = false,
    this.includeNotes = false,
    this.includeUsageCount = false,
    this.dateRange,
    this.categories,
    this.minConfidence,
  });

  ExportOptions copyWith({
    bool? includeOriginalText,
    bool? includeTranslatedText,
    bool? includeTimestamp,
    bool? includeLanguages,
    bool? includeConfidence,
    bool? includeSource,
    bool? includeCategory,
    bool? includeFavorites,
    bool? includeNotes,
    bool? includeUsageCount,
    common.DateRange? dateRange,
    List<String>? categories,
    double? minConfidence,
  }) {
    return ExportOptions(
      includeOriginalText: includeOriginalText ?? this.includeOriginalText,
      includeTranslatedText:
          includeTranslatedText ?? this.includeTranslatedText,
      includeTimestamp: includeTimestamp ?? this.includeTimestamp,
      includeLanguages: includeLanguages ?? this.includeLanguages,
      includeConfidence: includeConfidence ?? this.includeConfidence,
      includeSource: includeSource ?? this.includeSource,
      includeCategory: includeCategory ?? this.includeCategory,
      includeFavorites: includeFavorites ?? this.includeFavorites,
      includeNotes: includeNotes ?? this.includeNotes,
      includeUsageCount: includeUsageCount ?? this.includeUsageCount,
      dateRange: dateRange ?? this.dateRange,
      categories: categories ?? this.categories,
      minConfidence: minConfidence ?? this.minConfidence,
    );
  }
}

/// Export result with file information
class ExportResult {
  final String filePath;
  final String fileName;
  final ExportFormat format;
  final int itemCount;
  final int fileSizeBytes;
  final DateTime exportTime;

  const ExportResult({
    required this.filePath,
    required this.fileName,
    required this.format,
    required this.itemCount,
    required this.fileSizeBytes,
    required this.exportTime,
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024)
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Export service for handling various export formats
class ExportService {
  static const String _exportFolderName = 'LingoSphere_Exports';

  /// Export translation entries to specified format
  Future<ExportResult> exportTranslations({
    required List<TranslationEntry> entries,
    required ExportFormat format,
    required ExportOptions options,
    String? customFileName,
  }) async {
    try {
      // Filter entries based on options
      final filteredEntries = _filterEntries(entries, options);

      if (filteredEntries.isEmpty) {
        throw Exception('No items to export with current filter criteria');
      }

      // Generate filename
      final fileName = customFileName ?? _generateFileName(format);

      // Create export directory
      final exportDir = await _getExportDirectory();
      final filePath = '${exportDir.path}/$fileName';

      // Export based on format
      late Uint8List data;
      switch (format) {
        case ExportFormat.csv:
          data = await _exportToCsv(filteredEntries, options);
          break;
        case ExportFormat.json:
          data = await _exportToJson(filteredEntries, options);
          break;
        case ExportFormat.pdf:
          data = await _exportToPdf(filteredEntries, options);
          break;
        case ExportFormat.txt:
          data = await _exportToTxt(filteredEntries, options);
          break;
      }

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(data);

      return ExportResult(
        filePath: filePath,
        fileName: fileName,
        format: format,
        itemCount: filteredEntries.length,
        fileSizeBytes: data.length,
        exportTime: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Export error: $e');
      rethrow;
    }
  }

  /// Share exported file
  Future<void> shareExport(ExportResult result) async {
    try {
      await Share.shareXFiles(
        [XFile(result.filePath)],
        text:
            'LingoSphere Translation History Export (${result.itemCount} items)',
        subject: 'Translation History - ${result.fileName}',
      );
    } catch (e) {
      debugPrint('Share error: $e');
      rethrow;
    }
  }

  /// Get available export formats
  List<ExportFormat> getAvailableFormats() {
    return ExportFormat.values;
  }

  /// Get format display name
  String getFormatDisplayName(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'CSV (Spreadsheet)';
      case ExportFormat.json:
        return 'JSON (Data)';
      case ExportFormat.pdf:
        return 'PDF (Document)';
      case ExportFormat.txt:
        return 'TXT (Plain Text)';
    }
  }

  /// Get format icon
  String getFormatIcon(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return '📊';
      case ExportFormat.json:
        return '🔧';
      case ExportFormat.pdf:
        return '📄';
      case ExportFormat.txt:
        return '📝';
    }
  }

  /// Get format description
  String getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'Spreadsheet format compatible with Excel, Google Sheets, and other tools';
      case ExportFormat.json:
        return 'Structured data format for developers and data analysis';
      case ExportFormat.pdf:
        return 'Formatted document ideal for sharing and printing';
      case ExportFormat.txt:
        return 'Simple text format for basic viewing and editing';
    }
  }

  /// Filter entries based on export options
  List<TranslationEntry> _filterEntries(
      List<TranslationEntry> entries, ExportOptions options) {
    return entries.where((item) {
      // Date range filter
      if (options.dateRange != null) {
        if (item.timestamp.isBefore(options.dateRange!.start) ||
            item.timestamp.isAfter(options.dateRange!.end)) {
          return false;
        }
      }

      // Category filter
      if (options.categories != null && options.categories!.isNotEmpty) {
        if (item.category == null ||
            !options.categories!.contains(item.category.toString())) {
          return false;
        }
      }

      // Confidence filter
      if (options.minConfidence != null) {
        if (item.confidence < options.minConfidence!) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Export to CSV format
  Future<Uint8List> _exportToCsv(
      List<TranslationEntry> entries, ExportOptions options) async {
    final List<List<String>> rows = [];

    // Header row
    final headers = <String>[];
    if (options.includeTimestamp) headers.add('Date/Time');
    if (options.includeOriginalText) headers.add('Original Text');
    if (options.includeTranslatedText) headers.add('Translation');
    if (options.includeLanguages) {
      headers.add('Source Language');
      headers.add('Target Language');
    }
    if (options.includeConfidence) headers.add('Confidence');
    if (options.includeSource) headers.add('Source');
    if (options.includeCategory) headers.add('Category');
    if (options.includeFavorites) headers.add('Favorite');
    if (options.includeUsageCount) headers.add('Usage Count');
    if (options.includeNotes) headers.add('Notes');

    rows.add(headers);

    // Data rows
    for (final item in entries) {
      final row = <String>[];

      if (options.includeTimestamp) {
        row.add(item.timestamp.toIso8601String());
      }
      if (options.includeOriginalText) {
        row.add(item.sourceText);
      }
      if (options.includeTranslatedText) {
        row.add(item.translatedText);
      }
      if (options.includeLanguages) {
        row.add(item.sourceLanguage);
        row.add(item.targetLanguage);
      }
      if (options.includeConfidence) {
        row.add((item.confidence * 100).toStringAsFixed(1) + '%');
      }
      if (options.includeSource) {
        row.add(item.type.toString());
      }
      if (options.includeCategory) {
        row.add(item.category?.toString() ?? '');
      }
      if (options.includeFavorites) {
        row.add(item.isFavorite ? 'Yes' : 'No');
      }
      if (options.includeUsageCount) {
        row.add('1'); // Default usage count for TranslationEntry
      }
      if (options.includeNotes) {
        row.add(item.notes ?? '');
      }

      rows.add(row);
    }

    final csv = const ListToCsvConverter().convert(rows);
    return Uint8List.fromList(utf8.encode(csv));
  }

  /// Export to JSON format
  Future<Uint8List> _exportToJson(
      List<TranslationEntry> entries, ExportOptions options) async {
    final exportData = {
      'metadata': {
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0',
        'application': 'LingoSphere',
        'itemCount': entries.length,
      },
      'options': {
        'includeOriginalText': options.includeOriginalText,
        'includeTranslatedText': options.includeTranslatedText,
        'includeTimestamp': options.includeTimestamp,
        'includeLanguages': options.includeLanguages,
        'includeConfidence': options.includeConfidence,
        'includeSource': options.includeSource,
        'includeCategory': options.includeCategory,
        'includeFavorites': options.includeFavorites,
        'includeNotes': options.includeNotes,
        'includeUsageCount': options.includeUsageCount,
      },
      'translations':
          entries.map((item) => _itemToJson(item, options)).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    return Uint8List.fromList(utf8.encode(jsonString));
  }

  /// Export to PDF format
  Future<Uint8List> _exportToPdf(
      List<TranslationEntry> entries, ExportOptions options) async {
    final pdf = pw.Document();

    // Add pages with entries
    const itemsPerPage = 10;
    for (int i = 0; i < entries.length; i += itemsPerPage) {
      final pageItems = entries.skip(i).take(itemsPerPage).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Text(
              'LingoSphere Translation History - Page ${context.pageNumber}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Exported on ${DateTime.now().toString().split('.').first}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ),
          build: (context) => [
            if (context.pageNumber == 1)
              pw.Header(
                level: 0,
                child: pw.Text('Translation History Export'),
              ),
            ...pageItems.map((item) => _buildPdfItem(item, options)).toList(),
          ],
        ),
      );
    }

    return await pdf.save();
  }

  /// Export to TXT format
  Future<Uint8List> _exportToTxt(
      List<TranslationEntry> entries, ExportOptions options) async {
    final buffer = StringBuffer();

    buffer.writeln('LingoSphere Translation History Export');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Items: ${entries.length}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (int i = 0; i < entries.length; i++) {
      final item = entries[i];
      buffer.writeln('Entry ${i + 1}:');

      if (options.includeTimestamp) {
        buffer.writeln('Date: ${item.timestamp}');
      }

      if (options.includeLanguages) {
        buffer.writeln('${item.sourceLanguage} → ${item.targetLanguage}');
      }

      if (options.includeOriginalText) {
        buffer.writeln('Original: ${item.sourceText}');
      }

      if (options.includeTranslatedText) {
        buffer.writeln('Translation: ${item.translatedText}');
      }

      if (options.includeConfidence) {
        buffer.writeln(
            'Confidence: ${(item.confidence * 100).toStringAsFixed(1)}%');
      }

      if (options.includeSource) {
        buffer.writeln('Source: ${item.type.toString()}');
      }

      if (options.includeCategory && item.category != null) {
        buffer.writeln('Category: ${item.category}');
      }

      if (options.includeFavorites) {
        buffer.writeln('Favorite: ${item.isFavorite ? 'Yes' : 'No'}');
      }

      if (options.includeUsageCount) {
        buffer.writeln('Usage Count: 1'); // Default usage count
      }

      if (options.includeNotes && item.notes != null) {
        buffer.writeln('Notes: ${item.notes}');
      }

      buffer.writeln('-' * 30);
      buffer.writeln();
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  /// Convert translation entry to JSON
  Map<String, dynamic> _itemToJson(
      TranslationEntry item, ExportOptions options) {
    final json = <String, dynamic>{};

    if (options.includeTimestamp)
      json['timestamp'] = item.timestamp.toIso8601String();
    if (options.includeOriginalText) json['originalText'] = item.sourceText;
    if (options.includeTranslatedText)
      json['translatedText'] = item.translatedText;
    if (options.includeLanguages) {
      json['sourceLanguage'] = item.sourceLanguage;
      json['targetLanguage'] = item.targetLanguage;
    }
    if (options.includeConfidence) json['confidence'] = item.confidence;
    if (options.includeSource) json['source'] = item.type.toString();
    if (options.includeCategory) json['category'] = item.category;
    if (options.includeFavorites) json['isFavorite'] = item.isFavorite;
    if (options.includeUsageCount)
      json['usageCount'] = 1; // Default usage count
    if (options.includeNotes) json['notes'] = item.notes;

    return json;
  }

  /// Build PDF widget for translation entry
  pw.Widget _buildPdfItem(TranslationEntry item, ExportOptions options) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (options.includeTimestamp)
            pw.Text(
              item.timestamp.toString().split('.').first,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          if (options.includeLanguages)
            pw.Text(
              '${item.sourceLanguage} → ${item.targetLanguage}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          if (options.includeOriginalText) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Original: ${item.sourceText}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
          if (options.includeTranslatedText) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              'Translation: ${item.translatedText}',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ],
          if (options.includeConfidence ||
              options.includeSource ||
              options.includeCategory ||
              options.includeFavorites) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                if (options.includeConfidence)
                  pw.Text(
                    'Confidence: ${(item.confidence * 100).toStringAsFixed(1)}%',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                if (options.includeSource) ...[
                  if (options.includeConfidence) pw.SizedBox(width: 10),
                  pw.Text(
                    'Source: ${item.type.toString()}',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ],
                if (options.includeCategory && item.category != null) ...[
                  if (options.includeConfidence || options.includeSource)
                    pw.SizedBox(width: 10),
                  pw.Text(
                    'Category: ${item.category}',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ],
                if (options.includeFavorites && item.isFavorite) ...[
                  pw.SizedBox(width: 10),
                  pw.Text(
                    '★ Favorite',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.orange),
                  ),
                ],
              ],
            ),
          ],
          if (options.includeNotes && item.notes != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Notes: ${item.notes}',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  /// Generate filename based on format and timestamp
  String _generateFileName(ExportFormat format) {
    final timestamp = DateTime.now();
    final dateStr =
        '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}-${timestamp.minute.toString().padLeft(2, '0')}';

    final extension = _getFileExtension(format);
    return 'lingosphere_export_${dateStr}_$timeStr$extension';
  }

  /// Get file extension for format
  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.json:
        return '.json';
      case ExportFormat.pdf:
        return '.pdf';
      case ExportFormat.txt:
        return '.txt';
    }
  }

  /// Get export directory
  Future<Directory> _getExportDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${documentsDir.path}/$_exportFolderName');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    return exportDir;
  }

  /// Get all exported files
  Future<List<File>> getExportedFiles() async {
    try {
      final exportDir = await _getExportDirectory();
      final files = await exportDir
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();

      // Sort by modification time (newest first)
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      return files;
    } catch (e) {
      debugPrint('Error getting exported files: $e');
      return [];
    }
  }

  /// Delete exported file
  Future<void> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting exported file: $e');
      rethrow;
    }
  }

  /// Get export statistics
  Future<Map<String, dynamic>> getExportStatistics() async {
    try {
      final files = await getExportedFiles();
      final stats = <String, dynamic>{};

      stats['totalFiles'] = files.length;
      stats['totalSize'] =
          files.fold<int>(0, (sum, file) => sum + file.lengthSync());

      final formatCounts = <String, int>{};
      for (final file in files) {
        final extension = file.path.split('.').last.toLowerCase();
        formatCounts[extension] = (formatCounts[extension] ?? 0) + 1;
      }
      stats['formatBreakdown'] = formatCounts;

      if (files.isNotEmpty) {
        stats['newestExport'] = files.first.lastModifiedSync();
        stats['oldestExport'] = files.last.lastModifiedSync();
      }

      return stats;
    } catch (e) {
      debugPrint('Error getting export statistics: $e');
      return {};
    }
  }

  /// Export history using TranslationHistory models
  Future<ExportResult> exportHistory({
    required List<TranslationHistory> history,
    required ExportFormat format,
    required ExportOptions options,
    String? customFileName,
  }) async {
    // TranslationHistory contains a collection of TranslationEntry objects
    // Extract all entries from all history collections
    final allEntries = <TranslationEntry>[];
    for (final historyCollection in history) {
      allEntries.addAll(historyCollection.entries);
    }

    return await exportTranslations(
      entries: allEntries,
      format: format,
      options: options,
      customFileName: customFileName,
    );
  }

  /// Export translation entries directly (for new TranslationEntry model)
  Future<ExportResult> exportTranslationEntries({
    required List<TranslationEntry> entries,
    required ExportFormat format,
    required ExportOptions options,
    String? customFileName,
  }) async {
    // TranslationEntry objects can be exported directly
    return await exportTranslations(
      entries: entries,
      format: format,
      options: options,
      customFileName: customFileName,
    );
  }

  /// Export voice translation with audio file integration
  Future<ExportResult> exportVoiceTranslationWithAudio({
    required TranslationEntry translation,
    required String audioFilePath,
    String? customFileName,
  }) async {
    try {
      final exportDir = await _getExportDirectory();
      final timestamp = DateTime.now();
      final dateStr = timestamp.toIso8601String().split('T')[0];
      final timeStr =
          '${timestamp.hour.toString().padLeft(2, '0')}-${timestamp.minute.toString().padLeft(2, '0')}';

      final baseName =
          customFileName ?? 'voice_translation_${dateStr}_$timeStr';

      // Create a folder for this voice translation
      final voiceExportDir = Directory('${exportDir.path}/${baseName}_package');
      await voiceExportDir.create(recursive: true);

      // Copy audio file
      final audioFile = File(audioFilePath);
      final audioFileName = 'audio.${audioFilePath.split('.').last}';
      final targetAudioPath = '${voiceExportDir.path}/$audioFileName';
      await audioFile.copy(targetAudioPath);

      // Create text file with translation details
      final textContent = '''
Voice Translation Export
========================

Audio File: $audioFileName
Export Date: ${timestamp.toString().split('.').first}

Languages: ${translation.sourceLanguage} → ${translation.targetLanguage}

Original Text (${translation.sourceLanguage.toUpperCase()}):
${translation.sourceText}

Translation (${translation.targetLanguage.toUpperCase()}):
${translation.translatedText}

Translation ID: ${translation.id}
Type: ${translation.type}
Timestamp: ${translation.timestamp.toIso8601String()}
Favorite: ${translation.isFavorite ? 'Yes' : 'No'}

---
Generated by LingoSphere
AI-Powered Translation Platform
''';

      final textFile = File('${voiceExportDir.path}/translation_details.txt');
      await textFile.writeAsString(textContent);

      // Create README file
      final readmeContent = '''
LingoSphere Voice Translation Export
=====================================

This package contains:
- audio.$audioFileName.split('.').last}: Original audio recording
- translation_details.txt: Translation information and metadata
- README.txt: This file

How to use:
1. Open translation_details.txt to view the translation
2. Play the audio file to hear the original recording
3. Share this entire folder to preserve the complete translation context

For more information about LingoSphere, visit our website.
''';

      final readmeFile = File('${voiceExportDir.path}/README.txt');
      await readmeFile.writeAsString(readmeContent);

      // Calculate total size
      final files = await voiceExportDir
          .list(recursive: true)
          .where((entity) => entity is File)
          .cast<File>()
          .toList();
      final totalSize =
          files.fold<int>(0, (sum, file) => sum + file.lengthSync());

      return ExportResult(
        filePath: voiceExportDir.path,
        fileName: '${baseName}_package',
        format: ExportFormat.txt, // Closest format for mixed content
        itemCount: 1,
        fileSizeBytes: totalSize,
        exportTime: timestamp,
      );
    } catch (e) {
      debugPrint('Error exporting voice translation: $e');
      rethrow;
    }
  }

  /// Export image translation with image file
  Future<ExportResult> exportImageTranslationWithImage({
    required TranslationEntry translation,
    required String imageFilePath,
    String? customFileName,
  }) async {
    try {
      final exportDir = await _getExportDirectory();
      final timestamp = DateTime.now();
      final dateStr = timestamp.toIso8601String().split('T')[0];
      final timeStr =
          '${timestamp.hour.toString().padLeft(2, '0')}-${timestamp.minute.toString().padLeft(2, '0')}';

      final baseName =
          customFileName ?? 'image_translation_${dateStr}_$timeStr';

      // Create a folder for this image translation
      final imageExportDir = Directory('${exportDir.path}/${baseName}_package');
      await imageExportDir.create(recursive: true);

      // Copy image file
      final imageFile = File(imageFilePath);
      final imageFileName = 'image.${imageFilePath.split('.').last}';
      final targetImagePath = '${imageExportDir.path}/$imageFileName';
      await imageFile.copy(targetImagePath);

      // Create comprehensive translation report
      final reportContent = '''
Image Translation Report
========================

Image File: $imageFileName
Export Date: ${timestamp.toString().split('.').first}

TRANSLATION DETAILS
-------------------
Languages: ${translation.sourceLanguage} → ${translation.targetLanguage}

Extracted Text (${translation.sourceLanguage.toUpperCase()}):
${translation.sourceText}

Translation (${translation.targetLanguage.toUpperCase()}):
${translation.translatedText}

METADATA
--------
Translation ID: ${translation.id}
Type: ${translation.type}
Timestamp: ${translation.timestamp.toIso8601String()}
Favorite: ${translation.isFavorite ? 'Yes' : 'No'}

USAGE INSTRUCTIONS
------------------
1. View the original image: $imageFileName
2. Review extracted text and translation above
3. Use this data for documentation, presentations, or further analysis

TECHNICAL INFO
--------------
OCR Engine: Google ML Kit Text Recognition
Translation Engine: Multi-provider AI translation
Accuracy: High-confidence text extraction and translation

---
Generated by LingoSphere
🌐 AI-Powered Translation Platform
''';

      final reportFile = File('${imageExportDir.path}/translation_report.txt');
      await reportFile.writeAsString(reportContent);

      // Create JSON metadata for programmatic access
      final metadataJson = {
        'export': {
          'type': 'image_translation',
          'version': '1.0',
          'exported_at': timestamp.toIso8601String(),
          'application': 'LingoSphere',
        },
        'files': {
          'image': imageFileName,
          'report': 'translation_report.txt',
          'metadata': 'metadata.json',
        },
        'translation': {
          'id': translation.id,
          'source_language': translation.sourceLanguage,
          'target_language': translation.targetLanguage,
          'source_text': translation.sourceText,
          'translated_text': translation.translatedText,
          'timestamp': translation.timestamp.toIso8601String(),
          'type': translation.type,
          'is_favorite': translation.isFavorite,
        },
        'statistics': {
          'source_char_count': translation.sourceText.length,
          'translated_char_count': translation.translatedText.length,
          'source_word_count': translation.sourceText.split(' ').length,
          'translated_word_count': translation.translatedText.split(' ').length,
        },
      };

      final metadataFile = File('${imageExportDir.path}/metadata.json');
      await metadataFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(metadataJson));

      // Calculate total size
      final files = await imageExportDir
          .list(recursive: true)
          .where((entity) => entity is File)
          .cast<File>()
          .toList();
      final totalSize =
          files.fold<int>(0, (sum, file) => sum + file.lengthSync());

      return ExportResult(
        filePath: imageExportDir.path,
        fileName: '${baseName}_package',
        format: ExportFormat.json, // Primary format is JSON metadata
        itemCount: 1,
        fileSizeBytes: totalSize,
        exportTime: timestamp,
      );
    } catch (e) {
      debugPrint('Error exporting image translation: $e');
      rethrow;
    }
  }

  /// Export conversation with multimedia support
  Future<ExportResult> exportConversationWithMedia({
    required List<TranslationEntry> conversation,
    required String conversationTitle,
    List<String>? audioFiles,
    List<String>? imageFiles,
    String? customFileName,
  }) async {
    try {
      final exportDir = await _getExportDirectory();
      final timestamp = DateTime.now();
      final dateStr = timestamp.toIso8601String().split('T')[0];
      final timeStr =
          '${timestamp.hour.toString().padLeft(2, '0')}-${timestamp.minute.toString().padLeft(2, '0')}';

      final baseName = customFileName ?? 'conversation_${dateStr}_$timeStr';

      // Create conversation export directory
      final conversationDir =
          Directory('${exportDir.path}/${baseName}_package');
      await conversationDir.create(recursive: true);

      // Create subdirectories for organization
      final mediaDir = Directory('${conversationDir.path}/media');
      final docsDir = Directory('${conversationDir.path}/documents');
      await mediaDir.create();
      await docsDir.create();

      // Copy media files
      final copiedAudioFiles = <String>[];
      if (audioFiles != null) {
        for (int i = 0; i < audioFiles.length; i++) {
          final audioFile = File(audioFiles[i]);
          final fileName = 'audio_${i + 1}.${audioFiles[i].split('.').last}';
          final targetPath = '${mediaDir.path}/$fileName';
          await audioFile.copy(targetPath);
          copiedAudioFiles.add(fileName);
        }
      }

      final copiedImageFiles = <String>[];
      if (imageFiles != null) {
        for (int i = 0; i < imageFiles.length; i++) {
          final imageFile = File(imageFiles[i]);
          final fileName = 'image_${i + 1}.${imageFiles[i].split('.').last}';
          final targetPath = '${mediaDir.path}/$fileName';
          await imageFile.copy(targetPath);
          copiedImageFiles.add(fileName);
        }
      }

      // Generate comprehensive conversation report
      final reportBuffer = StringBuffer();
      reportBuffer.writeln('$conversationTitle');
      reportBuffer.writeln('=' * conversationTitle.length);
      reportBuffer.writeln();
      reportBuffer
          .writeln('Export Date: ${timestamp.toString().split('.').first}');
      reportBuffer.writeln('Total Translations: ${conversation.length}');
      reportBuffer.writeln(
          'Languages: ${_getUniqueLanguages(conversation).join(', ')}');

      if (copiedAudioFiles.isNotEmpty) {
        reportBuffer.writeln('Audio Files: ${copiedAudioFiles.length}');
      }
      if (copiedImageFiles.isNotEmpty) {
        reportBuffer.writeln('Image Files: ${copiedImageFiles.length}');
      }
      reportBuffer.writeln();

      reportBuffer.writeln('CONVERSATION TRANSCRIPT');
      reportBuffer.writeln('-' * 25);
      reportBuffer.writeln();

      for (int i = 0; i < conversation.length; i++) {
        final entry = conversation[i];
        reportBuffer.writeln(
            '[${i + 1}] ${entry.timestamp.toString().split('.').first}');
        reportBuffer
            .writeln('${entry.sourceLanguage} → ${entry.targetLanguage}');
        reportBuffer.writeln('Original: ${entry.sourceText}');
        reportBuffer.writeln('Translation: ${entry.translatedText}');
        reportBuffer.writeln();
      }

      // Add media references
      if (copiedAudioFiles.isNotEmpty || copiedImageFiles.isNotEmpty) {
        reportBuffer.writeln('MEDIA FILES');
        reportBuffer.writeln('-' * 11);
        reportBuffer.writeln();

        for (final audioFile in copiedAudioFiles) {
          reportBuffer.writeln('🎙️ Audio: media/$audioFile');
        }
        for (final imageFile in copiedImageFiles) {
          reportBuffer.writeln('📷 Image: media/$imageFile');
        }
        reportBuffer.writeln();
      }

      reportBuffer.writeln('---');
      reportBuffer.writeln('Generated by LingoSphere');
      reportBuffer.writeln('🌐 AI-Powered Translation Platform');

      final reportFile = File('${docsDir.path}/conversation_report.txt');
      await reportFile.writeAsString(reportBuffer.toString());

      // Generate JSON export for the conversation
      await exportTranslationEntries(
        entries: conversation,
        format: ExportFormat.json,
        options: const ExportOptions(
          includeOriginalText: true,
          includeTranslatedText: true,
          includeTimestamp: true,
          includeLanguages: true,
          includeSource: true,
        ),
        customFileName: '${docsDir.path}/conversation_data.json',
      );

      // Create package index
      final indexContent = '''
LingoSphere Conversation Export Package
========================================

This package contains:
📁 documents/
   - conversation_report.txt: Human-readable conversation transcript
   - conversation_data.json: Machine-readable conversation data
   - lingosphere_export_*.json: Detailed export data

📁 media/
   - Audio files: ${copiedAudioFiles.join(', ')}
   - Image files: ${copiedImageFiles.join(', ')}

Total conversations: ${conversation.length}
Exported: ${timestamp.toString().split('.').first}

To view:
1. Open conversation_report.txt for the transcript
2. Use conversation_data.json for data analysis
3. Media files are organized in the media/ folder
''';

      final indexFile = File('${conversationDir.path}/README.txt');
      await indexFile.writeAsString(indexContent);

      // Calculate total package size
      final files = await conversationDir
          .list(recursive: true)
          .where((entity) => entity is File)
          .cast<File>()
          .toList();
      final totalSize =
          files.fold<int>(0, (sum, file) => sum + file.lengthSync());

      return ExportResult(
        filePath: conversationDir.path,
        fileName: '${baseName}_package',
        format: ExportFormat.json,
        itemCount: conversation.length,
        fileSizeBytes: totalSize,
        exportTime: timestamp,
      );
    } catch (e) {
      debugPrint('Error exporting conversation with media: $e');
      rethrow;
    }
  }

  /// Share export result using native sharing service
  Future<void> shareExportWithNativeService(ExportResult result) async {
    try {
      final sharingService = NativeSharingService();

      // Create share content based on export result
      final shareContent = ShareContent(
        type: ShareContentType.file,
        files: [XFile(result.filePath)],
        text: 'LingoSphere Export: ${result.fileName}\n\n'
            '📊 ${result.itemCount} translations\n'
            '💾 ${result.fileSizeFormatted}\n'
            '📅 ${result.exportTime.toString().split('.').first}',
        subject: 'LingoSphere Translation Export - ${result.fileName}',
        metadata: {
          'export_format': result.format.toString(),
          'item_count': result.itemCount,
          'file_size': result.fileSizeBytes,
          'export_time': result.exportTime.toIso8601String(),
        },
      );

      await sharingService.shareContent(shareContent);
    } catch (e) {
      debugPrint('Error sharing export with native service: $e');
      rethrow;
    }
  }

  // Helper methods for new functionality

  Set<String> _getUniqueLanguages(List<TranslationEntry> entries) {
    final languages = <String>{};
    for (final entry in entries) {
      languages.add(entry.sourceLanguage);
      languages.add(entry.targetLanguage);
    }
    return languages;
  }
}
