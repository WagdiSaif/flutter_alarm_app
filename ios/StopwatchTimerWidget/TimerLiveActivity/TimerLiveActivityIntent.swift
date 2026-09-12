import AppIntents
import ActivityKit
@available(iOS 17.0, *)
struct TimerLiveActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Update Timer"
    static var openAppWhenRun: Bool = false
    @Parameter(title: "Activity ID")
    var activityId: String
    
    @Parameter(title: "Action Type")
    var actionType: String
    
    
    
    
    init() {
    }
    init(activityId: String, actionType: String) {
        self.activityId = activityId
        self.actionType = actionType
        
        
        
    }
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let sharedDefault = UserDefaults(suiteName: "group.com.wagdi.alarmapp") else{
            
            return .result(dialog: .init(""))
        }
        guard let activity = Activity<LiveActivitiesAppAttributes>.activities.first(where: { $0.id == activityId }) else {
            return .result(dialog: .init(""))
        }
        let  nowDate = Date()
        var updateTimerState = activity.content.state.timerState ?? TimerState()
        
        let remainingSecond =   updateTimerState.currentDuration
        
        let action = TimerButtonAction.byName(actionType)
        let startDate = updateTimerState.startDate
        switch action {
        case .AddOneMinute:

            let newRemainingSeconds = startDate.addingTimeInterval(remainingSecond).timeIntervalSince(nowDate)//startTime - now
            
            updateTimerState.currentDuration  = newRemainingSeconds>0 ? newRemainingSeconds+60 :60
            updateTimerState.startDate=Date()

            break
        case .Pause:
            let newRemainingSeconds = startDate.addingTimeInterval(remainingSecond) .timeIntervalSince(nowDate)
            updateTimerState.currentDuration = newRemainingSeconds>=0 ? newRemainingSeconds :0
            
            
            updateTimerState.startDate = nowDate
            
            //Store new Start Date
            
            break
        case .Resume:
            //
            
            updateTimerState.startDate =  nowDate
            
            break
        case .Reset:
            let finalState = activity.content.state
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            TimerStateStorage.remove()
            Task {
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
            
            
            
            break
        default:
            break
        }
        updateTimerState.timerButtonAction = action
        
        let newState = LiveActivitiesAppAttributes.ContentState(timerState: updateTimerState, activityType: "timer")
        let content = ActivityContent(state: newState, staleDate: nil)
        await activity.update(content)
        try  TimerStateStorage.save(updateTimerState)
        return .result(dialog: .init(""))
    }
}
