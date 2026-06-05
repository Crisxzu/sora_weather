import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:weather_app/providers/location.dart';
import 'package:weather_app/providers/params.dart';
import 'package:weather_app/view/settings/add_city_dialog.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  void _showAddCityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddCityDialog(),
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
        onPressed: () => _showAddCityDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
