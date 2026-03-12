import 'package:alarmapp/core/extensions.dart';
import 'package:alarmapp/model/datetime_setting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alarmapp/helper/sizer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:intl/intl.dart';

import '../helper/helper_message.dart';

StateProvider<bool> isAM = StateProvider(
  (ref) => DateTime.now().amPmTime == 'AM' ? true : false,
);
StateProvider<bool> isPM = StateProvider(
  (ref) => DateTime.now().amPmTime == 'PM' ? true : false,
);
StateProvider<int> hoursIndex = StateProvider(
  (ref) => int.parse(DateTime.now().toHours),
);

StateProvider<int> minutesIndex = StateProvider(
  (ref) => int.parse(DateTime.now().toMinutes),
);

class AddAlarmScreen extends ConsumerStatefulWidget {
  const AddAlarmScreen({super.key});

  @override
  ConsumerState<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends ConsumerState<AddAlarmScreen> {
  int selectedHour = 3;

  int selectedMinute = 59;

  late final FixedExtentScrollController _hoursController;
  late final FixedExtentScrollController _minutesController;
  late DateTimeSetting _dataTime;

  List<int> get getHoursList => List<int>.generate(
    12,
    (index) => Duration(hours: index + 1, minutes: 0, seconds: 0).inHours,
  );

  List<int> get getMinutesList =>
      List<int>.generate(60, (index) => Duration(minutes: index).inMinutes);

  @override
  void initState() {
    super.initState();

    _dataTime = DateTimeSetting(
      year: DateTime.now().year,
      month: DateTime.now().month,
      hour: ref.read<int>(hoursIndex),
      second: DateTime.now().second,
      minute: ref.read<int>(minutesIndex),
      day: DateTime.now().day,
      microsecond: DateTime.now().microsecond,
      millisecond: DateTime.now().millisecond,
      peroid: ref.read<bool>(isPM) ? 'PM' : 'AM',
    );

    _hoursController = FixedExtentScrollController(
      initialItem: ref.read<int>(hoursIndex),
    );
    _minutesController = FixedExtentScrollController(
      initialItem: ref.read<int>(minutesIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTimeAm = ref.watch<bool>(isAM);
    final isTimePm = ref.watch<bool>(isPM);
    final currentHours = ref.watch(hoursIndex);
    final currentMinutes = ref.watch(minutesIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_dataTime.hour} : ${_dataTime.minute.toString().padLeft(2, '0')}: ${_dataTime.peroid}',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            // _dataTime.hour = hoursIndex.value;
            // _dataTime.minute = minutesIndex.value;
            if (kDebugMode) {
              print(
                'minutes  ${_dataTime.minute}hourse ${_dataTime.hour}period :${_dataTime.peroid}  \$  ${_dataTime.totDateTime}}',
              );
            }
            // await CreateAlarm.instanceAlarm.setAlarm(_dataTime);
            final message =
                '${_dataTime.hour} : ${_dataTime.minute}: ${_dataTime.peroid}';
            if (context.mounted) {
              HelperMessage.scaffoldSetAlarmMessage(context, message);
            }
            // CreateAlarm.instanceAlarm.checkAlarm(_dataTime);
          },
          icon: const Icon(Icons.check_sharp),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_sharp),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30.sw,
                  height: 30.sh,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'PM',
                          style: TextStyle(
                            fontSize: 24,
                            color: isTimePm ? Colors.red : Colors.black,
                          ),
                        ),
                      ),

