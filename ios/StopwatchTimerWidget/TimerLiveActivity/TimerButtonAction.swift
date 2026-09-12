enum TimerButtonAction:String,CaseIterable,Codable {
    case Pause="Pause"
    case AddOneMinute = "AddOneMinute"
    case Resume = "Resume"
    case Reset = "Reset"
    case Unknown = "Unknown"
    
    static func byName(_ name:String) -> TimerButtonAction {
        
        let actionName=name.lowercased()
        return  (TimerButtonAction.allCases.first{$0.rawValue.lowercased()==actionName||String(describing: $0).lowercased() == actionName } ?? .Unknown)
        }
    
    var label :String{
        switch self {
        case .AddOneMinute:return "Add 1 Minute"
        case .Pause:return "Pause"
        case .Reset:return "Reset"
        case .Resume:return "Resume"
        default: return "Unknown"
          
        }
        
    }
}
