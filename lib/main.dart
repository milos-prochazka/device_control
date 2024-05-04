import 'device/device_extensions.dart';
import 'device/device_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'counter_device.dart';
import 'device/device_base.dart';

void main() 
{
  runApp(const MyApp());
  deviceList.addDevice(CounterDevice('Counter Device', 'counter-device'));
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      title: 'Flutter Demo',
      theme: ThemeData
      (
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyAppPage(),
    );
  }
}

typedef ActivityListener = void Function(bool isActive);

class MyAppPage extends StatefulWidget 
{
  const MyAppPage({super.key});

  @override
  State<MyAppPage> createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> 
{
  bool _active = true;

  @override
  Widget build(BuildContext context) 
  {
    return _active
    ? //
    PageContent
    (
      title: 'Flutter Demo Home Page',
      activityListener: (isActive) 
      {
        _active = isActive;
        if (mounted) setState(() {});
      },
    )
    : ////////////////////////////
    const SizedBox();
  }
}

class PageContent extends StatefulWidget 
{
  final ActivityListener activityListener;

  const PageContent({super.key, required this.title, required this.activityListener});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends IoNotifyState<PageContent> 
{
  bool _dotOn = true;

  _PageContentState() : super() 
  {
    print('_MyHomePageState constructor');
  }

  @override
  void initState() 
  {
    super.initState();
    final device = getDeviceById('counter-device')!;
    subscribeEvent
    (
      device, 'seconds', (device, name, event, eventParam) 
      {
        _dotOn = !_dotOn;
        if (mounted) setState(() {});
      }
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    final device = getDeviceById('counter-device')!;
    final timerRunning = getValue(device, 'seconds', getParam: 'isRunning') as bool? ?? false;
    if (!timerRunning) 
    {
      _dotOn = true;
    }

    final dotWidget = _dotOn
    ? SizedBox(width: 30, child: Center(child: Text(' : ', style: Theme.of(context).textTheme.headlineMedium)))
    : const SizedBox(width: 30);

    return Scaffold
    (
      appBar: AppBar
      (
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center
      (
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column
        (
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            const Text
            (
              'You have pushed the button this many times:',
            ),
            Text
            (
              getValue(device, 'counter').toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text
            (
              getValue(device, 'stopwatch'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith
              (
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            Row
            (
              mainAxisAlignment: MainAxisAlignment.center, children: 
              [
                ElevatedButton
                (
                  onPressed: () => device.command('start'),
                  child: const Text('start'),
                ),
                space,
                ElevatedButton
                (
                  onPressed: () => device.command('increment'),
                  child: const Text('reset'),
                ),
              ]
            ),
            space,
            Row
            (
              mainAxisSize: MainAxisSize.min, children: 
              [
                buildTimeField(context, device, 'hours'),
                dotWidget,
                buildTimeField(context, device, 'minutes'),
                dotWidget,
                buildTimeField(context, device, 'seconds'),
              ]
            ),
            space,
            buildStarStopTimerButton(context, device),
            space,
            ElevatedButton
            (
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecondPage())),
              child: const Text('Go to Second Page'),
            ),
            space,
            ElevatedButton
            (
              onPressed: () => setState
              (
                () async 
                {
                  try 
                  {
                    widget.activityListener.call(false);
                    if (mounted) setState(() {});
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const SecondPage()));
                  } 
                  finally 
                  {
                    widget.activityListener.call(true);
                    if (mounted) setState(() {});
                  }
                }
              ),
              child: const Text('Go to Second Page and deactivate'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: () => device.command('increment'),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildStarStopTimerButton(BuildContext context, DeviceBase device) 
  {
    final isRunning = getValue(device, 'seconds', getParam: 'isRunning') as bool? ?? false;

    return ElevatedButton
    (
      onPressed: () => device.command(isRunning ? 'stopTimer' : 'startTimer'),
      child: Text(isRunning ? 'Stop' : 'Start'),
    );
  }

  Widget buildTimeField(BuildContext context, DeviceBase device, String ioName) 
  {
    final editingController = getVisualState(device, ioName, stateCreator: (createParam) => (TextEditingController()))
    as TextEditingController;

    editingController.setIfChanged(getValue(device, ioName).toString());

    return IntrinsicWidth
    (
      stepWidth: 50,
      child: TextField
      (
        maxLengthEnforcement: MaxLengthEnforcement.none, //
        textAlign: TextAlign.center, //
        inputFormatters: [LengthLimitingTextInputFormatter(2), FilteringTextInputFormatter.digitsOnly],
        decoration:
        const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.only(top: 0, bottom: 0)),
        style: Theme.of(context)
        .textTheme
        .headlineMedium
        ?.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
        controller: editingController,
        keyboardType: TextInputType.number,
        readOnly: getValue(device, ioName, getParam: 'isRunning') as bool? ?? false,
        onChanged: (value) => setValue(device, ioName, int.tryParse(value) ?? 0)
      )
    );
  }
}

const space = SizedBox(height: 10, width: 10);

class SecondPage extends StatelessWidget 
{
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Second Page'),
      ),
      body: const Center
      (
        child: Text
        (
          'This is the second page',
        ),
      ),
    );
  }
}