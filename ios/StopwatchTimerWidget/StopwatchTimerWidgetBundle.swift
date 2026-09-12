//
//  StopwatchTimerWidgetBundle.swift
//  StopwatchTimerWidget
//
//  Created by wagdi saif  on 26/03/1448 AH.
//

import WidgetKit
import SwiftUI

@main
struct StopwatchTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        StopwatchTimerWidget()
        StopwatchTimerWidgetControl()
        StopwatchTimerWidgetLiveActivity()
    }
}
