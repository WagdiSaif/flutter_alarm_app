import ActivityKit

//The following class represents Bridge Between AppDelegate and Our Widget Extenetion
@available(iOS 16.2, *)
public class LiveActivityPlugin: NSObject, FlutterPlugin {
   
    
    private static let CHANNEL_NAME = "com.wagdi.alarmapp/live_activity"
    
    public static func register(with registar:any FlutterPluginRegistrar) {
        let messenger = registar.messenger()
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: messenger)
  
        let instance = LiveActivityPlugin()
        registar.addMethodCallDelegate(instance, channel: channel)
    }
    var sharedDefault:UserDefaults{
        
        
        return UserDefaults(suiteName: "group.com.wagdi.alarmapp")!
        
        
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "createActivity" {
            guard let args = call.arguments as? [String: Any],
                  
                    let activeService=args["activeService"] as? String
                    
            else {
                return  result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                
            }

            
            if activeService=="timer"
            {
                
                
       
                handleTimerService(call,result: result)
                
            }
            
            else{
           
                handleStopwatchService(call,result: result)
            }
            
        }
        else if call.method == "retrieveTimerData"{
            
            
            retrieveTimerData(result: result)
        }
        else if call.method == "retrieveStopwatchData"{
            retrieveStopwatchData(result: result)
            
        }
        else if call.method=="cleanUpServicesSData"{
            
            cleanUpServicesSData()
            
            return result("Clean Up Successfully")
        }
        else if call.method=="cancellAllNotifications"{
            
            
            Task{
                do{
                    try  await cancelAllNotification()
                    result(" canceled All Notification Succssfully")
                }
                catch{
                    
                    result(FlutterError(code: "END_ERR", message: error.localizedDescription, details:nil))
                }
            }
        }
        
        else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleTimerService(_ call:FlutterMethodCall,result:@escaping FlutterResult){
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        guard let args = call.arguments as? [String:Any],
              let actionName = args["timerButtonAction"] as? String
        
        else{
            return result(FlutterError(code: "ERROR", message: "ARGS_ERROR", details: nil))
        }
        
        TimerStateStorage.remove()
       
        
        let currentDuration = args.double(for: "currentDuration")
     

        let timerState=TimerState(currentDuration: currentDuration, timerButtonAction: TimerButtonAction.byName(actionName))

        do {
            try TimerStateStorage.save( timerState)
            
            let attributes = LiveActivitiesAppAttributes()

            let  state = LiveActivitiesAppAttributes.ContentState(
                timerState:timerState,
                activityType: "timer"
                
            )
            
            _ = try Activity<LiveActivitiesAppAttributes>.request(attributes: attributes, content: ActivityContent(state: state, staleDate: nil),pushType: nil)
            result(" Timer Starting Succssfully")
            
        } catch {
            result(FlutterError(code: "ERROR", message: "", details: nil))
        }
    }
    
    
    private func handleStopwatchService(_ call:FlutterMethodCall,result:@escaping FlutterResult){
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return
            
        }
        guard let args = call.arguments as? [String:Any],
              let currentButtonAction=args["stopwatchButtonAction"] as? String
                //
        else{
            return result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
            
        }
        var allLaps:[Laps]=[]
        
        do{
            
            StopwatchStorage.remove()
            
            //Remmber That All The following Numrical Data in Milisecond Incoming from Flutter
            if let lapsData=args["laps"] as? [[String:Any]]{
                
                for lap in lapsData {
                    let lapInstance =  Laps.fromJson(json: lap)
                    
                    allLaps.append(lapInstance)
                }
                
            }
            //          let currentDuration
            let stopwatchState =  StopwatchState.init(laps: allLaps, currentDuration: args.double(for:"currentDuration"),startDate: Date(), currentButtonAction:
                                                        StopwatchButtonAction.byName(name: currentButtonAction))
            
            
            try StopwatchStorage.save( stopwatchState)
            
            let attributes = LiveActivitiesAppAttributes()
            
            let state = LiveActivitiesAppAttributes.ContentState(
                stopwacthState: stopwatchState,
              
                activityType: "stopwatch"
            )
            
            _ = try Activity<LiveActivitiesAppAttributes>.request(attributes: attributes, content: ActivityContent(state: state, staleDate: nil),pushType: nil)

            result("Calling Stopwatch Successfully!")
            
        } catch {
            result("Failed to Run Stopwacth Service")
            return
        }
    }
    private  func retrieveTimerData(result:@escaping FlutterResult)  {
        
        
        do{
            let isTimerActive = Activity<LiveActivitiesAppAttributes>.activities.contains(where:  {$0.content.state.activityType=="timer"} )
          
//            activities
            
         
         
            if !isTimerActive{
                return result(nil)
                
                
            }
            var timerState = try TimerStateStorage.load()
            
            
            if timerState.timerButtonAction != .Pause {//Because it is Running we  calculate remaining Second form started+Interval-currentDate(timeIntervalSince(Date()) This is helpful
                
                let startedDate =  timerState.startDate//Get Start timer Date That we  already saved it
                
                let finalRemainingSecond=timerState.currentDuration
                let finalSeconds =  startedDate.addingTimeInterval(finalRemainingSecond).timeIntervalSince(Date())
            
                timerState.currentDuration=finalSeconds
                return result(timerState.asDictionary)
                
                
                
            }
            
            else{//The seconds still have not changed because timer Paused
                
                
                return result(timerState.asDictionary)
            }
        }
        catch{
            
            return result([:])
        }
        
        
    }
    
    
    private  func retrieveStopwatchData(result:@escaping FlutterResult){
        
        do{
            
            let isStopwatchActive = Activity<LiveActivitiesAppAttributes>.activities.contains(where:  {$0.content.state.activityType=="stopwatch"} )
          
//            activities
            
         
         
            if !isStopwatchActive {
                return result(nil)
                
            }
            
            var stopwatchState =  try  StopwatchStorage.load()
            if stopwatchState.currentButtonAction != .Pause{
                
                let currentElapsedInsecond = stopwatchState.currentDuration/1000.0
                let  newElapsedDuration =   Date().timeIntervalSince( stopwatchState.startDate.addingTimeInterval(-currentElapsedInsecond))
                
                stopwatchState.currentDuration=newElapsedDuration*1000
                
                let dictionary = stopwatchState.asDictionary
                
                return result(dictionary)
                
                
            }

            let finalStopwatchDataShared =  stopwatchState.asDictionary
            
            return result(finalStopwatchDataShared)
            
        }
        catch{
            print("Failed to Load Data")
           return result([:])
        }
        
        
    }
    private  func cancelAllNotification()async throws{
        
        
        
        let allActivities = Activity<LiveActivitiesAppAttributes>.activities
        for activity in allActivities {
            
            let finalState = activity.content.state
            let finalContent =  ActivityContent(state: finalState, staleDate:nil)
            await activity.end(finalContent, dismissalPolicy: .immediate)
            
            
        }
        
        
    }
    
    
    private func cleanUpServicesSData(){
        
        TimerStateStorage.remove()
        StopwatchStorage.remove()
        
    }
    
}

