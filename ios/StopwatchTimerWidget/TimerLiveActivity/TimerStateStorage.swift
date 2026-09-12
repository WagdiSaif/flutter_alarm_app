//
//  TimerStateStorage.swift
//  Runner
//
//  Created by wagdi saif  on 18/03/1448 AH.
//

import Foundation
enum TimerStateStorage{
    static  let  sharedDefault: UserDefaults = UserDefaults(suiteName: "group.com.wagdi.alarmapp")!
    static let timerStateKey:String = "timer_state_kay"

    static func save(_ timerState:TimerState?)throws{
        guard let data = try timerState?.toJsonData()else{
            
            return
        }

        sharedDefault.set(data, forKey:timerStateKey )

    }
    static  func remove(){
        
        sharedDefault.removeObject(forKey: timerStateKey)
        
    }
  
       static  func load()throws->TimerState{
        
        
           guard let jsonData =  sharedDefault.data(forKey: timerStateKey)  else{
            return  TimerState()
        }
        
        do{
            guard let state = try TimerState.fromJson(jsonData) else {
                
                return  TimerState()
            }
           
            return state
        }
        catch{
            return  TimerState()
        }
        
    }
}
