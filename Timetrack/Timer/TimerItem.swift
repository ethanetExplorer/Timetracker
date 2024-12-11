//
//  TimerItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 2024-12-11.
//

import Foundation
import SwiftData

@Model
class TimerItem {
    @Attribute(.unique) var id: UUID = UUID()
    var startTime: Date?
    var elapsedTime: TimeInterval
    var isRunning: Bool

    init(startTime: Date? = nil, elapsedTime: TimeInterval = 0, isRunning: Bool = false) {
        self.startTime = startTime
        self.elapsedTime = elapsedTime
        self.isRunning = isRunning
    }
}
