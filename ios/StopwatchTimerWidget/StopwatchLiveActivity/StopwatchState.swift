//
//  StopwatchState.swift
//  Runner
//
//  Created by wagdi saif  on 15/03/1448 AH.
//

import Foundation

struct Laps: Codable,Equatable,Hashable {
    
    var  previousLapElapsed:Double
    var  currentLapElapsed:Double
  
    init(previousLapElapsed: Double=0, currentLapElapsed: Double=0) {
        self.previousLapElapsed = previousLapElapsed
        self.currentLapElapsed = currentLapElapsed
    }
    static func fromJson(json:[String:Any])->Laps{
        
        
        return Laps(previousLapElapsed: json.double(for:"previousLapElapsed"),currentLapElapsed:(json.double(for: "currentLapElapsed")))
        
        
    }
    func   toJson()->[String:Any]{
        
        return     ["previousLapElapsed":self.previousLapElapsed,"currentLapElapsed":self.currentLapElapsed]
        
    }
}



struct StopwatchState : Codable,Equatable,Hashable{
    
    var laps : [Laps]
    var  currentDuration:Double;
    var startDate :Date
    var currentButtonAction :StopwatchButtonAction

    init(laps: [Laps]=[], currentDuration: Double=0,startDate:Date=Date(),currentButtonAction:StopwatchButtonAction=StopwatchButtonAction.Start) {
        self.laps = laps
        self.currentDuration = currentDuration
      
        self.startDate = startDate
        self.currentButtonAction=currentButtonAction
    }
    
    func toJsonData() throws -> Data? {
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .iso8601
    
        do{
            
            let data = try  encoder.encode(self)
            
            return data
            
        }
        catch{
            print("Failed to Encode")
            return nil
        }
        
        
    }
    
  
    static func fromJsonData(_ json : Data) throws -> StopwatchState? {
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do{
            
            return  try  decoder.decode(StopwatchState.self, from:json)
        }
        catch{
            print("Failed to Encode")
            return nil
        }
        
        
    }
    
    
    
}
