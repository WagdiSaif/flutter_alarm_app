import SwiftUICore
import SwiftUI
import WidgetKit
@available(iOS 17.0, *)
struct StopwatchLiveActivityWidget: View {
    let sharedDefault = UserDefaults(suiteName: "group.com.wagdi.alarmapp")!
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View {
        
        let activityIdStr = context.activityID
        
        let stopwatState=context.state.stopwacthState ?? StopwatchState()
        
     
        
        let elpasedDurationInsecond =
        Int((stopwatState.currentDuration/1000.0).rounded())
     
        let startDate = stopwatState.startDate
       
        let stopwatchTargetDate =   startDate.addingTimeInterval(-TimeInterval(elpasedDurationInsecond))
        
        let pausedAtTime = startDate.addingTimeInterval(TimeInterval(elpasedDurationInsecond))
      
        let elapsedTime = pausedAtTime.formatRemainingDuration()
        let buttonAction=stopwatState.currentButtonAction
        let lapsCount=stopwatState.laps.count
        
        
        VStack(spacing: 8) {
            Label("Stopwatch", systemImage: "stopwatch")  
                .font(.callout)
            if buttonAction == .Pause{
                Text(" \(elapsedTime)").font(.title3).fontWeight(.bold).foregroundColor(.red).monospacedDigit()
                
                
            }
            
      
            
            else{   let nowDate = Date()
                
                Text(timerInterval:stopwatchTargetDate...nowDate.addingTimeInterval(TimeInterval(36000)),countsDown: false)
                    .padding(.horizontal, 10).padding(.vertical, 4) .font(.title2)
                    .fontWeight(.bold)
                    .colorMultiply(.gray).foregroundColor(.black).cornerRadius(8).multilineTextAlignment(.center)
                
                if lapsCount>0{
                    Text( " Lap \(lapsCount-1)").font(.title2)
                }
            }
            
       
          
            
            
                
            StopwatchControlButtons(context: context)
                
        
            
            
        }.padding(.vertical,40)}
            
            
            
        }
