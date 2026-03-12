import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

StateProvider<String> providerStateStr=StateProvider<String>((ref)=>'hello');

class AlarmHome  extends ConsumerWidget{

  const AlarmHome({super.key});


  @override

  Widget build(BuildContext context,WidgetRef ref){
    final startmesage=ref.watch(providerStateStr);
final width=MediaQuery.of(context).size.width;
final height=MediaQuery.of(context).size.height;

    return Scaffold(
appBar: AppBar(),
      body: Column(
        children: [
          Container(
            height: height,
            child: Text('data'),
          ),
        ],
      ),
    );
  }
}