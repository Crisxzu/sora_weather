import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/common/fuzzy_search.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/data/geo_repository.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/model/geo/geo_city.dart';
import 'package:weather_app/model/geo/geo_country.dart';
import 'package:weather_app/model/geo/geo_state.dart';
import 'package:weather_app/providers/location.dart';
import 'package:weather_app/providers/params.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  List<GeoCountry> _countries = [];
  GeoCountry? _selectedCountry;
  GeoState? _selectedState;
  GeoCity? _selectedCity;
  GeoState? _selectedCityState;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final countries = await GeoRepository.instance.countries();
    if (mounted) setState(() => _countries = countries);
  }

  void _showAddCitySheet(BuildContext context) {
    _selectedCountry = null;
    _selectedState = null;
    _selectedCity = null;
    _selectedCityState = null;

    final locale = Provider.of<ParamsProvider>(context, listen: false).locale?.languageCode ?? 'en';

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
                  DropdownSearch<GeoCountry>(
                    compareFn: (a, b) => a.iso2 == b.iso2,
                    filterFn: (_, __) => true,
                    items: (filter, _) => _countries
                        .where((c) => FuzzySearch.matches(c.localizedName(locale), filter) ||
                            FuzzySearch.matches(c.name, filter))
                        .toList(),
                    itemAsString: (c) => '${c.emoji}  ${c.localizedName(locale)}',
                    selectedItem: _selectedCountry,
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(labelText: l10n.country),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                      ),
                    ),
                    onChanged: (val) => setSheetState(() {
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
                      return states
                          .where((s) => FuzzySearch.matches(s.localizedName(locale), filter) ||
                              FuzzySearch.matches(s.name, filter))
                          .toList();
                    },
                    itemAsString: (s) => s.localizedName(locale),
                    selectedItem: _selectedState,
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(labelText: l10n.state),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                      ),
                    ),
                    onChanged: (val) => setSheetState(() {
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
                        // Cities from selected state only
                        final cities = await GeoRepository.instance.citiesOf(_selectedCountry!.iso2);
                        return cities
                            .where((c) => c.stateId == _selectedState!.id &&
                                FuzzySearch.matches(c.name, filter))
                            .toList();
                      } else {
                        // Search across all cities of the country
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
                    onChanged: (val) async {
                      if (val == null) {
                        setSheetState(() {
                          _selectedCity = null;
                          _selectedCityState = null;
                        });
                        return;
                      }
                      // Resolve the state for this city
                      GeoState? cityState = _selectedState;
                      if (cityState == null && _selectedCountry != null) {
                        final states = await GeoRepository.instance.statesOf(_selectedCountry!.iso2);
                        cityState = states.where((s) => s.id == val.stateId).firstOrNull;
                      }
                      setSheetState(() {
                        _selectedCity = val;
                        _selectedCityState = cityState;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _selectedCity != null
                        ? () {
                            Provider.of<LocationProvider>(ctx, listen: false).addCity(
                              cityName: _selectedCity!.name,
                              countryName: _selectedCountry?.name ?? '',
                              stateName: _selectedCityState?.name,
                              countryEmoji: _selectedCountry?.emoji,
                              countryIso2: _selectedCountry?.iso2,
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
