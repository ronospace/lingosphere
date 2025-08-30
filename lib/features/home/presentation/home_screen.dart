// 🌐 LingoSphere - Home Screen
// Main translation interface with real-time group chat integration

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const TranslationTab(),
    const ChatsTab(),
    const InsightsTab(),
    const VoiceTab(),
    const SettingsTab(),
  ];
  
  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.translate_rounded),
      activeIcon: Icon(Icons.translate_rounded),
      label: 'Translate',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline_rounded),
      activeIcon: Icon(Icons.chat_bubble_rounded),
      label: 'Chats',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.insights_outlined),
      activeIcon: Icon(Icons.insights_rounded),
      label: 'Insights',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.mic_outlined),
      activeIcon: Icon(Icons.mic_rounded),
      label: 'Voice',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navigationItems,
        backgroundColor: AppTheme.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.gray500,
        selectedLabelStyle: const TextStyle(
          fontFamily: AppTheme.primaryFontFamily,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppTheme.primaryFontFamily,
          fontWeight: FontWeight.normal,
        ),
        elevation: 8,
      ),
    );
  }
}

// Translation Tab
class TranslationTab extends StatelessWidget {
  const TranslationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Text(
                  'LingoSphere',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: AppTheme.headingFontFamily,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Handle notifications
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick Translation Card
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.translate_rounded,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Translation',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.vibrantGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'AI Powered',
                            style: TextStyle(
                              color: AppTheme.vibrantGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Translation Input
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Enter text to translate...',
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        // Handle text change
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Language Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Show source language picker
                            },
                            icon: const Icon(Icons.language_rounded),
                            label: const Text('Auto-detect'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            // Swap languages
                          },
                          icon: const Icon(Icons.swap_horiz_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.gray100,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Show target language picker
                            },
                            icon: const Icon(Icons.language_rounded),
                            label: const Text('English'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Translate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Perform translation
                        },
                        icon: const Icon(Icons.translate_rounded),
                        label: const Text('Translate'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Translations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Translations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.accentTeal.withOpacity(0.1),
                              child: const Icon(
                                Icons.translate_rounded,
                                color: AppTheme.accentTeal,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              'Hello, how are you?',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text('Hola, ¿cómo estás?'),
                            trailing: Text(
                              'EN → ES',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.gray500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder tabs
class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: AppTheme.gray400,
          ),
          SizedBox(height: 16),
          Text(
            'Group Chats',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Connect your messaging apps to enable\nreal-time translation',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 64,
            color: AppTheme.gray400,
          ),
          SizedBox(height: 16),
          Text(
            'AI Insights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Get AI-powered analytics and\ntranslation insights',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceTab extends StatelessWidget {
  const VoiceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_outlined,
            size: 64,
            color: AppTheme.gray400,
          ),
          SizedBox(height: 16),
          Text(
            'Voice Translation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Speak and translate in real-time\nwith voice recognition',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_outlined,
            size: 64,
            color: AppTheme.gray400,
          ),
          SizedBox(height: 16),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Customize your translation\npreferences and settings',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
