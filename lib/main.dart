import 'package:flutter/material.dart';
import 'route_observer.dart';
import 'secondary_screen.dart';

import 'smart_ux.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: "/home_page",
      routes: {
        '/home_page':
            (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/second_page': (context) => const SecondaryScreen(),
      },
      navigatorObservers: [SmartUXObserver()],
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ...[
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed:
                      () => SmartUX.instance.recordAction(
                        actionId: 'tag_manager',
                        actionName: 'Tag Manager',
                        screenName: 'HomePage',
                      ),
                  child: const Text('Tag Manager'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () => SmartUX.instance.start(),
                  child: const Text('Start'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () => SmartUX.instance.stop(),
                  child: const Text('Stop'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed:
                      () => SmartUX.instance.sendEvent(
                        eventName: 'Basic Event',
                        eventCount: 1,
                      ),
                  child: const Text('Basic Event'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed:
                      () => SmartUX.instance.sendEvent(
                        eventName: 'Event With Sum',
                        eventCount: 1,
                        eventSum: 0.99,
                      ),
                  child: const Text('Event With Sum'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed:
                      () => SmartUX.instance.sendEvent(
                        eventName: 'Event with Segment',
                        eventCount: 1,
                        segmentation: {'Country': 'France', 'Age': 38},
                      ),
                  child: const Text('Event with Segment'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed:
                      () => SmartUX.instance.sendEvent(
                        eventName: 'Even with Sum and Segment',
                        eventCount: 1,
                        segmentation: {'Country': 'France', 'Age': 38},
                        eventSum: 0.99,
                      ),
                  child: const Text('Even with Sum and Segment'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    SmartUX.instance.startEvent(startEvent: 'timedEvent');
                    Future.delayed(
                      const Duration(seconds: 1),
                      () => SmartUX.instance.endEvent(eventName: 'timedEvent'),
                    );
                  },
                  child: const Text('Timed event'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    SmartUX.instance.startEvent(
                      startEvent: 'timedEventWithSum',
                    );
                    Future.delayed(
                      const Duration(seconds: 1),
                      () => SmartUX.instance.endEvent(
                        eventName: 'timedEventWithSum',
                        eventSum: 0.99,
                      ),
                    );
                  },
                  child: const Text('Timed events with Sum'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    SmartUX.instance.startEvent(
                      startEvent: 'timedEventWithSegment',
                    );
                    Future.delayed(
                      const Duration(seconds: 1),
                      () => SmartUX.instance.endEvent(
                        eventName: 'timedEventWithSegment',
                        segmentation: {'Country': 'Germany', 'Age': 32},
                      ),
                    );
                  },
                  child: const Text('Timed events with Segment'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    SmartUX.instance.startEvent(
                      startEvent: 'timedEventWithSumAndSegment',
                    );
                    Future.delayed(
                      const Duration(seconds: 1),
                      () => SmartUX.instance.endEvent(
                        eventName: 'timedEventWithSumAndSegment',
                        eventCount: 1,
                        eventSum: 0.99,
                        segmentation: {'Country': 'India', 'Age': 21},
                      ),
                    );
                  },
                  child: const Text('Timed events with Sum and Segment'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed:
                      () => SmartUX.instance.setUserData(
                        userId: "", // require for product
                        userDataMap: {
                          'name': 'Name of User',
                          'username': 'Username',
                          'email': 'User Email',
                          'organization': 'User Organization',
                          'phone': 'User Contact number',
                          'picture':
                              'https://kenh14cdn.com/203336854389633024/2023/8/24/qg-1692841944596899107413.jpg',
                          'picturePath': '',
                          'gender': 'Male',
                          'byear': 1989,
                        },
                      ),
                  child: const Text('Send Users Data'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed:
                      () => SmartUX.instance.setUserData(
                        userId: "", // require for product
                        userDataMap: {
                          'organization': 'Updated User Organization',
                          'phone': 'Updated User Contact number',
                          'gender': 'Female',
                          'byear': 1995,
                        },
                      ),
                  child: const Text('Update Users Data'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    SmartUX.instance.recordView(screenName: 'HomePage');
                    SmartUX.instance.trackingNavigationScreen(
                      screenName: 'HomePage',
                    );
                  },
                  child: const Text('Record View: \'HomePage\''),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed:
                      () => SmartUX.instance.recordView(
                        screenName: 'HomePage',
                        segmentation: {
                          'version': '1.0',
                          '_facebook_version': '0.0.1',
                        },
                      ),
                  child: const Text('Record View: \'HomePage\' with Segment'),
                ),
              ),
            ),
          ].expand((element) => [element, const SizedBox(height: 8)]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SmartUX.instance.recordAction(
            actionId: 'floating_action_button',
            actionName: 'Floating Action Button',
            screenName: 'HomePage',
          );
          Navigator.pushNamed(context, '/second_page');
        },
        tooltip: 'Next Second Page',
        child: const Icon(Icons.add),
      ),
    );
  }
}
