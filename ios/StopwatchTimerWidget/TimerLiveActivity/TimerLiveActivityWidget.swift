
import SwiftUI
import WidgetKit
import Foundation
@available(iOS 17.0, *)
struct TimerLiveActivityWidget: View {
    let sharedDefault = UserDefaults(suiteName: "group.com.wagdi.alarmapp")!
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var activityIdStr: String {
           return context.activityID
       }
    var body: some  View{
   

        let timerState = context.state.timerState ?? TimerState()

        let buttonAction =  timerState.timerButtonAction
   
        let remainingSecond=timerState.currentDuration
     
     
        let pausedAtTime = timerState.startDate.addingTimeInterval(remainingSecond).formatRemainingDuration()

        let nowDate = Date()
      
        let targetEndTime = timerState.startDate.addingTimeInterval(TimeInterval(remainingSecond))

        
        VStack(spacing: 5) {
           
            Label("Timer", systemImage: "timer")
                .font(.callout)
        

            if buttonAction == .Pause  {

                 Text(" \(pausedAtTime)").font(.title3).fontWeight(.bold).foregroundColor(.red).monospacedDigit()


            } else {
         
                Text(timerInterval: nowDate...targetEndTime, countsDown: true)
                    .font(.title2).fontWeight(.bold).foregroundColor(.black).multilineTextAlignment(.center).monospacedDigit()
            }
        
            TimerControlButtons(context: context)
        }.padding()
        
        

    }
}
