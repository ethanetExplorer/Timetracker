//
//  StopwatchItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import Foundation
import Combine
import SwiftData

@Model
class Lap: Identifiable {
	var id = UUID()
	var index: Int
	var timeRunningTotal: TimeInterval
	var timeElapsedSinceLastLap: TimeInterval
	
	init(id: UUID = UUID(), index: Int = 0, timeRunningTotal: TimeInterval = 0, timeElapsedSinceLastLap: TimeInterval = 0) {
		self.id = id
		self.index = index
		self.timeRunningTotal = timeRunningTotal
		self.timeElapsedSinceLastLap = timeElapsedSinceLastLap
	}
}


enum StopwatchStates: String, Codable {
	case unstarted, running, paused
}

@Model
class Stopwatch {
	@Attribute(.unique) var id: UUID
	var label: String
	var startTime: Date?
	var timeLastPaused: Date?
	var elapsedTime: TimeInterval
	var elapsedTimeString: String
	var isRunning: Bool
	var laps: [Lap]
	var status: StopwatchStates
	
	init(id: UUID = UUID(), label: String = "", startTime: Date? = nil, elapsedTime: TimeInterval = 0, elapsedTimeString: String = "00:00:00", isRunning: Bool = false, laps: [Lap] = [], status: StopwatchStates = .unstarted) {
		self.id = id
		self.label = label
		self.startTime = startTime
		self.elapsedTime = elapsedTime
		self.elapsedTimeString = elapsedTimeString
		self.isRunning = isRunning
		self.laps = laps
		self.status = status
	}
	
	// Start or resume the stopwatch
	func start() {
		if status == .unstarted {
			// Start for the first time
			self.startTime = Date()
			self.status = .running
			self.isRunning = true
		} else if status == .paused {
			// Resuming from pause
			if let timeLastPaused = self.timeLastPaused {
				// Adjust the startTime to account for the paused duration
				let pauseDuration = Date.now.timeIntervalSince(timeLastPaused)
//				self.startTime! += pauseDuration
				self.elapsedTime -= pauseDuration
				self.timeLastPaused = nil
				self.status = .running
				self.isRunning = true
			}
		}
	}
	
	// Stop or pause the stopwatch
	func stop() {
		if status == .running {
			// Calculate and store the elapsed time up to the point of pausing
			self.timeLastPaused = Date() // Mark the time when the stopwatch was paused
			self.status = .paused
			self.isRunning = false
		}
	}
	
	func lap() {
		guard status == .running, let startTime = startTime else {
			return // Ensure the stopwatch is running before recording a lap
		}
		
		// Calculate the current elapsed time
		let currentElapsedTime = Date().timeIntervalSince(startTime) + self.elapsedTime
		
		// Calculate the time since the last lap
		let timeSinceLastLap: TimeInterval
		if let lastLap = laps.last {
			timeSinceLastLap = currentElapsedTime - lastLap.timeRunningTotal
		} else {
			timeSinceLastLap = currentElapsedTime // This is the first lap
		}
		
		// Create a new Lap object
		let newLap = Lap(
			index: laps.count + 1,
			timeRunningTotal: currentElapsedTime,
			timeElapsedSinceLastLap: timeSinceLastLap
		)
		
		// Add the new Lap to the laps array
		laps.append(newLap)
	}
	
	// Update the elapsed time string without accumulating extra time
	func updateElapsedTime() {
		if status == .running, let startTime = startTime {
			// Calculate the total elapsed time as the difference between now and the start time plus any previously recorded elapsed time
			let currentElapsedTime = Date().timeIntervalSince(startTime) + self.elapsedTime
			self.elapsedTimeString = formatTimeInterval(currentElapsedTime)
		} else {
			// When paused or unstarted, just format the current elapsed time
			self.elapsedTimeString = formatTimeInterval(self.elapsedTime)
		}
	}
	
	// Reset the stopwatch to its initial state
	func reset() {
		self.startTime = nil
		self.timeLastPaused = nil
		self.elapsedTime = 0
		self.elapsedTimeString = "00:00:00"
		self.isRunning = false
		self.laps = []
		self.status = .unstarted
	}
	
	// Format TimeInterval into a string with milliseconds precision
	func formatTimeInterval(_ input: TimeInterval) -> String {
		let seconds = Int(input) % 60
		let minutes = (Int(input) / 60) % 60
		let hours = Int(input) / 3600
		let milliseconds = Int((input.truncatingRemainder(dividingBy: 1)) * 100)
		
		if hours > 0 {
			//			return settings.showMillisecondsAfterHour ? String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, milliseconds) : String(format: "%02d:%02d:%02d", hours, minutes, seconds)
			return String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, milliseconds)
		} else if minutes > 0 {
			return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
		} else {
			return String(format: "00:%02d:%02d", seconds, milliseconds)
		}
	}
}

@Model
class StopwatchSet {
	@Attribute(.unique) var id: UUID
	var stopwatches: [Stopwatch] // A set of stopwatches
	
	init(id: UUID = UUID(), stopwatches: [Stopwatch] = [Stopwatch(label: "Stopwatch 1")]) {
		self.id = id
		self.stopwatches = stopwatches
	}
	
	func addStopwatch() {
		let stopwatch = Stopwatch(label: "Stopwatch \(self.stopwatches.count + 1)")
		stopwatches.append(stopwatch)
	}
	
	func deleteStopwatch(_ stopwatch: Stopwatch) {
		if let index = stopwatches.firstIndex(where: { $0.id == stopwatch.id }) {
			stopwatches.remove(at: index)
		}
	}
}
