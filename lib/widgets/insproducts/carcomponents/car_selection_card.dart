import 'package:flutter/material.dart';
import 'package:freeway_app/models/car_info.dart';

class CarSelectionCard extends StatelessWidget {
  final CarInfo car;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const CarSelectionCard({
    required this.car, required this.isSelected, required this.onSelect, required this.onEdit, required this.onRemove, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF0046B9) : Colors.black,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car information
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.year,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w700,
                    color: isSelected ? const Color(0xFF0046B9) : Colors.black,
                  ),
                ),
                Text(
                  '${car.make}-${car.model}',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w700,
                    color: isSelected ? const Color(0xFF0046B9) : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'VIN ${car.vin}',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0046B9) : Colors.black,
                    fontSize: 14,
                    fontFamily: 'Open Sans',
                  ),
                ),
              ],
            ),
          ),
          // Edit and Remove actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color:
                          isSelected ? const Color(0xFF0046B9) : Colors.black,
                    ),
                    const SizedBox(width: 2),
                    TextButton(
                      onPressed: isSelected ? onEdit : null,
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF0046B9)
                              : Colors.black,
                          fontSize: 14,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color:
                          isSelected ? const Color(0xFF0046B9) : Colors.black,
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: isSelected ? onRemove : null,
                      child: Text(
                        'Remove',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF0046B9)
                              : Colors.black,
                          fontSize: 14,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
          ),
          // Select radio button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onSelect,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected ? const Color(0xFF0046B9) : Colors.black,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0046B9),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Select',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0046B9) : Colors.black,
                    fontSize: 14,
                    fontFamily: 'Open Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
