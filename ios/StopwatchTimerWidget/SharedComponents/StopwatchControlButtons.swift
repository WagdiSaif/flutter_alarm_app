//
//  StopwatchControlButtons.swift
//  Runner
//
//  Created by wagdi saif  on 22/03/1448 AH.
//

import SwiftUICore
import SwiftUI
import WidgetKit
@available(iOS 17.0, *)
struct StopwatchControlButtons:View{
    

    let context:ActivityViewContext<LiveActivitiesAppAttributes>
    
    var body:some View{
        
        
        var activityId = context.activityID
        
        let stopwatState=context.state.stopwacthState ?? StopwatchState()
        let buttonAction=stopwatState.currentButtonAction
        
        HStack(spacing:25){
            if buttonAction == .Pause {
                
                
                
                
                Button(StopwatchButtonAction.Start.label, intent: StopwatchLiveActivityIntent(activityId: activityId, actionType: StopwatchButtonAction.Start.rawValue)).colorMultiply(.gray).foregroundStyle(.black).multilineTextAlignment(.leading).monospaced()
                
                
                
                
                Button(StopwatchButtonAction.Reset.label, intent: StopwatchLiveActivityIntent(activityId: activityId, actionType: StopwatchButtonAction.Reset.rawValue)).colorMultiply(.gray).foregroundStyle(.black).multilineTextAlignment(.leading).monospaced()
                
                
            }
            
            
            
            else{
                Button(StopwatchButtonAction.Pause.label, intent: StopwatchLiveActivityIntent(activityId: activityId, actionType: StopwatchButtonAction.Pause.rawValue)).colorMultiply(.gray).foregroundStyle(.black).multilineTextAlignment(.leading).monospaced()
                
                
                
                
                Button(StopwatchButtonAction.Lap.label, intent: StopwatchLiveActivityIntent(activityId: activityId, actionType: StopwatchButtonAction.Lap.rawValue)).colorMultiply(.gray).foregroundStyle(.black).multilineTextAlignment(.leading).monospaced()
                
                
            }}
        
    }
}