                      Center(
                        child: Text(
                          'AM',
                          style: TextStyle(
                            fontSize: 24,
                            color: isTimeAm ? Colors.red : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),



                SizedBox(
                  width: 30.sw,
                  height: 30.sh,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 50,
                    squeeze: 1,

                    controller: _hoursController,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      _listenForScrollNotification(
                        currentMinutes,
                        currentHours,
                        isTimeAm,
                        isTimePm,

                        _hoursController.position.userScrollDirection,
                        index,
                      );

                      if (kDebugMode) {
                        print(
                          'scrolling is${_hoursController.position.userScrollDirection}',
                        );
                      }

                      ref
                          .read(hoursIndex.notifier)
                          .state = getHoursList[index] == 12
                          ? 0
                          : getHoursList[index] + 12;
                      if (kDebugMode) {
                        // print('index is :   ${hoursIndex.value}');
                      }
                    },
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: getHoursList.map((int e) {
                        int compair = e == 12 ? 0 : e + 12;
                        return Center(
                          child: Text(
                            // textDirection: TextDirection,
                            e.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: currentHours == compair
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: currentHours == compair
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                SizedBox(
                  width: 30.sw,
                  height: 30.sh,
                  child: ListWheelScrollView.useDelegate(
                    squeeze: 1,
                    itemExtent: 50,
                    controller: _minutesController,
                    onSelectedItemChanged: (index) {
                      ref.read(minutesIndex.notifier).state =
                          getMinutesList[index];
                      _dataTime.minute = ref.read(minutesIndex.notifier).state;
                      if (kDebugMode) {
                        print(
                          'mibtes index is ${ref.read(minutesIndex.notifier).state}',
                        );

                        print(
                          'minutes  ${_dataTime.minute}hourse ${_dataTime.hour}period :${_dataTime.peroid}  \$  ${_dataTime.totDateTime}}',
                        );
                      }
                    },
                    // clipBehavior: Clip.antiAlias,
                    // controller: _controller,
                    physics: const FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: getMinutesList.map((int element) {
                        return Center(
                          child: Text(
                            element.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: currentMinutes == element
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: currentMinutes == element
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ListTile(
              title: const Text('Ringtone'),
              subtitle: const Text('Default ringtone'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            SwitchListTile(
              title: const Text('Vibrate when alarm sounds'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Delete after goes off'),
              value: false,
              onChanged: (value) {},
            ),
            ListTile(
              title: const Text('Label'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  bool _listenForScrollNotification(
    int currentMinutes,
    int currentHours,
    bool isTimeAm,
    bool isTimePm,
    ScrollDirection scrollDirection,
    int index,
  ) {
    if (kDebugMode) {
      print('Current hour index: ${getHoursList[index]}');
    }
    int currentHours = DateFormat('hh:mm:ss')
        .parse(DateFormat('hh:mm:ss').format(DateTime.now()), true)
        .microsecondsSinceEpoch;
    // Get the current hour from the hoursList
    int hour = getHoursList[index];

    _dataTime.hour = hour + 12;
    _dataTime.minute = currentMinutes;

    final dateFormated = DateTimeSetting.fromDate(_dataTime);
    if (kDebugMode) {
      print('minutes is${dateFormated.totDateTime}');
    }
    _dataTime = dateFormated;
    int alarmTime = DateFormat('HH:mm:ss')
        .parse(DateFormat('HH:mm:ss').format(_dataTime.totDateTime), true)
        .microsecondsSinceEpoch;
    final currentPeroid = DateFormat('a').format(DateTime.now());
    // Determine if we're moving forward or backward
    bool isMovingForward = scrollDirection == ScrollDirection.forward;

    // Check current state of isAM and isPM
    // bool wasAM = isTimeAm;
    // bool wasPM = isPM.value;

    // Create a DateTime object for the current day and the specific hour
// Add 12 for PM

    // final df = TimeOfDay(hour: Duration(hours: hour).inHours, minute: 0);

    // final TimeOfDayFormat timeOfDayFormat = MaterialLocalizations.of(context).timeOfDayFormat(
    //     alwaysUse24HourFormat: true,
    //   );

    if (isTimePm && !isMovingForward) {
      // Case 1: If the current period is PM and we are moving backward
      if (hour == 12) {
        // Transition from PM to AM, moving to the next day
        isTimePm = false;
        isTimeAm = true;

        _dataTime.day = DateTime.now().day + 1;
        _dataTime.peroid = 'AM';
      } else if (hour == 11) {
        // Stay within PM but shift backward within the same day
        isTimePm = true;
        isTimeAm = false;
        _dataTime.day = DateTime.now().day;
        _dataTime.peroid = 'PM';
      }
    } else if (isTimePm && isMovingForward) {
      // Case 2: If the current period is PM and we are moving forward
      if (hour == 12) {
        // Stay within PM, still at the current day
        isTimePm = true;
        isTimeAm = false;
        _dataTime.day = DateTime.now().day + 1;
        _dataTime.peroid = 'PM';
      } else if (hour == 11) {
        // Transition from PM to AM within the same day
        isTimePm = false;
        isTimeAm = true;
        _dataTime.day = DateTime.now().day + 1;
        _dataTime.peroid = 'AM';
      }
    } else if (isTimeAm && !isMovingForward) {
      // Case 3: If the current period is AM and we are moving backward
      if (hour == 12) {
        // Transition from AM to PM, moving to the next day
        isTimePm = true;
        isTimeAm = false;
        _dataTime.day = DateTime.now().day + 1;
        _dataTime.peroid = 'PM';
      } else if (hour == 11) {
        // Stay within AM but shift backward within the current day
        isTimePm = false;
        isTimeAm = true;
        _dataTime.day = DateTime.now().day;
        _dataTime.peroid = 'AM';
      }
    } else if (isTimeAm && isMovingForward) {
      // Case 4: If the current period is AM and we are moving forward
      if (hour == 12) {
        // Transition within AM, staying in the same period
        isTimePm = false;
        isTimeAm = true;
        _dataTime.day = DateTime.now().day + 1;
        _dataTime.peroid = isTimeAm ? 'AM' : 'PM';
      } else if (hour == 11) {
        // Transition from AM to PM
        isTimePm = true;
        isTimeAm = false;
        _dataTime.day = DateTime.now().day;
        _dataTime.peroid = isTimeAm ? 'AM' : 'PM';
      }
    }

    if (isTimePm && currentPeroid == 'AM') {
      _dataTime.day = DateTime.now().day + 1;
      _dataTime.peroid = 'PM';
    } else if (isTimeAm && currentPeroid == 'PM') {
      _dataTime.day = DateTime.now().day + 1;
      _dataTime.peroid = 'AM';

      if (kDebugMode) {
        print('here we are1');
      }
    } else if (alarmTime < currentHours) {
      if ((hour != 11 && hour != 12)) {
        _dataTime.day = DateTime.now().day + 1;
        _dataTime.peroid = isTimeAm ? 'AM' : 'PM';
        if (kDebugMode) {
          print('here we insed4');
        }
      }
      // else if ((hour != 11 && hour != 12)) {
      //   _dataTime.day = DateTime.now().day + 1;
      //   _dataTime.peroid = isTimeAm ? 'AM' : 'PM';
      // }
      // else {
      //   _dataTime.day = DateTime.now().day + 1;
      //   _dataTime.peroid = 'AM';
      // }
      if (kDebugMode) {
        print('here we are4');
      }
    } else if (alarmTime > currentHours) {
      if ((hour != 11 && hour != 12)) {
        _dataTime.day = DateTime.now().day;
        _dataTime.peroid = isTimeAm ? 'AM' : 'PM';
        if (kDebugMode) {
          print('here we insed3');
        }
      }
      // else if ((hour != 11 && hour != 12)) {
      //   _dataTime.day = DateTime.now().day + 1;
      //   _dataTime.peroid = isTimeAm ? 'AM' : 'PM';
      // }
      // else {
      //   _dataTime.day = DateTime.now().day + 1;
      //   _dataTime.peroid = 'AM';
      // }
      if (kDebugMode) {
        print('here we are3');
      }
    }
    if (kDebugMode) {
      print('alarmTime$alarmTime currenthours$currentHours');
      // print(
      //     'datetime format ${DateFormat('yyyy-MM-dd hh:mm ss').parse(DateFormat('yyyy-MM-dd hh:mm ss').format(_dataTime.totDateTime)).microsecondsSinceEpoch} ${

      //     }');
    }

 
    DateTime.timestamp();

    final dateFormated1 = DateTimeSetting.fromDate(_dataTime);
    if (kDebugMode) {
      print('The Alram in Time $hour ${isTimeAm ? 'AM' : 'PM'}}');

      print(
        'minutes  ${_dataTime.minute}hourse ${_dataTime.hour}period :${_dataTime.peroid}  \$  ${_dataTime.totDateTime}}',
      );
    }
    return true;
  }
}
