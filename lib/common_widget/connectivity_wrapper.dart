import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nearhood/common_widget/empty_state_widget.dart';
import 'package:nearhood/core/constants/app_assets.dart';
import 'package:nearhood/core/constants/app_strings.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/services/connectivity_service.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late StreamSubscription<bool> _subscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _isConnected = ConnectivityService.instance.isConnected;
    _subscription = ConnectivityService.instance.onConnectivityChanged.listen((
      connected,
    ) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: EmptyStateWidget(
          illustrationPath: AppAssets.noInternet,
          title: AppStrings.noInternet,
          subtitle: AppStrings.noInternetDesc,
          btnText: AppStrings.refresh,
          onPressed: () async {
            await ConnectivityService.instance.checkConnection();
          },
        ),
      ),
    );
  }
}
