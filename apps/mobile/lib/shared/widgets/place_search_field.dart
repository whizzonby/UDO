import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Type-ahead place search backed by Google Places Autocomplete (falls back
/// to a plain text field if the search API returns nothing — e.g. no API key
/// configured server-side).
///
/// Notifier-agnostic: callers pass their own [search]/[fetchDetails]
/// functions (typically a provider's notifier methods) rather than this
/// widget depending on a specific provider type.
///
/// [placeType] restricts results (e.g. `'lodging'` for hotel-only search);
/// leave null for unrestricted address/venue search. [onPlaceSelected], when
/// provided, fetches the place's full details (address/phone) after
/// selection so the caller can auto-fill other fields — pass null to skip
/// that extra lookup for fields that don't need it (e.g. a plain location
/// field where the suggestion text itself is the whole answer).
class PlaceSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Future<List<Map<String, dynamic>>>
      Function(String query, String sessionToken, {String? type}) search;
  final Future<Map<String, dynamic>?> Function(
      String placeId, String sessionToken)? fetchDetails;
  final String hint;
  final String? placeType;
  final IconData icon;
  final bool useFullDescriptionOnSelect;
  final void Function(Map<String, dynamic> place)? onPlaceSelected;
  const PlaceSearchField({
    super.key,
    required this.controller,
    required this.search,
    this.fetchDetails,
    required this.hint,
    this.placeType,
    this.icon = Icons.place_outlined,
    this.useFullDescriptionOnSelect = false,
    this.onPlaceSelected,
  });

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  Timer? _debounce;
  bool _loadingDetails = false;
  // Groups an autocomplete search with the eventual details lookup into one
  // billing "session" on Google's side; rotated after each selection so the
  // next search starts a fresh session.
  String _sessionToken = UniqueKey().toString();

  Future<List<Map<String, dynamic>>> _search(String query) {
    if (query.trim().length < 2) return Future.value(const []);
    final completer = Completer<List<Map<String, dynamic>>>();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await widget.search(query.trim(), _sessionToken,
          type: widget.placeType);
      if (!completer.isCompleted) completer.complete(results);
    });
    return completer.future;
  }

  Future<void> _onSelected(Map<String, dynamic> place) async {
    widget.controller.text = widget.useFullDescriptionOnSelect
        ? (place['description']?.toString() ?? place['name']?.toString() ?? '')
        : (place['name']?.toString() ?? '');

    final onPlaceSelected = widget.onPlaceSelected;
    final fetchDetails = widget.fetchDetails;
    final placeId = place['place_id'] as String?;
    if (onPlaceSelected == null || fetchDetails == null || placeId == null) {
      setState(() => _sessionToken = UniqueKey().toString());
      return;
    }

    setState(() => _loadingDetails = true);
    final details = await fetchDetails(placeId, _sessionToken);
    if (!mounted) return;
    setState(() {
      _loadingDetails = false;
      _sessionToken = UniqueKey().toString();
    });
    if (details != null) onPlaceSelected(details);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      textEditingController: widget.controller,
      optionsBuilder: (value) => _search(value.text),
      displayStringForOption: (option) => option['name']?.toString() ?? '',
      onSelected: (option) => _onSelected(option),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle:
                const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
            filled: true,
            fillColor: AppTheme.udoCardFill,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: _loadingDetails
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : null,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return ListTile(
                  dense: true,
                  leading: Icon(widget.icon, size: 18),
                  title: Text(option['name']?.toString() ?? ''),
                  subtitle: (option['address'] as String?)?.isNotEmpty == true
                      ? Text(option['address'].toString(),
                          maxLines: 1, overflow: TextOverflow.ellipsis)
                      : null,
                  onTap: () => onSelected(option),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
