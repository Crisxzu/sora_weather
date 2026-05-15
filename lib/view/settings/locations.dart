import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/providers/location.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

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
                  Text(
                    l10n.addCity,
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SelectState(
                    onCountryChanged: (val) => setSheetState(() {
                      _selectedCountry = val;
                      _selectedState = null;
                      _selectedCity = null;
                    }),
                    onStateChanged: (val) => setSheetState(() {
                      _selectedState = val;
                      _selectedCity = null;
                    }),
                    onCityChanged: (val) => setSheetState(() => _selectedCity = val),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _selectedCity != null && _selectedCity!.isNotEmpty
                        ? () {
                            Provider.of<LocationProvider>(ctx, listen: false).addCity(
                              cityName: _selectedCity!,
                              countryName: _selectedCountry ?? '',
                              stateName: _selectedState,
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
                leading: Icon(
                  isGps ? Icons.my_location : Icons.location_city,
                  color: isActive ? Theme.of(context).colorScheme.primary : null,
                ),
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
