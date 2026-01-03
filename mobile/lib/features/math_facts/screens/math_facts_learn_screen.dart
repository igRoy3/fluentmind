// Math Facts Learning Screen - Interactive reference for Tables, Squares, and Cubes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/math_facts_data.dart';

class MathFactsLearnScreen extends StatefulWidget {
  final String factType; // 'tables', 'squares', or 'cubes'

  const MathFactsLearnScreen({super.key, required this.factType});

  @override
  State<MathFactsLearnScreen> createState() => _MathFactsLearnScreenState();
}

class _MathFactsLearnScreenState extends State<MathFactsLearnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTableIndex = 0; // For tables: 0 = table of 11, 9 = table of 20

  @override
  void initState() {
    super.initState();
    // Only tables need tabs (11-20)
    if (widget.factType == 'tables') {
      _tabController = TabController(length: 10, vsync: this);
      _tabController.addListener(() {
        setState(() {
          _selectedTableIndex = _tabController.index;
        });
      });
    } else {
      _tabController = TabController(length: 1, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.factType) {
      case 'tables':
        return 'Tables 11-20';
      case 'squares':
        return 'Squares 1²-25²';
      case 'cubes':
        return 'Cubes 1³-15³';
      default:
        return 'Math Facts';
    }
  }

  Color get _primaryColor {
    switch (widget.factType) {
      case 'tables':
        return const Color(0xFF6C5CE7);
      case 'squares':
        return const Color(0xFF00B894);
      case 'cubes':
        return const Color(0xFFE17055);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: widget.factType == 'tables'
                ? (isSmallScreen ? 160 : 180)
                : (isSmallScreen ? 120 : 140),
            floating: false,
            pinned: true,
            backgroundColor: _primaryColor,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.white,
                ),
                onPressed: () => _showTips(context, isDark, isSmallScreen),
                tooltip: 'Tips',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryColor, _primaryColor.withOpacity(0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSubtitle(),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 15,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        if (widget.factType == 'tables') ...[
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          // Table selector
                          SizedBox(
                            height: isSmallScreen ? 36 : 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                final tableNum = index + 11;
                                final isSelected = _selectedTableIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _tabController.animateTo(index);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 14 : 18,
                                      vertical: isSmallScreen ? 6 : 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$tableNum',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? _primaryColor
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: widget.factType == 'tables'
            ? TabBarView(
                controller: _tabController,
                children: List.generate(10, (index) {
                  final tableNum = index + 11;
                  return _TableView(
                    tableNumber: tableNum,
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                    primaryColor: _primaryColor,
                  );
                }),
              )
            : widget.factType == 'squares'
            ? _SquaresView(
                isDark: isDark,
                isSmallScreen: isSmallScreen,
                primaryColor: _primaryColor,
              )
            : _CubesView(
                isDark: isDark,
                isSmallScreen: isSmallScreen,
                primaryColor: _primaryColor,
              ),
      ),
    );
  }

  String _getSubtitle() {
    switch (widget.factType) {
      case 'tables':
        return 'Tap a number to view its table';
      case 'squares':
        return 'n × n = n² (Perfect squares)';
      case 'cubes':
        return 'n × n × n = n³ (Perfect cubes)';
      default:
        return '';
    }
  }

  void _showTips(BuildContext context, bool isDark, bool isSmallScreen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lightbulb_rounded, color: AppColors.accentYellow),
            const SizedBox(width: 8),
            Text(
              'Learning Tips',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TipItem(
              icon: Icons.repeat_rounded,
              text: 'Review facts multiple times a day',
              isDark: isDark,
              isSmallScreen: isSmallScreen,
            ),
            _TipItem(
              icon: Icons.edit_note_rounded,
              text: 'Write them down to memorize faster',
              isDark: isDark,
              isSmallScreen: isSmallScreen,
            ),
            _TipItem(
              icon: Icons.pattern_rounded,
              text: 'Look for patterns in the numbers',
              isDark: isDark,
              isSmallScreen: isSmallScreen,
            ),
            _TipItem(
              icon: Icons.games_rounded,
              text: 'Test yourself with practice mode',
              isDark: isDark,
              isSmallScreen: isSmallScreen,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

// Tip Item Widget
class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final bool isSmallScreen;

  const _TipItem({
    required this.icon,
    required this.text,
    required this.isDark,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: isSmallScreen ? 18 : 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Table View (for multiplication tables)
class _TableView extends StatelessWidget {
  final int tableNumber;
  final bool isDark;
  final bool isSmallScreen;
  final Color primaryColor;

  const _TableView({
    required this.tableNumber,
    required this.isDark,
    required this.isSmallScreen,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final facts = MathFactsGenerator.getTableFor(tableNumber);

    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      itemCount: facts.length,
      itemBuilder: (context, index) {
        final fact = facts[index];
        return _FactCard(
              expression: '$tableNumber × ${fact.multiplier}',
              result: '${fact.result}',
              index: index,
              isDark: isDark,
              isSmallScreen: isSmallScreen,
              primaryColor: primaryColor,
            )
            .animate(delay: Duration(milliseconds: index * 50))
            .fadeIn()
            .slideX(begin: 0.1);
      },
    );
  }
}

// Squares View
class _SquaresView extends StatelessWidget {
  final bool isDark;
  final bool isSmallScreen;
  final Color primaryColor;

  const _SquaresView({
    required this.isDark,
    required this.isSmallScreen,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final facts = MathFactsGenerator.getAllSquares();
    final crossAxisCount = isSmallScreen ? 3 : 4;

    return GridView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8 : 10,
        mainAxisSpacing: isSmallScreen ? 8 : 10,
        childAspectRatio: 1.0,
      ),
      itemCount: facts.length,
      itemBuilder: (context, index) {
        final fact = facts[index];
        return _SquareCubeCard(
              number: fact.baseNumber,
              result: fact.result,
              isSquare: true,
              isDark: isDark,
              isSmallScreen: isSmallScreen,
              primaryColor: primaryColor,
            )
            .animate(delay: Duration(milliseconds: index * 30))
            .fadeIn()
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

// Cubes View
class _CubesView extends StatelessWidget {
  final bool isDark;
  final bool isSmallScreen;
  final Color primaryColor;

  const _CubesView({
    required this.isDark,
    required this.isSmallScreen,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final facts = MathFactsGenerator.getAllCubes();
    final crossAxisCount = isSmallScreen ? 3 : 4;

    return GridView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8 : 10,
        mainAxisSpacing: isSmallScreen ? 8 : 10,
        childAspectRatio: isSmallScreen ? 0.85 : 0.9,
      ),
      itemCount: facts.length,
      itemBuilder: (context, index) {
        final fact = facts[index];
        return _SquareCubeCard(
              number: fact.baseNumber,
              result: fact.result,
              isSquare: false,
              isDark: isDark,
              isSmallScreen: isSmallScreen,
              primaryColor: primaryColor,
            )
            .animate(delay: Duration(milliseconds: index * 40))
            .fadeIn()
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

// Fact Card (for tables)
class _FactCard extends StatelessWidget {
  final String expression;
  final String result;
  final int index;
  final bool isDark;
  final bool isSmallScreen;
  final Color primaryColor;

  const _FactCard({
    required this.expression,
    required this.result,
    required this.index,
    required this.isDark,
    required this.isSmallScreen,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 10),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Index badge
          Container(
            width: isSmallScreen ? 28 : 32,
            height: isSmallScreen ? 28 : 32,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 14 : 18),
          // Expression
          Expanded(
            child: Text(
              expression,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          // Equals sign
          Text(
            '=',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.w300,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(width: isSmallScreen ? 14 : 18),
          // Result
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 14 : 18,
              vertical: isSmallScreen ? 8 : 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              result,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Square/Cube Card (grid view)
class _SquareCubeCard extends StatefulWidget {
  final int number;
  final int result;
  final bool isSquare;
  final bool isDark;
  final bool isSmallScreen;
  final Color primaryColor;

  const _SquareCubeCard({
    required this.number,
    required this.result,
    required this.isSquare,
    required this.isDark,
    required this.isSmallScreen,
    required this.primaryColor,
  });

  @override
  State<_SquareCubeCard> createState() => _SquareCubeCardState();
}

class _SquareCubeCardState extends State<_SquareCubeCard> {
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _showResult = !_showResult;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: _showResult
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.primaryColor,
                    widget.primaryColor.withOpacity(0.7),
                  ],
                )
              : null,
          color: _showResult
              ? null
              : (widget.isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withOpacity(_showResult ? 0.3 : 0.1),
              blurRadius: _showResult ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Number with exponent
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${widget.number}',
                    style: TextStyle(
                      fontSize: widget.isSmallScreen ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: _showResult
                          ? Colors.white
                          : (widget.isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                    ),
                  ),
                  WidgetSpan(
                    child: Transform.translate(
                      offset: const Offset(1, -8),
                      child: Text(
                        widget.isSquare ? '²' : '³',
                        style: TextStyle(
                          fontSize: widget.isSmallScreen ? 14 : 18,
                          fontWeight: FontWeight.bold,
                          color: _showResult
                              ? Colors.white.withOpacity(0.9)
                              : widget.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: widget.isSmallScreen ? 6 : 8),
            // Result or hint
            AnimatedCrossFade(
              firstChild: Text(
                'Tap to see',
                style: TextStyle(
                  fontSize: widget.isSmallScreen ? 10 : 12,
                  color: widget.isDark
                      ? AppColors.textHintDark
                      : AppColors.textHint,
                ),
              ),
              secondChild: Column(
                children: [
                  Text(
                    '= ${widget.result}',
                    style: TextStyle(
                      fontSize: widget.isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (!widget.isSquare && !widget.isSmallScreen) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${widget.number}×${widget.number}×${widget.number}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
              crossFadeState: _showResult
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
