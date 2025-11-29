import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  const FilterBottomSheet({super.key, required this.onApply});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 50000000);
  double _minRating = 0;
  String _sortBy = 'popular';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Bộ lọc', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(onPressed: () => setState(() { _priceRange = const RangeValues(0, 50000000); _minRating = 0; _sortBy = 'popular'; }), child: const Text('Đặt lại')),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Khoảng giá', style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: _priceRange,
            min: 0, max: 50000000,
            divisions: 100,
            labels: RangeLabels('${(_priceRange.start / 1000000).toStringAsFixed(1)}tr', '${(_priceRange.end / 1000000).toStringAsFixed(1)}tr'),
            onChanged: (v) => setState(() => _priceRange = v),
            activeColor: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text('Đánh giá tối thiểu', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _minRating = i + 1.0),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.star, size: 32, color: i < _minRating ? Colors.amber : Colors.grey[300]),
              ),
            )),
          ),
          const SizedBox(height: 16),
          const Text('Sắp xếp theo', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip('popular', 'Phổ biến'),
              _buildSortChip('newest', 'Mới nhất'),
              _buildSortChip('price_low', 'Giá thấp'),
              _buildSortChip('price_high', 'Giá cao'),
              _buildSortChip('rating', 'Đánh giá'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply({'priceRange': _priceRange, 'minRating': _minRating, 'sortBy': _sortBy});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Áp dụng'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _sortBy = value),
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}

void showFilterBottomSheet(BuildContext context, Function(Map<String, dynamic>) onApply) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => FilterBottomSheet(onApply: onApply),
  );
}
