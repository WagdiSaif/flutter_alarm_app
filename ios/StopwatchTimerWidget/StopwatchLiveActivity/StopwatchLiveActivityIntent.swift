//
//  StopwatchLiveActivityIntent.swift
//  Runner
//
//  Created by wagdi saif  on 13/03/1448 AH.
//


import AppIntents
import ActivityKit
@available(iOS 17.0, *)
struct StopwatchLiveActivityIntent:LiveActivityIntent{

    static var title: LocalizedStringResource = "Update Stopwatch"
    
    static var openAppWhenRun: Bool = false
    
    @Parameter(title:"actionId id")
    var activityId :String
   
    
    
    @Parameter(title : "actionType type")
    var actionType: String
    
    init() {
        
    }
    init(activityId: String, actionType: String) {
        self.activityId = activityId
        self.actionType = actionType
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        
        
        
        
        guard let activity = Activity<LiveActivitiesAppAttributes>.activities.first(where: {
            $0.id == activityId
        })else{
            return .result(dialog: .init(""))
        }
     
        
        var udpdatStopwatState = activity.content.state.stopwacthState ?? StopwatchState()
 
        
        let action = StopwatchButtonAction.byName(name: actionType)
        switch action {
        case .Pause:
   
            let currentElapsedInsecond = udpdatStopwatState.currentDuration/1000.0
            let  newElapsedDuration =   Date().timeIntervalSince( udpdatStopwatState.startDate.addingTimeInterval(-currentElapsedInsecond))
            udpdatStopwatState.currentDuration  = newElapsedDuration*1000
            
            udpdatStopwatState.startDate = Date()

            break
            
        
        case .Start:

            
            udpdatStopwatState.startDate = Date()
            break
        case .Lap:

            let currentElapsedInsecond = udpdatStopwatState.currentDuration/1000.0
            var  newElapsedDuration =   Date().timeIntervalSince( udpdatStopwatState.startDate.addingTimeInterval(-currentElapsedInsecond))
            udpdatStopwatState.currentDuration  = newElapsedDuration*1000
            
            udpdatStopwatState =    udpdatStopwatState.addLap()
            udpdatStopwatState.startDate = Date()

            break
        case .Reset:
       
            Task{
                let finalState=activity.content.state
                
                let finalContent=ActivityContent(state: finalState, staleDate: nil)
                await    activity.end(finalContent,dismissalPolicy:.immediate)
            }
            StopwatchStorage.remove()
            
            
            break
        default:
            break;
        }
        udpdatStopwatState.currentButtonAction=action
        try  StopwatchStorage.save(udpdatStopwatState)
        
        let newState=LiveActivitiesAppAttributes.ContentState(stopwacthState: udpdatStopwatState,activityType: "stopwatch")
        
        let content=ActivityContent(state: newState, staleDate: nil)
        
        await   activity.update(content)
        
        return .result(dialog: .init(""))
        
        
    }
    
    
    
    
}
