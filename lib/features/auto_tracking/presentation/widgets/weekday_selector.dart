import 'package:flutter/material.dart';

class WeekdaySelector extends StatelessWidget {
  final Set<int> selectedWeekdays;
  final Function(Set<int>) onWeekdaysChanged;

  static const Map<int, String> _weekdayNames = {
    DateTime.monday: 'Mo',
    DateTime.tuesday: 'Di',
    DateTime.wednesday: 'Mi',
    DateTime.thursday: 'Do',
    DateTime.friday: 'Fr',
    DateTime.saturday: 'Sa',
    DateTime.sunday: 'So',
  };

  const WeekdaySelector({
    super.key,
    required this.selectedWeekdays,
    required this.onWeekdaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wochentage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weekdayNames.entries.map((entry) {
                final weekday = entry.key;
                final name = entry.value;
                final isSelected = selectedWeekdays.contains(weekday);

                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = Set<int>.from(selectedWeekdays);
                    if (selected) {
                      updated.add(weekday);
                    } else {
                      updated.remove(weekday);
                    }
                    onWeekdaysChanged(updated);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
