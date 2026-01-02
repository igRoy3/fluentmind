import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/audio_service.dart';
// Sound service removed - not currently used
import '../../practice/widgets/dynamic_waveform.dart';

// Conversation scenarios data
class ConversationScenario {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<ConversationTurn> turns;
  final int xpReward;
  final String difficulty;

  const ConversationScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.turns,
    required this.xpReward,
    required this.difficulty,
  });
}

class ConversationTurn {
  final String speaker; // 'ai' or 'user'
  final String text;
  final List<String> suggestedResponses;
  final String? aiResponse;

  const ConversationTurn({
    required this.speaker,
    required this.text,
    this.suggestedResponses = const [],
    this.aiResponse,
  });
}

// Predefined scenarios
final _scenarios = [
  ConversationScenario(
    id: 'cafe_order',
    title: 'Coffee Shop',
    description: 'Order your favorite drink at a café',
    icon: Icons.coffee_rounded,
    color: const Color(0xFF8B4513),
    xpReward: 50,
    difficulty: 'Beginner',
    turns: [
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Hi! Welcome to Java Dreams. What can I get started for you today?',
        suggestedResponses: [
          'I\'d like a large latte, please.',
          'Can I get a cappuccino?',
          'What do you recommend?',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text: 'Great choice! Would you like that hot or iced?',
        suggestedResponses: [
          'Hot, please.',
          'I\'ll have it iced.',
          'What\'s the difference in price?',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Perfect! Any milk preference? We have oat, almond, soy, or regular dairy.',
        suggestedResponses: [
          'Oat milk would be great.',
          'Just regular milk is fine.',
          'Which one do you recommend?',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text: 'Sounds good! Can I get a name for the order?',
        suggestedResponses: [
          'It\'s [Your Name].',
          'You can put it under [Name].',
          'Just call it when it\'s ready, please.',
        ],
      ),
    ],
  ),
  ConversationScenario(
    id: 'hotel_checkin',
    title: 'Hotel Check-in',
    description: 'Check into a hotel for your stay',
    icon: Icons.hotel_rounded,
    color: const Color(0xFF2E86AB),
    xpReward: 75,
    difficulty: 'Intermediate',
    turns: [
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Good afternoon! Welcome to Grand Plaza Hotel. Do you have a reservation with us?',
        suggestedResponses: [
          'Yes, I have a reservation under [Name].',
          'I\'d like to book a room for tonight.',
          'I booked online. Here\'s my confirmation number.',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'I found your reservation. May I see your ID and a credit card for incidentals?',
        suggestedResponses: [
          'Sure, here you go.',
          'Of course, here\'s my passport and card.',
          'Can I use a different card for incidentals?',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Thank you! Would you prefer a room on a higher floor with a city view, or a quieter room on a lower floor?',
        suggestedResponses: [
          'A higher floor with a city view would be lovely.',
          'I\'d prefer a quieter room, please.',
          'Which floor has the best view?',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Your room is 1205. Breakfast is served from 7 to 10 AM. Is there anything else I can help you with?',
        suggestedResponses: [
          'What time does the gym open?',
          'Is there a restaurant in the hotel?',
          'That\'s all, thank you!',
        ],
      ),
    ],
  ),
  ConversationScenario(
    id: 'job_interview',
    title: 'Job Interview',
    description: 'Practice answering common interview questions',
    icon: Icons.business_center_rounded,
    color: const Color(0xFF6C5CE7),
    xpReward: 100,
    difficulty: 'Advanced',
    turns: [
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Thanks for coming in today. Tell me a little bit about yourself and your background.',
        suggestedResponses: [
          'I have 3 years of experience in...',
          'I recently graduated with a degree in...',
          'I\'ve been working in the industry for...',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Interesting! What attracted you to this particular role at our company?',
        suggestedResponses: [
          'I admire your company\'s mission to...',
          'The role aligns perfectly with my skills in...',
          'I\'ve been following your company\'s work on...',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Can you tell me about a challenging situation at work and how you handled it?',
        suggestedResponses: [
          'There was a time when I had to meet a tight deadline...',
          'I once had to resolve a conflict between team members...',
          'We faced a major technical issue that required...',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text: 'Where do you see yourself in five years?',
        suggestedResponses: [
          'I hope to grow into a leadership position...',
          'I want to become an expert in...',
          'I see myself contributing to major projects...',
        ],
      ),
    ],
  ),
  ConversationScenario(
    id: 'doctor_visit',
    title: 'Doctor\'s Office',
    description: 'Describe symptoms and ask medical questions',
    icon: Icons.local_hospital_rounded,
    color: const Color(0xFFE17055),
    xpReward: 80,
    difficulty: 'Intermediate',
    turns: [
      const ConversationTurn(
        speaker: 'ai',
        text: 'Hello, I\'m Dr. Smith. What brings you in today?',
        suggestedResponses: [
          'I\'ve been having headaches for a few days.',
          'I\'ve had a cough and sore throat since...',
          'I\'m here for a routine checkup.',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'I see. How long has this been going on, and have you noticed any other symptoms?',
        suggestedResponses: [
          'It started about a week ago, and I also feel...',
          'Just a few days, and I\'ve also noticed...',
          'It comes and goes, but recently it\'s been...',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Are you currently taking any medications or do you have any allergies I should know about?',
        suggestedResponses: [
          'I take medication for...',
          'I\'m allergic to...',
          'No medications or allergies.',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'I\'d like to prescribe something for you. Do you have any questions about the treatment?',
        suggestedResponses: [
          'How often should I take this?',
          'Are there any side effects I should watch for?',
          'How long until I should feel better?',
        ],
      ),
    ],
  ),
  ConversationScenario(
    id: 'restaurant',
    title: 'Restaurant Dining',
    description: 'Order food and interact with the waiter',
    icon: Icons.restaurant_rounded,
    color: const Color(0xFFD63031),
    xpReward: 60,
    difficulty: 'Beginner',
    turns: [
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Good evening! Welcome to La Bella Italia. Can I start you off with something to drink?',
        suggestedResponses: [
          'I\'ll have a glass of water, please.',
          'Can I see the wine list?',
          'What soft drinks do you have?',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Here are your drinks. Are you ready to order, or do you need a few more minutes?',
        suggestedResponses: [
          'I\'d like to order the...',
          'What do you recommend?',
          'Can I have a few more minutes, please?',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Excellent choice! Would you like any appetizers or sides with that?',
        suggestedResponses: [
          'I\'ll also have the...',
          'What appetizers do you recommend?',
          'No, just the main course is fine.',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text: 'How is everything tasting? Can I get you anything else?',
        suggestedResponses: [
          'Everything is delicious, thank you!',
          'Could I have some more bread, please?',
          'Can I see the dessert menu?',
        ],
      ),
    ],
  ),
  ConversationScenario(
    id: 'travel_agency',
    title: 'Travel Planning',
    description: 'Book a vacation with a travel agent',
    icon: Icons.flight_rounded,
    color: const Color(0xFF00B894),
    xpReward: 90,
    difficulty: 'Advanced',
    turns: [
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Hello! I\'m here to help you plan your perfect vacation. What destination are you thinking about?',
        suggestedResponses: [
          'I\'m interested in visiting Europe.',
          'I\'d like to go somewhere tropical.',
          'What destinations would you recommend for...',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Great choice! When are you planning to travel, and for how long?',
        suggestedResponses: [
          'I\'m thinking sometime in [month].',
          'I have a two-week vacation coming up.',
          'What\'s the best time of year to visit?',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'What kind of experience are you looking for? Adventure, relaxation, cultural immersion?',
        suggestedResponses: [
          'I\'d like a mix of adventure and relaxation.',
          'I\'m mainly interested in cultural experiences.',
          'What activities are popular there?',
        ],
      ),
      const ConversationTurn(
        speaker: 'ai',
        text:
            'Based on your preferences, I can put together a package. What\'s your approximate budget?',
        suggestedResponses: [
          'I\'m looking to spend around...',
          'What options do you have for...',
          'Can you show me a few different price ranges?',
        ],
      ),
    ],
  ),
];

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen>
    with SingleTickerProviderStateMixin {
  ConversationScenario? _selectedScenario;
  int _currentTurnIndex = 0;
  List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _showSuggestions = true;
  final AudioService _audioService = AudioService();
  Timer? _timer;
  int _recordingSeconds = 0;
  int _earnedXp = 0;
  int _turnsCompleted = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _checkPermissions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    await _audioService.requestPermission();
  }

  void _selectScenario(ConversationScenario scenario) {
    setState(() {
      _selectedScenario = scenario;
      _currentTurnIndex = 0;
      _messages = [];
      _earnedXp = 0;
      _turnsCompleted = 0;
    });

    // Add first AI message with typing animation delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              speaker: 'ai',
              text: scenario.turns[0].text,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  void _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
        _showSuggestions = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() => _recordingSeconds++);
          if (_recordingSeconds >= 30) _stopRecording();
        }
      });
    } catch (e) {
      _showSnackBar('Failed to start recording: $e');
    }
  }

  void _stopRecording() async {
    _timer?.cancel();

    try {
      await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      // Simulate processing and add user response
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        // Add user message (simulated transcription)
        final currentTurn = _selectedScenario!.turns[_currentTurnIndex];
        final userResponse = currentTurn.suggestedResponses.isNotEmpty
            ? currentTurn.suggestedResponses[Random().nextInt(
                currentTurn.suggestedResponses.length,
              )]
            : 'Great response!';

        setState(() {
          _messages.add(
            ChatMessage(
              speaker: 'user',
              text: userResponse,
              timestamp: DateTime.now(),
            ),
          );
          _turnsCompleted++;
          _earnedXp += 10;
        });

        // Move to next turn or complete
        await Future.delayed(const Duration(milliseconds: 800));
        _advanceConversation();
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
      _showSnackBar('Error: $e');
    }
  }

  void _selectSuggestion(String suggestion) async {
    setState(() {
      _messages.add(
        ChatMessage(
          speaker: 'user',
          text: suggestion,
          timestamp: DateTime.now(),
        ),
      );
      _turnsCompleted++;
      _earnedXp += 10;
      _showSuggestions = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    _advanceConversation();
  }

  void _advanceConversation() {
    if (_currentTurnIndex < _selectedScenario!.turns.length - 1) {
      setState(() {
        _currentTurnIndex++;
        _showSuggestions = true;
      });

      // Add next AI message with delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _messages.add(
              ChatMessage(
                speaker: 'ai',
                text: _selectedScenario!.turns[_currentTurnIndex].text,
                timestamp: DateTime.now(),
              ),
            );
          });
        }
      });
    } else {
      // Conversation complete
      _showCompletionDialog();
    }

    setState(() => _isProcessing = false);
  }

  void _showCompletionDialog() {
    final xpBonus = _selectedScenario!.xpReward;
    final totalXp = _earnedXp + xpBonus;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: AppColors.success,
                  size: 40,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text(
                'Conversation Complete! 🎉',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedScenario!.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    value: '$_turnsCompleted',
                    label: 'Turns',
                  ),
                  _buildStatCard(
                    icon: Icons.star_rounded,
                    value: '+$totalXp',
                    label: 'XP Earned',
                    highlight: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedScenario = null;
                          _messages = [];
                        });
                      },
                      child: const Text('New Scenario'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.pop();
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.accentYellow.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: highlight ? AppColors.accentYellow : AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.accentYellow : AppColors.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _selectedScenario?.title ?? 'Conversation Practice',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedScenario != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.accentYellow,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+$_earnedXp XP',
                    style: const TextStyle(
                      color: AppColors.accentYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _selectedScenario == null
            ? _buildScenarioSelection(isDark)
            : _buildConversationView(isDark),
      ),
    );
  }

  Widget _buildScenarioSelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a Scenario 🎭',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Practice real-world conversations with AI',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _scenarios.length,
            itemBuilder: (context, index) {
              final scenario = _scenarios[index];
              return _ScenarioCard(
                    scenario: scenario,
                    onTap: () => _selectScenario(scenario),
                  )
                  .animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConversationView(bool isDark) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (_currentTurnIndex + 1) / _selectedScenario!.turns.length,
          backgroundColor: isDark ? AppColors.dividerDark : AppColors.divider,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        ),

        // Chat messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isProcessing ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isProcessing) {
                return _TypingIndicator().animate().fadeIn();
              }
              final message = _messages[index];
              return _ChatBubble(
                message: message,
                isDark: isDark,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
            },
          ),
        ),

        // Suggestions & Input
        _buildInputArea(isDark),
      ],
    );
  }

  Widget _buildInputArea(bool isDark) {
    final currentTurn = _selectedScenario!.turns[_currentTurnIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestions
          if (_showSuggestions &&
              currentTurn.suggestedResponses.isNotEmpty &&
              !_isRecording)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: AppColors.accentYellow,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Suggested Responses',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentTurn.suggestedResponses.map((suggestion) {
                    return GestureDetector(
                      onTap: () => _selectSuggestion(suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          suggestion,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Or speak your own response:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Recording area
          if (_isRecording)
            Column(
              children: [
                DynamicWaveformVisualizer(
                  amplitudeStream: _audioService.amplitudeStream,
                  isRecording: true,
                ),
                const SizedBox(height: 12),
                Text(
                  '${_recordingSeconds}s',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Record button
          GestureDetector(
            onTap: _isProcessing
                ? null
                : (_isRecording ? _stopRecording : _startRecording),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? Colors.red
                        : (_isProcessing ? Colors.grey : AppColors.primary),
                    boxShadow: _isRecording
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(
                                0.3 + 0.2 * _pulseController.value,
                              ),
                              blurRadius: 20 + 10 * _pulseController.value,
                              spreadRadius: 5 * _pulseController.value,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _isRecording
                        ? Icons.stop_rounded
                        : (_isProcessing
                              ? Icons.hourglass_empty_rounded
                              : Icons.mic_rounded),
                    color: Colors.white,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isRecording
                ? 'Tap to stop'
                : (_isProcessing ? 'Processing...' : 'Tap to speak'),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final ConversationScenario scenario;
  final VoidCallback onTap;

  const _ScenarioCard({required this.scenario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scenario.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(scenario.icon, color: scenario.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        scenario.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(
                            scenario.difficulty,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          scenario.difficulty,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getDifficultyColor(scenario.difficulty),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scenario.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.accentYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${scenario.xpReward} XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentYellow,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${scenario.turns.length} turns',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return AppColors.success;
      case 'Intermediate':
        return AppColors.accentYellow;
      case 'Advanced':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }
}

class ChatMessage {
  final String speaker;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.speaker,
    required this.text,
    required this.timestamp,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const _ChatBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.speaker == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.success,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(delay: 0),
              const SizedBox(width: 4),
              _Dot(delay: 200),
              const SizedBox(width: 4),
              _Dot(delay: 400),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final int delay;

  const _Dot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fadeIn(delay: Duration(milliseconds: delay))
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 400.ms,
        );
  }
}
