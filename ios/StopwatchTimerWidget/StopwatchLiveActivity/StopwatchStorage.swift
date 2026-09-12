//
//  StopwatchStorage.swift
//  MyConsoleApp
//
//  Created by wagdi saif  on 14/03/1448 AH.
//

import Foundation

enum StopwatchStorage {
    static let  sharedDefault: UserDefaults = UserDefaults(suiteName: "group.com.wagdi.alarmapp")!
    
    
    static let stopwatchStateKey :String="stopwatch_state_kay"
  
    
    static func save(_ instance:StopwatchState?)throws{
        let json = try instance?.toJsonData()
        
        guard let json = json else{
            return
            
        }
        
        
        sharedDefault.set(json, forKey: stopwatchStateKey)
    
    }
    
    static  func load() throws->StopwatchState{
        do{
            guard let json =   sharedDefault.data(forKey: stopwatchStateKey)else{
                return StopwatchState()
            }
           
            guard  let  instance =  try StopwatchState.fromJsonData(json) else{
                return StopwatchState()
             
            }
        
            return instance
        }
        catch{
            return StopwatchState()
            
        }
    }
    
    
  
    static  func remove(){
        
        sharedDefault.removeObject(forKey: stopwatchStateKey)
        
    }
    
    static  func fetchStopwtachData()throws ->[String:Any] {
        
        do{
            
            guard let data =    sharedDefault.data(forKey: stopwatchStateKey) else { return [:] }

            guard  let newData = try  JSONSerialization.jsonObject(with:data ,options: [])
                    as? [String:Any] else{
                
                return [:] }
            return newData

        }
        
        catch{
            return [:]
            
        }
    }
}
