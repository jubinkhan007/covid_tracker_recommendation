import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'coronavirus_service.dart';
import 'coronavirus_data.dart';
import 'stack_pie.dart';
import 'stats.dart';
import 'action_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'search_screen.dart';
import 'error_alert.dart';

enum LocationSource { Global, Local, Search }

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<CoronavirusData> futureCoronavirusData;
  LocationSource locationSource = LocationSource.Local;

  @override
  void initState() {
    super.initState();
    getData(countryCode: '');
  }

  void getData({required String countryCode}) async {
    switch (locationSource) {
      case LocationSource.Global:
        futureCoronavirusData = CoronavirusService().getLatestData();
        break;
      case LocationSource.Local:
        Placemark placemark = await LocationService().getPlacemark();
        setState(() {
          futureCoronavirusData =
              CoronavirusService().getLocationDataFromPlacemark(placemark);
        });
        break;
      case LocationSource.Search:
        if (countryCode != null) {
          futureCoronavirusData =
              CoronavirusService().getLocationDataFromCountryCode(countryCode);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppBarMainTitle, style: kTextStyleAppBar),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: FutureBuilder<CoronavirusData>(
            future: futureCoronavirusData,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return SpinKitPulse(color: kColourPrimary, size: 80);
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return dataColumn(coronavirusData: snapshot.data);
                  } else if (snapshot.hasError) {
                    return ErrorAlert(
                      errorMessage: snapshot.error.toString(),
                      onRetryButtonPressed: () {
                        setState(() {
                          getData(countryCode: '');
                        });
                      },
                    );
                  }
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Column dataColumn({required CoronavirusData coronavirusData}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          coronavirusData.date,
          style: kTextStyleDate,
          textAlign: TextAlign.center,
        ),
        Text(
          coronavirusData.locationLabel,
          style: kTextStyleLocationLabel,
          textAlign: TextAlign.center,
        ),
        StackPie(
          totalNumber: coronavirusData.totalNumber,
          sickNumber: coronavirusData.sickNumber,
          recoveredNumber: coronavirusData.recoveredNumber,
          deadNumber: coronavirusData.deadNumber,
        ),
        Stats(
          sickNumber: coronavirusData.sickNumber,
          recoveredNumber: coronavirusData.recoveredNumber,
          deadNumber: coronavirusData.deadNumber,
          sickPercentage: coronavirusData.sickPercentage,
          recoveredPercentage: coronavirusData.recoveredPercentage,
          deadPercentage: coronavirusData.deadPercentage,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ActionButton(
              icon: Icons.search,
              onPressed: () async {
                var countryCode = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
                setState(() {
                  locationSource = LocationSource.Search;
                  getData(countryCode: countryCode);
                });
              },
            ),
            ActionButton(
              icon: Icons.near_me,
              onPressed: () {
                setState(() {
                  locationSource = LocationSource.Local;
                  getData(countryCode: '');
                });
              },
            ),
            ActionButton(
              icon: Icons.language,
              onPressed: () {
                setState(() {
                  locationSource = LocationSource.Global;
                  getData(countryCode: '');
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}