//
//  TimerState.swift
//  Runner
//
//  Created by wagdi saif  on 18/03/1448 AH.
//
import Foundation
struct TimerState:Codable,Equatable,Hashable{
    
    var currentDuration:Double
    var startDate:Date
    var timerButtonAction: TimerButtonAction
    
    init(currentDuration: Double=0, startDate: Date=Date(), timerButtonAction: TimerButtonAction=TimerButtonAction.Unknown) {
        self.currentDuration = currentDuration
        self.startDate = startDate
        self.timerButtonAction = timerButtonAction
    }
    
    static func fromJson(_ json:Data)throws->TimerState?{
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    
        
        do{
            
            let object =   try decoder.decode(self, from:json)
            
            return object
        }
        
        catch{
            return   nil
        }
        
    }
    
    func toJsonData()throws->Data?{
        
        let encoder=JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
     
        
        
        do{
            let result =  try  encoder.encode(self)
            
            return result
        }
        
        catch{
            
            return nil
        }
    }
    }


