// 🧪 Voice Translation Test Runner Screen
// Interactive testing interface for voice translation capabilities

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../services/voice_translation_test_service.dart';
import '../../../main.dart';

class VoiceTranslationTestScreen extends ConsumerStatefulWidget {
  const VoiceTranslationTestScreen({super.key});

  @override
  ConsumerState<VoiceTranslationTestScreen> createState() =>
      _VoiceTranslationTestScreenState();
}

class _VoiceTranslationTestScreenState 
    extends ConsumerState<VoiceTranslationTestScreen> {
  
  final VoiceTranslationTestService _testService = VoiceTranslationTestService();
  
  VoiceTestSuite? _currentTestSuite;
  bool _isRunning = false;
  double _progress = 0.0;
  String _currentTestName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text(
          'Voice Translation Tests',
          style: TextStyle(
            fontFamily: AppTheme.headingFontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 2,
        actions: [
          if (!_isRunning)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _runTests,
              tooltip: 'Run Tests',
            ),
        ],
      ),
      body: SafeArea(
        child: AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildTestHeader(),
                Expanded(child: _buildTestContent()),
                if (_isRunning) _buildProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: !_isRunning ? FloatingActionButton.extended(
        onPressed: _runTests,
        backgroundColor: AppTheme.vibrantGreen,
        label: const Text('Run All Tests'),
        icon: const Icon(Icons.science),
      ) : null,
    );
  }

  Widget _buildTestHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppTheme.vibrantGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.science,
                    color: AppTheme.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Voice Translation Test Suite',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comprehensive testing of voice features',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentTestSuite != null) _buildResultBadge(),
              ],
            ),
            const SizedBox(height: 16),
            _buildTestStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBadge() {
    if (_currentTestSuite == null) return const SizedBox.shrink();

    final result = _currentTestSuite!.overallResult;
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (result) {
      case TestResult.pass:
        badgeColor = Colors.green;
        badgeText = 'PASSED';
        badgeIcon = Icons.check_circle;
        break;
      case TestResult.warning:
        badgeColor = Colors.orange;
        badgeText = 'WARNING';
        badgeIcon = Icons.warning;
        break;
      case TestResult.fail:
        badgeColor = Colors.red;
        badgeText = 'FAILED';
        badgeIcon = Icons.error;
        break;
      case TestResult.pending:
        badgeColor = Colors.blue;
        badgeText = 'PENDING';
        badgeIcon = Icons.pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: badgeColor, size: 16),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestStats() {
    if (_currentTestSuite == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.gray100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.gray600),
            const SizedBox(width: 12),
            Text(
              'No tests have been run yet',
              style: TextStyle(
                color: AppTheme.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final suite = _currentTestSuite!;
    final passedTests = suite.testResults
        .where((test) => test.result == TestResult.pass).length;
    final totalTests = suite.testResults.length;
    final duration = suite.totalDuration;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Tests Passed',
            '$passedTests/$totalTests',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            'Duration',
            _formatDuration(duration),
            Icons.timer,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            'Success Rate',
            '${((passedTests / totalTests) * 100).toInt()}%',
            Icons.trending_up,
            passedTests == totalTests ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestContent() {
    if (_isRunning) {
      return _buildRunningTests();
    } else if (_currentTestSuite != null) {
      return _buildTestResults();
    } else {
      return _buildInitialState();
    }
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.vibrantGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.science,
              size: 60,
              color: AppTheme.vibrantGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ready to Test Voice Features',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Run comprehensive tests to validate\nvoice translation capabilities',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 32),
          _buildTestCategories(),
        ],
      ),
    );
  }

  Widget _buildTestCategories() {
    final testCategories = [
      {'name': 'Voice Service Initialization', 'icon': Icons.settings_voice},
      {'name': 'Speech Recognition', 'icon': Icons.mic},
      {'name': 'Translation Quality', 'icon': Icons.translate},
      {'name': 'Text-to-Speech', 'icon': Icons.volume_up},
      {'name': 'Real-time Performance', 'icon': Icons.speed},
      {'name': 'Conversation Mode', 'icon': Icons.chat},
      {'name': 'Language Detection', 'icon': Icons.language},
      {'name': 'Audio Quality', 'icon': Icons.audio_file},
      {'name': 'Multi-language Support', 'icon': Icons.public},
      {'name': 'Error Handling', 'icon': Icons.error_outline},
    ];

    return Column(
      children: [
        Text(
          'Test Categories:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray700,
          ),
        ),
        const SizedBox(height: 16),
        ...testCategories.map((category) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category['icon'] as IconData,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                category['name'] as String,
                style: TextStyle(
                  color: AppTheme.gray600,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildRunningTests() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 6,
                    backgroundColor: AppTheme.gray300,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
                  ),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Running Tests...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _currentTestName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Please wait while tests are running...',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    final suite = _currentTestSuite!;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suite.testResults.length,
      itemBuilder: (context, index) {
        final testResult = suite.testResults[index];
        return _buildTestResultCard(testResult);
      },
    );
  }

  Widget _buildTestResultCard(VoiceTestResult testResult) {
    Color resultColor;
    IconData resultIcon;

    switch (testResult.result) {
      case TestResult.pass:
        resultColor = Colors.green;
        resultIcon = Icons.check_circle;
        break;
      case TestResult.warning:
        resultColor = Colors.orange;
        resultIcon = Icons.warning;
        break;
      case TestResult.fail:
        resultColor = Colors.red;
        resultIcon = Icons.error;
        break;
      case TestResult.pending:
        resultColor = Colors.blue;
        resultIcon = Icons.pending;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: resultColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(resultIcon, color: resultColor, size: 20),
        ),
        title: Text(
          testResult.testName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              testResult.details,
              style: TextStyle(
                color: AppTheme.gray600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${_formatDuration(testResult.duration)}',
              style: TextStyle(
                color: AppTheme.gray500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTestMetrics(testResult.metrics),
          ),
        ],
      ),
    );
  }

  Widget _buildTestMetrics(Map<String, dynamic> metrics) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Metrics:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.gray800,
          ),
        ),
        const SizedBox(height: 8),
        ...metrics.entries.map((entry) {
          // Skip complex objects for display
          if (entry.value is List || entry.value is Map) {
            return const SizedBox.shrink();
          }
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ${_formatMetricKey(entry.key)}: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray700,
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatMetricValue(entry.value),
                    style: TextStyle(
                      color: AppTheme.gray600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _currentTestName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppTheme.gray300,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _progress = 0.0;
      _currentTestName = 'Initializing tests...';
      _currentTestSuite = null;
    });

    try {
      // Simulate progress updates
      final testNames = [
        'Voice Service Initialization',
        'Speech Recognition Accuracy',
        'Translation Quality',
        'TTS Performance',
        'Real-time Translation Speed',
        'Voice Conversation Mode',
        'Language Detection Accuracy',
        'Audio Quality and Noise Handling',
        'Multi-language Support',
        'Error Handling and Recovery',
      ];

      for (int i = 0; i < testNames.length; i++) {
        setState(() {
          _currentTestName = testNames[i];
          _progress = (i + 1) / testNames.length;
        });
        
        // Add a small delay to simulate test execution
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Run the actual tests
      final testSuite = await _testService.runComprehensiveTests();

      setState(() {
        _currentTestSuite = testSuite;
        _isRunning = false;
        _progress = 1.0;
        _currentTestName = 'Tests completed';
      });

      // Show completion snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Voice translation tests completed: ${testSuite.overallResult.name.toUpperCase()}',
            ),
            backgroundColor: testSuite.overallResult == TestResult.pass 
                ? Colors.green 
                : testSuite.overallResult == TestResult.warning
                    ? Colors.orange
                    : Colors.red,
          ),
        );
      }

      logger.i('Voice translation tests completed with result: ${testSuite.overallResult}');

    } catch (e) {
      logger.e('Voice translation tests failed: $e');
      
      setState(() {
        _isRunning = false;
        _currentTestName = 'Test failed';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test execution failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }

  String _formatMetricKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatMetricValue(dynamic value) {
    if (value is double) {
      if (value < 1.0) {
        return '${(value * 100).toInt()}%';
      } else {
        return value.toStringAsFixed(2);
      }
    } else if (value is bool) {
      return value ? 'Yes' : 'No';
    } else {
      return value.toString();
    }
  }
}
