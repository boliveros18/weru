import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequest extends StatefulWidget {
  final Function(bool) onPermissionStatusChanged;

  const PermissionRequest({super.key, required this.onPermissionStatusChanged});

  @override
  State<PermissionRequest> createState() => _PermissionRequestState();
}

class _PermissionRequestState extends State<PermissionRequest> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.notification,
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
      Permission.accessMediaLocation,
      Permission.manageExternalStorage,
      Permission.sensors,
      Permission.scheduleExactAlarm,
      Permission.ignoreBatteryOptimizations,
      Permission.phone,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      await openAppSettings();
    }

    widget.onPermissionStatusChanged(allGranted);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
