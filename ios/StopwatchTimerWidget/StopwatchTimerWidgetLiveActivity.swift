////
////  StopwatchTimerWidgetLiveActivity.swift
////  StopwatchTimerWidget
////
////  Created by wagdi saif  on 26/03/1448 AH.
////
//



import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents


struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState
  
    
    public struct ContentState: Codable,Hashable,Equatable {
        
        
        var  stopwacthState: StopwatchState?
        var timerState:TimerState?
        var activityType: String?
        
        
    }
    
    var id = UUID()
}


@available(iOS 17.0, *)

struct StopwatchTimerWidgetLiveActivity: Widget {
    
    let sharedDefault = UserDefaults(suiteName: "group.com.wagdi.alarmapp")!
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            
            
            let activeService=context.state.activityType ?? ""
            
            
            
            if activeService=="timer" {
                
                
                TimerLiveActivityWidget(context: context)
            }
            //stopwatch
            if activeService=="stopwatch" {
                
                
                
                StopwatchLiveActivityWidget(context: context)
            }
        
        } dynamicIsland: { context in
            var activityIdStr: String {
                return context.activityID
            }
            
            
            let activeService=context.state.activityType ?? ""
            //Stopwatch Section
            let allActiveActivities = Activity<LiveActivitiesAppAttributes>.activities

              let isTimerRunning = allActiveActivities.contains { $0.content.state.activityType == "timer" }
              let isStopwatchRunning = allActiveActivities.contains { $0.content.state.activityType == "stopwatch" }
              
              let areBothRunning = isTimerRunning && isStopwatchRunning
            
            //Timer
           
    


            return   DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    
                    HStack {
                        
                        if context.state.activityType == "timer" {
                            Label("Timer", systemImage: "timer")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.blue)
                        }
                        
                        if context.state.activityType == "stopwatch" {
                            Label("Stopwatch", systemImage: "stopwatch")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    
                    VStack(alignment:.trailing, spacing: 6){
                        if activeService == "timer" {
                            TimerIslandTrailingView(context: context)
                        }
                        
                        if activeService == "stopwatch" {
                            StopwatchIslandTrailingView(context: context)
                        }
                    }
                    
              
                    
                }
                DynamicIslandExpandedRegion(.bottom) {
                    
                    
                    HStack(spacing: 20) {
                        if activeService == "timer" {
                       
                            
                            TimerControlButtons(context: context)
                            
                            
                        }
                        if areBothRunning{
                               Divider().frame(height: 40).background(Color.gray.opacity(0.5))
                           }
                        
                        if activeService == "stopwatch" {
                            //stopwatch
                           
                            StopwatchControlButtons(context: context)
                            
                            
                        }
                    }
                    
                    
                    
                }
            } compactLeading: {
                
                if activeService == "timer" {
                    Text("⏳").font(.body)
                } else {
                    Text("⏱️").font(.body)
                }
                
            }
            compactTrailing: {
                
                let allActiveActivities = Activity<LiveActivitiesAppAttributes>.activities
                
                let isTimerActive = allActiveActivities.contains { $0.content.state.activityType == "timer" }
                let isStopwatchActive = allActiveActivities.contains { $0.content.state.activityType == "stopwatch" }
                let areBothActive = isTimerActive && isStopwatchActive
                
             
                if areBothActive {
                  
                    if context.state.activityType == "timer" {
                        TimerIslandTrailingView(context: context)
                    } else {
                        StopwatchIslandTrailingView(context: context)
                    }
                } else {
                    
                    if context.state.activityType == "timer" {
                        TimerIslandTrailingView(context: context)
                    } else if context.state.activityType == "stopwatch" {
                        StopwatchIslandTrailingView(context: context)
                    }
                }
                
            } minimal: {
               
                let allActiveActivities = Activity<LiveActivitiesAppAttributes>.activities
                
                let isTimerActive = allActiveActivities.contains { $0.content.state.activityType == "timer" }
                let isStopwatchActive = allActiveActivities.contains { $0.content.state.activityType == "stopwatch" }
                let areBothActive = isTimerActive && isStopwatchActive
                

                if areBothActive {
              
                    Text(context.state.activityType == "timer" ? "⏱️" : "⏳")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                } else {
                   
                    Text(context.state.activityType == "timer" ? "⏳" : "⏱️")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                }
            }

        }
        
  
    }
    


    
}




@available(iOS 16.1, *)
struct TimerIslandTrailingView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View{
        
        


        let timerState = context.state.timerState ?? TimerState()
        let timerAction =  timerState.timerButtonAction
        let nowDate = Date()
        
        let currentDurationInsecond = timerState.currentDuration

        if timerAction == .Pause  {
            let remainingTime = timerState.startDate.addingTimeInterval(currentDurationInsecond).formatRemainingDuration()
            
            Text(" \(remainingTime)") .font(.system(.caption2, design: .monospaced))
            
        } else {
            let timerIntervalTime = timerState.startDate.addingTimeInterval(TimeInterval(currentDurationInsecond))
            
            
            Text(timerInterval: nowDate...timerIntervalTime, countsDown: true)
                .font(.system(.caption2, design: .monospaced)).fontWeight(.bold).foregroundColor(.blue).multilineTextAlignment(.center).monospacedDigit()
            
            
        }
    }
    
}



@available(iOS 16.1, *)
struct StopwatchIslandTrailingView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View{
        
        
        
        //Stopwatch Section
        
        let nowDate = Date()
        let stopwatState=context.state.stopwacthState ?? StopwatchState()
        let startDate = stopwatState.startDate
        let stopwatchTargetDate =   startDate.addingTimeInterval(-TimeInterval((stopwatState.currentDuration/1000)))
   
        let pausedAtTime = startDate.addingTimeInterval(TimeInterval(     Int((stopwatState.currentDuration/1000).rounded())))
        
        let elapsedTime = pausedAtTime.formatRemainingDuration()
        let stopwatAction=stopwatState.currentButtonAction
        let lapsCount=stopwatState.laps.count
        
        
        
        if stopwatAction == .Pause{
            
            Text("\(elapsedTime)") .font(.system(.caption2, design: .monospaced)).font(.system(.caption2, design: .monospaced))
        }
        else{
            
            Text(timerInterval:stopwatchTargetDate...nowDate.addingTimeInterval(TimeInterval(9999999)),countsDown: false)
                .font(.system(.caption2, design: .monospaced)).fontWeight(.bold).foregroundColor(.blue).multilineTextAlignment(.center).monospacedDigit()
            if lapsCount>0{
                Text( " Lap \(lapsCount-1)") .font(.system(.caption2, design: .monospaced))
            }
            
            
            
        }
        
        
    }
    
}

