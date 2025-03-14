import 'package:flutter/material.dart';

class TabData {
  final IconData icon;
  final String title;

  TabData(this.icon, this.title);
}

class CircleNavBar extends StatefulWidget {
  final List<TabData> tabItems;
  final int selectedPos;
  final Function(int) onTap;

  const CircleNavBar({
    required this.tabItems, required this.selectedPos, required this.onTap, super.key,
  });

  @override
  State<CircleNavBar> createState() => _CircleNavBarState();
}

class _CircleNavBarState extends State<CircleNavBar>
    with SingleTickerProviderStateMixin {
  int _previousIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 410,
      height: 65,
      margin: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F111111),
            offset: Offset(0, 4),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          widget.tabItems.length,
          (index) => _buildNavItem(index),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = index == widget.selectedPos;
    if (isSelected) {
      if (_previousIndex != index) {
        _controller.reset();
        _controller.forward();
        _previousIndex = index;
      }
    }

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              child: Center(
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, -12 * value),
                      child: Transform.rotate(
                        angle: 6.28319 * value,
                        child: Transform.scale(
                          scale: 1 + (0.2 * value),
                          child: child!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: isSelected ? 33 : 24,
                    height: isSelected ? 33 : 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0A4DA2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0A4DA2).withAlpha(51),
                                blurRadius: 8,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: const Color(0xFFF5FCFF).withAlpha(153),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.tabItems[index].icon,
                      size: isSelected ? 28 : 24,
                      color: isSelected ? Colors.white : const Color(0xFF0A4DA2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.tabItems[index].title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFF26522) // Color naranja para opción seleccionada
                    : const Color(0xFF0A4DA2),
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
