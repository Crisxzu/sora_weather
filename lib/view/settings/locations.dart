import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/common/fuzzy_search.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/providers/location.dart';
import 'package:weather_app/providers/params.dart';

class _CountryData {
  final String name;
  final String emoji;
  final List<_StateData> states;
  _CountryData({required this.name, required this.emoji, required this.states});
}

class _StateData {
  final String name;
  final List<String> cities;
  _StateData({required this.name, required this.cities});
}

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  List<_CountryData> _countries = [];
  _CountryData? _selectedCountry;
  _StateData? _selectedState;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final raw = await rootBundle.loadString('packages/country_state_city_picker/lib/assets/country.json');
    final List data = json.decode(raw);
    setState(() {
      _countries = data.map((c) {
        final states = (c['state'] as List? ?? []).map((s) {
          final cities = (s['city'] as List? ?? []).map((ci) => ci['name'] as String).toList();
          return _StateData(name: s['name'] as String, cities: cities);
        }).toList();
        return _CountryData(name: c['name'] as String, emoji: c['emoji'] as String? ?? '', states: states);
      }).toList();
    });
  }

  void _showAddCitySheet(BuildContext context) {
    _selectedCountry = null;
    _selectedState = null;
    _selectedCity = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final l10n = AppLocalizations.of(ctx)!;
            final states = _selectedCountry?.states ?? [];
            final cities = _selectedState?.cities ??
                (_selectedCountry?.states.expand((s) => s.cities).toSet().toList() ?? []);

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.addCity, style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  // Country
                  DropdownSearch<_CountryData>(
                    compareFn: (a, b) => a.name == b.name,
                    items: (filter, _) => _countries
                        .where((c) => FuzzySearch.matches(c.name, filter))
                        .toList(),
                    itemAsString: (c) => '${c.emoji}  ${c.name}',
                    selectedItem: _selectedCountry,
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(labelText: l10n.country),
                    ),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: const TextFieldProps(
                        decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                      ),
                    ),
                    onChanged: (val) => setSheetState(() {
                      _selectedCountry = val;
                      _selectedState = null;
                      _selectedCity = null;
                    }),
                  ),
                  const SizedBox(height: 12),

                  // State
                  DropdownSearch<_StateData>(
                    compareFn: (a, b) => a.name == b.name,
                    enabled: _selectedCountry != null,
                    items: (filter, _) => states
                        .where((s) => FuzzySearch.matches(s.name, filter))
                        .toList(),
                    itemAsString: (s) => s.name,
                    selectedItem: _selectedState,
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(labelText: l10n.state),
                    ),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: const TextFieldProps(
                        decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                      ),
                    ),
                    onChanged: (val) => setSheetState(() {
                      _selectedState = val;
                      _selectedCity = null;
                    }),
                  ),
                  const SizedBox(height: 12),

                  // City
                  DropdownSearch<String>(
                    enabled: _selectedCountry != null,
                    items: (filter, _) => cities
                        .where((c) => FuzzySearch.matches(c, filter))
                        .toList(),
                    selectedItem: _selectedCity,
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(labelText: l10n.city),
                    ),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: const TextFieldProps(
                        decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                      ),
                    ),
                    onChanged: (val) => setSheetState(() => _selectedCity = val),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _selectedCity != null && _selectedCity!.isNotEmpty
                        ? () {
                            Provider.of<LocationProvider>(ctx, listen: false).addCity(
                              cityName: _selectedCity!,
                              countryName: _selectedCountry?.name ?? '',
                              stateName: _selectedState?.name,
                              countryEmoji: _selectedCountry?.emoji,
                            );
                            Navigator.pop(ctx);
                          }
                        : null,
                    child: Text(l10n.addCity),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myLocations, style: textStyle['title2']),
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) {
          final locations = locationProvider.locations;

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final loc = locations[index];
              final isActive = locationProvider.activeIndex == index;
              final isGps = loc.isGps;

              return ListTile(
                leading: isGps
                    ? Icon(Icons.my_location, color: isActive ? Theme.of(context).colorScheme.primary : null)
                    : Text(loc.countryEmoji ?? '🌍', style: const TextStyle(fontSize: 24)),
                title: Text(
                  isGps ? l10n.myPosition : loc.cityName ?? '',
                  style: textStyle['body']!.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: isGps
                    ? Text(l10n.myPositionSubtitle, style: textStyle['bodySmall'])
                    : (loc.countryName != null
                        ? Text(
                            [loc.stateName, loc.countryName]
                                .where((p) => p != null && p.isNotEmpty)
                                .join(', '),
                            style: textStyle['bodySmall'],
                          )
                        : null),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive)
                      Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                    if (!isGps)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => locationProvider.removeAt(index),
                      ),
                  ],
                ),
                onTap: () {
                  locationProvider.setActive(index);
                  Provider.of<ParamsProvider>(context, listen: false)
                      .refreshIndicatorKey
                      ?.currentState
                      ?.show();
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCitySheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
