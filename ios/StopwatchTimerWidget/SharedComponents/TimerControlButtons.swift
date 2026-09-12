//
//  TimerControlButtons.swift
//  Runner
//
//  Created by wagdi saif  on 22/03/1448 AH.
//

import SwiftUICore
import SwiftUI
import WidgetKit


@available(iOS 17.0, *)
struct TimerControlButtons:View{
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    
    
    
    
    var body: some View{
        
        var activityId = context.activityID
        let timerState = context.state.timerState ?? TimerState()
        let buttonAction =  timerState.timerButtonAction
        
   
        
        HStack(spacing:25
        ){
            
            if buttonAction == .Pause {
                
                Button(TimerButtonAction.Resume.label, intent: TimerLiveActivityIntent(
                    activityId:activityId, actionType: TimerButtonAction.Resume.rawValue)).colorMultiply(.gray).foregroundStyle(.black).monospaced().multilineTextAlignment(.leading)
                
                
                Button(TimerButtonAction.Reset.label, intent: TimerLiveActivityIntent(activityId:activityId, actionType: TimerButtonAction.Reset.rawValue)).colorMultiply(.gray).foregroundStyle(.black).monospaced().multilineTextAlignment(.leading)
            }
            
            else{
             
                Button(TimerButtonAction.Pause.label, intent: TimerLiveActivityIntent(activityId:activityId, actionType: TimerButtonAction.Pause.rawValue)).monospaced().multilineTextAlignment(.leading).colorMultiply(.gray).foregroundStyle(.black)
                
                
                Button(TimerButtonAction.AddOneMinute.label, intent: TimerLiveActivityIntent(activityId:activityId, actionType: TimerButtonAction.AddOneMinute.rawValue)).monospaced().multilineTextAlignment(.leading).colorMultiply(.gray).foregroundStyle(.black)
            }
        }
    }
}
