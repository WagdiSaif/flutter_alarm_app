enum StopwatchButtonAction :String , CaseIterable,Codable{
    
    case Pause="Pause"
    case Lap = "Lap"
    case Reset = "Reset"
    case Start = "Start"
    case Unknown = "Unknown"
    
    
    var label: String{
        switch self {
        case .Pause:
            return "Pause"
            
        case .Start:
            
            return "Start"
        case .Lap:
            return "Lap"
        case .Reset:
            return "Reset"
       
        default:
            return "Unknown"
        
            
        }
        
        
    }
    
    static func byName(name:String)->StopwatchButtonAction
    {
        let actionName=name.lowercased()
        return   StopwatchButtonAction.allCases.first(where: {
            
            $0.rawValue.lowercased()==actionName||String(describing: $0).lowercased()==actionName
        }) ?? StopwatchButtonAction.Unknown
    }
    

    
    
}
