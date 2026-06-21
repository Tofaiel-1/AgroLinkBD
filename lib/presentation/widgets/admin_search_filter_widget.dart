import 'package:flutter/material.dart';

class AdminSearchFilterWidget extends StatefulWidget {
  final Function(String searchQuery) onSearch;
  final Function(String? filterValue)? onFilterChanged;
  final String searchHint;
  final List<String>? filterOptions;
  final String? filterLabel;
  final IconData searchIcon;

  const AdminSearchFilterWidget({
    super.key,
    required this.onSearch,
    this.onFilterChanged,
    this.searchHint = 'Search...',
    this.filterOptions,
    this.filterLabel,
    this.searchIcon = Icons.search,
  });

  @override
  State<AdminSearchFilterWidget> createState() =>
      _AdminSearchFilterWidgetState();
}

class _AdminSearchFilterWidgetState extends State<AdminSearchFilterWidget> {
  late TextEditingController _searchController;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.searchHint,
            prefixIcon: Icon(widget.searchIcon),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearch('');
                      setState(() {});
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            widget.onSearch(value);
            setState(() {});
          },
        ),
        const SizedBox(height: 12),

        // Filter dropdown (optional)
        if (widget.filterOptions != null && widget.filterOptions!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String?>(
              decoration: InputDecoration(
                labelText: widget.filterLabel ?? 'Filter',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.filter_list),
              ),
              initialValue: _selectedFilter,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(widget.filterLabel ?? 'All'),
                ),
                ...widget.filterOptions!.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedFilter = value);
                widget.onFilterChanged?.call(value);
              },
            ),
          ),
      ],
    );
  }
}
