//
//  TimerItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import Foundation

class TimerSet: Codable {
	let id = UUID()
	
	var timers: [CountdownTimer] = []
}

class CountdownTimer: Codable {
	let id = UUID()
	var label: String = "Timer"
	var duration: Double = 0.0
}
