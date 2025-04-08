import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart' show AppTheme;
import 'package:freeway_app/widgets/theme/app_theme.dart';

import '../../../models/quote_plan.dart';
import 'quote_callcenter.dart';

class QuotePlanCard extends StatefulWidget {
  final QuotePlan plan;
  final VoidCallback onRequestQuote;
  final bool isSelected;
  final bool isMonthly;

  const QuotePlanCard({
    required this.plan,
    required this.onRequestQuote,
    required this.isMonthly,
    super.key,
    this.isSelected = false,
  });

  @override
  State<QuotePlanCard> createState() => _QuotePlanCardState();
}

class _QuotePlanCardState extends State<QuotePlanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Hero(
              tag: 'plan_${widget.plan.title}',
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.plan.primaryColor
                        : AppTheme.getDetailsGreyColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.getBoxShadowColor(context),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildFeaturesList(),
                      const SizedBox(height: 16),
                      _buildRequestQuoteButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.plan.isPopular)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.getGreenColor(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getBoxShadowColor(context),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    context.translate('quotePlans.mostPopular'),
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 14,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/products/vehiclepng/4.0x/auto.png',
              width: 40,
              height: 40,
              color: widget.plan.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              context.translate('quotePlans.${widget.plan.title}'),
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.bold,
                color: widget.plan.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w600,
                  color: widget.plan.accentColor,
                ),
              ),
              Text(
                (widget.isMonthly
                        ? widget.plan.monthlyPrice
                        : widget.plan.annualPrice)
                    .toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w700,
                  color: widget.plan.accentColor,
                ),
              ),
              Text(
                widget.isMonthly
                    ? context.translate('quotePlans.monthlySuffix')
                    : context.translate('quotePlans.annualSuffix'),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w400,
                  color: widget.plan.accentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: widget.plan.features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: widget.plan.accentColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('quotePlans.features.${feature.title}'),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTitleTextColor(context),
                      ),
                    ),
                    if (feature.subtitle != null)
                      Text(
                        context.translate(
                          'quotePlans.features.${feature.subtitle}',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w400,
                          color: AppTheme.getSubtitleTextColor(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRequestQuoteButton() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuoteCallcenter(
              insuranceType: widget.plan.title,
            ),
          ),
        );
        widget.onRequestQuote();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.plan.primaryColor.withValues(alpha: 0.8)
              : widget.plan.primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.plan.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            context.translate('quotePlans.requestQuote'),
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 16,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
