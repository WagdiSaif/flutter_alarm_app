
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'alarm_screen.dart';

StateProvider<int> pageIndex=StateProvider<int>((ref)=>0);

class Homescreen extends ConsumerWidget {
  
 Homescreen({super.key});
  final List<BottomNavigationBarItem> _bottomNavigationItem = const [
  BottomNavigationBarItem(
    label: 'Timer',
      icon: Icon(Icons.timer)
    ),
     BottomNavigationBarItem(label: 'alarm',
      icon: Icon(Icons.av_timer)
    ),
     BottomNavigationBarItem(
      label: 'colo',
      icon: Icon(Icons.alarm)
    ),
  ];
  final List<Widget> _bottomNavigationView = [
     AlarmScreen(),
    Container(
      color: Colors.green,
      child: const Text('commect'),
    ),
    Container(
      color: Colors.blue,
      child: const Text('about'),
    )
  ];

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final currentPageIndex=ref.watch(pageIndex);
    return Scaffold(

      bottomNavigationBar: BottomNavigationBar(items: _bottomNavigationItem
      ,currentIndex: currentPageIndex,
      onTap: (value) => ref.read(pageIndex.notifier).state =value,
      
      ),
      body: _bottomNavigationView[currentPageIndex]
          
        ,
      
//       floatingActionButton: FloatingActionButton(
// onPressed: () {
  
// },
//         child: Container(
//           decoration:const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//           // alignment: Alignment.bottomCenter,
//           margin: const EdgeInsets.only(bottom: 3),
//           height: 70,
//           width: 70,
          
//           child: Center(
//               child: IconButton(
//                   onPressed: () {
//                     Navigator.of(context)
//                         .push(MaterialPageRoute(builder: (contex) {
//                       return AddAlarmScreen();
//                     }));
//                   },
//                   icon: const Icon(
//                     Icons.add,
//                     size: 20,
//                   ))),
//         ),
//       ),
    );
  }
}
