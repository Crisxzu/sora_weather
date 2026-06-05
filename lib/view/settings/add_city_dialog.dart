import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/common/fuzzy_search.dart';
import 'package:weather_app/data/geo_repository.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/model/geo/geo_city.dart';
import 'package:weather_app/model/geo/geo_country.dart';
import 'package:weather_app/model/geo/geo_state.dart';
import 'package:weather_app/providers/location.dart';
import 'package:weather_app/providers/params.dart';

class AddCityDialog extends StatefulWidget {
  const AddCityDialog({super.key});

  @override
  State<AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<AddCityDialog> {
  List<GeoCountry> _countries = [];
  GeoCountry? _selectedCountry;
  GeoState? _selectedState;
  GeoCity? _selectedCity;
  GeoState? _selectedCityState;

  late final String _locale;

  @override
  void initState() {
    super.initState();
    _locale = Provider.of<ParamsProvider>(context, listen: false).locale?.languageCode ?? 'en';
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final countries = await GeoRepository.instance.countries();
    if (mounted) setState(() => _countries = countries);
  }

  void _onCityChanged(GeoCity? val) async {
    if (val == null) {
      setState(() {
        _selectedCity = null;
        _selectedCityState = null;
      });
      return;
    }
    GeoState? cityState = _selectedState;
    if (cityState == null && _selectedCountry != null) {
      final states = await GeoRepository.instance.statesOf(_selectedCountry!.iso2);
      cityState = states.where((s) => s.id == val.stateId).firstOrNull;
    }
    setState(() {
      _selectedCity = val;
      _selectedCityState = cityState;
    });
  }

  void _submit() {
    if (_selectedCity == null) return;
    Provider.of<LocationProvider>(context, listen: false).addCity(
      cityName: _selectedCity!.name,
      countryName: _selectedCountry?.name ?? '',
      stateName: _selectedCityState?.name,
      countryEmoji: _selectedCountry?.emoji,
      countryIso2: _selectedCountry?.iso2,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.addCity, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Country
              DropdownSearch<GeoCountry>(
                compareFn: (a, b) => a.iso2 == b.iso2,
                filterFn: (_, __) => true,
                items: (filter, _) {
                  if (filter.isEmpty) return _countries;
                  final q = FuzzySearch.normalize(filter);
                  return _countries
                      .where((c) =>
                          FuzzySearch.matchesNormalized(c.normalizedName, q) ||
                          FuzzySearch.matchesNormalized(FuzzySearch.normalize(c.localizedName(_locale)), q))
                      .toList();
                },
                itemAsString: (c) => '${c.emoji}  ${c.localizedName(_locale)}',
                selectedItem: _selectedCountry,
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(labelText: l10n.country),
                ),
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  searchDelay: Duration(milliseconds: 200),
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                  ),
                ),
                onChanged: (val) => setState(() {
                  _selectedCountry = val;
                  _selectedState = null;
                  _selectedCity = null;
                  _selectedCityState = null;
                }),
              ),
              const SizedBox(height: 12),

              // State
              DropdownSearch<GeoState>(
                compareFn: (a, b) => a.id == b.id,
                filterFn: (_, __) => true,
                enabled: _selectedCountry != null,
                items: (filter, _) async {
                  if (_selectedCountry == null) return [];
                  final states = await GeoRepository.instance.statesOf(_selectedCountry!.iso2);
                  if (filter.isEmpty) return states;
                  final q = FuzzySearch.normalize(filter);
                  return states
                      .where((s) =>
                          FuzzySearch.matchesNormalized(s.normalizedName, q) ||
                          FuzzySearch.matchesNormalized(FuzzySearch.normalize(s.localizedName(_locale)), q))
                      .toList();
                },
                itemAsString: (s) => s.localizedName(_locale),
                selectedItem: _selectedState,
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(labelText: l10n.state),
                ),
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  searchDelay: Duration(milliseconds: 200),
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                  ),
                ),
                onChanged: (val) => setState(() {
                  _selectedState = val;
                  _selectedCity = null;
                  _selectedCityState = null;
                }),
              ),
              const SizedBox(height: 12),

              // City
              DropdownSearch<GeoCity>(
                compareFn: (a, b) => a.id == b.id,
                filterFn: (_, __) => true,
                enabled: _selectedCountry != null,
                items: (filter, _) async {
                  if (_selectedCountry == null) return [];
                  if (_selectedState != null) {
                    if (filter.isEmpty) return [];
                    final cities = await GeoRepository.instance.citiesOf(_selectedCountry!.iso2);
                    final q = FuzzySearch.normalize(filter);
                    return cities
                        .where((c) =>
                            c.stateId == _selectedState!.id &&
                            FuzzySearch.matchesNormalized(c.normalizedName, q))
                        .toList();
                  } else {
                    if (filter.isEmpty) return [];
                    final results = await GeoRepository.instance.searchCities(
                      iso2: _selectedCountry!.iso2,
                      query: filter,
                    );
                    return results.map((r) => r.city).toList();
                  }
                },
                itemAsString: (c) => c.name,
                selectedItem: _selectedCity,
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(labelText: l10n.city),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchDelay: const Duration(milliseconds: 200),
                  searchFieldProps: const TextFieldProps(
                    decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                  ),
                  emptyBuilder: _selectedState == null
                      ? (ctx, filter) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                filter.isEmpty ? l10n.typeToSearch : l10n.noResults,
                                style: Theme.of(ctx).textTheme.bodyMedium,
                              ),
                            ),
                          )
                      : null,
                ),
                onChanged: _onCityChanged,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _selectedCity != null ? _submit : null,
                child: Text(l10n.addCity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
