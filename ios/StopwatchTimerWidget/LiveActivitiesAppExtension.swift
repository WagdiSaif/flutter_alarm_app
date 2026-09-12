//
//  LiveActivitiesAppExtension.swift
//  Runner
//
//  Created by wagdi saif  on 16/03/1448 AH.
//
import Foundation

extension StopwatchState{
    
    
    func addLap()->StopwatchState{
        
        var currentState = self
        
        if currentState.laps.isEmpty{
            let firstLap =  Laps(previousLapElapsed: currentState.currentDuration, currentLapElapsed:currentState.currentDuration )
            
            
            currentState.laps.append(firstLap)
            
            let calculatePerviousLapElapsed=currentState.currentDuration-firstLap.currentLapElapsed
            let secondLap=Laps(previousLapElapsed: calculatePerviousLapElapsed,currentLapElapsed: currentState.currentDuration)
            

            currentState.laps.append(secondLap)
            
           return currentState
            
            
        }
        
     
        if let last=currentState.laps.last{
            
          let newcurrentLapElapsed = currentState.currentDuration
          let newpreviousLapElapsed=currentState.currentDuration-last.currentLapElapsed
            
            let newLap =  Laps(previousLapElapsed: newpreviousLapElapsed, currentLapElapsed:newcurrentLapElapsed )
            currentState.laps.append(newLap)
        }
      
        return currentState
    }
    var asDictionary:[String:Any] {
        let currentElapsedDuration = Int(self.currentDuration.rounded())
        let buttonAction = self.currentButtonAction.rawValue
        
        let laps = self.laps
        
        let lapDictionry = laps.isEmpty ? []  : laps.map{$0.asDictionary}
          return [
            "laps":lapDictionry,
            "buttonAction":buttonAction,
            "elapsedDuration": currentElapsedDuration
        ]
    }
    }


extension Dictionary where Key==String,Value==Any  {
    
    func double(for key:String)->Double{
        
        guard let value=self[key] as? NSNumber else{
            return 0
        }
        return value.doubleValue
            
        }
    
    
}
extension Laps {
    var asDictionary: [String: Int] {
        return [
            "previousLapElapsed": Int(self.previousLapElapsed.rounded()),
            "currentLapElapsed":Int(self.currentLapElapsed.rounded())
        ]
    }
}
extension Date{
    func formatRemainingDuration()->String{
        let remainingTime=self
        let totalSecond = Int(remainingTime.timeIntervalSince(Date()).rounded())
        let hours = Int(totalSecond) / 3600
        let totalSecondAfterHours=Int(totalSecond) % 3600
        let minutes = (Int(totalSecondAfterHours)) / 60
        let seconds =  (Int(totalSecondAfterHours)) % 60
        if hours>0{return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
        }
            return String(format: "%02d:%02d",  minutes, seconds)
    }
}


extension TimerState{
    
    
    var asDictionary:[String:Any]{
        return [
            "currentDuration":Int(self.currentDuration.rounded()),
            "buttonAction": self.timerButtonAction.rawValue,
          
      ]
        
    }
    
    
}
