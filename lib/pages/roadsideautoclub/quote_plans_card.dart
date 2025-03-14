import 'package:flutter/material.dart';
import '../../../models/quote_plan.dart';
import 'quote_callcenter.dart';

class QuotePlanCard extends StatefulWidget {
  final QuotePlan plan;
  final VoidCallback onRequestQuote;
  final bool isSelected;
  final bool isMonthly;

  const QuotePlanCard({
    required this.plan, required this.onRequestQuote, required this.isMonthly, super.key,
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
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ),);

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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.plan.primaryColor
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
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
                    color: const Color(0xFF76B947),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Most Popular',
                    style: TextStyle(
                      color: Colors.white,
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
              widget.plan.title,
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
                widget.isMonthly ? '/mo*' : '/yr*',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w500,
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.plan.features.length,
      itemBuilder: (context, index) {
        final feature = widget.plan.features[index];
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index * 0.1,
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                        feature.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (feature.subtitle != null)
                        Text(
                          feature.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Open Sans',
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestQuoteButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
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
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 210,
        height: 48,
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.plan.primaryColor.withAlpha(204)
              : widget.plan.primaryColor, // 0.8 * 255 ≈ 204
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            'Request a Quote',
            style: TextStyle(
              color: Colors.white,
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
