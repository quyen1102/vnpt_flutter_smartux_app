import 'package:flutter/material.dart';
import 'channels/icsmartux_channel.dart';
import 'route_observer.dart';

class SecondaryScreen extends StatefulWidget {
  const SecondaryScreen({super.key});

  @override
  State<SecondaryScreen> createState() => _SecondaryScreenState();
}

class _SecondaryScreenState extends State<SecondaryScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    ICSmartUXChannel.trackingNavigationEnter(
      name: 'SecondaryScreen',
      timeDelay: 0.3, // Tăng delay nếu màn hình có animation
    );
  }

  @override
  void didPopNext() {
    // Quay lại màn hình này từ một màn hình khác
    ICSmartUXChannel.trackingNavigationEnter(name: 'SecondaryScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secondary Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back to Home'),
        ),
      ),
    );
  }
}
