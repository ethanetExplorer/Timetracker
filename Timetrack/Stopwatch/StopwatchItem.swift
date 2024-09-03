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
	
	init(id: UUID = UUID(), index: Int, timeRunningTotal: TimeInterval, timeElapsedSinceLastLap: TimeInterval) {
		self.id = id
		self.index = index
		self.timeRunningTotal = timeRunningTotal
		self.timeElapsedSinceLastLap = timeElapsedSinceLastLap
	}
}
//
//class Stopwatch: ObservableObject, Identifiable, Codable {
//	var id = UUID()
//
//	@Published var label: String
//	@Published var startTime: Date?
//	@Published var elapsedTime: TimeInterval = 0
//	@Published var isRunning: Bool = false
//	@Published var laps: [Lap] = []
//
//	private var timer: AnyCancellable?
//	private var lastElapsedTime: TimeInterval = 0
//
//	enum CodingKeys: String, CodingKey {
//		case id, label, elapsedTime, isRunning, laps, lastElapsedTime, startTime
//	}
//
//	init(label: String = "", elapsedTime: TimeInterval = 0, isRunning: Bool = false) {
//		self.label = label
//		self.elapsedTime = elapsedTime
//		self.isRunning = isRunning
//	}
//
//	required init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		id = try container.decode(UUID.self, forKey: .id)
//		label = try container.decode(String.self, forKey: .label)
//		elapsedTime = try container.decode(TimeInterval.self, forKey: .elapsedTime)
//		isRunning = try container.decode(Bool.self, forKey: .isRunning)
//		laps = try container.decode([Lap].self, forKey: .laps)
//		lastElapsedTime = try container.decode(TimeInterval.self, forKey: .lastElapsedTime)
//		startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
//	}
//
//	func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(id, forKey: .id)
//		try container.encode(label, forKey: .label)
//		try container.encode(elapsedTime, forKey: .elapsedTime)
//		try container.encode(isRunning, forKey: .isRunning)
//		try container.encode(laps, forKey: .laps)
//		try container.encode(lastElapsedTime, forKey: .lastElapsedTime)
//		try container.encode(startTime, forKey: .startTime)
//	}
//
//	func start() {
//		guard !isRunning else { return }
//		isRunning = true
//		startTime = Date()
//		timer = Timer.publish(every: 0.01, on: .main, in: .common)
//			.autoconnect()
//			.sink { [weak self] _ in
//				guard let self = self else { return }
//				if let startTime = self.startTime {
//					self.elapsedTime = self.lastElapsedTime + Date().timeIntervalSince(startTime)
//				}
//			}
//		saveState()
//	}
//
//	func stop() {
//		guard isRunning else { return }
//		isRunning = false
//		timer?.cancel()
//		timer = nil
//		if let startTime = self.startTime {
//			lastElapsedTime += Date().timeIntervalSince(startTime)
//		}
//		saveState()
//	}
//
//	func reset() {
//		elapsedTime = 0
//		lastElapsedTime = 0
//		laps.removeAll()
//		stop()
//		startTime = nil
//		saveState()
//	}
//
//	func calculateTimeInterval(lap: Lap) -> Double {
//		return elapsedTime - lap.timeRunningTotal
//	}
//
//	func lap() {
//		let prevLap = laps.last ?? Lap(index: 0, timeRunningTotal: 0, timeElapsedSinceLastLap: 0)
//		laps.append(Lap(index: laps.count + 1, timeRunningTotal: elapsedTime, timeElapsedSinceLastLap: calculateTimeInterval(lap: prevLap)))
//		saveState()
//	}
//
//	func sortLapsByElapsedTime() {
//		laps.sort { $0.timeElapsedSinceLastLap < $1.timeElapsedSinceLastLap }
//	}
//
//	private func saveState() {
//		do {
//			let data = try JSONEncoder().encode(self)
//			UserDefaults.standard.set(data, forKey: "Stopwatch_\(id.uuidString)")
//		} catch {
//			print("Failed to save stopwatch state: \(error)")
//		}
//	}
//
//	func restoreState() {
//		guard let data = UserDefaults.standard.data(forKey: "Stopwatch_\(id.uuidString)") else { return }
//		do {
//			let decoded = try JSONDecoder().decode(Stopwatch.self, from: data)
//			self.label = decoded.label
//			self.elapsedTime = decoded.elapsedTime
//			self.isRunning = decoded.isRunning
//			self.laps = decoded.laps
//			self.lastElapsedTime = decoded.lastElapsedTime
//			self.startTime = decoded.startTime
//
//			if isRunning {
//				if let startTime = self.startTime {
//					// Update elapsedTime to reflect the current time
//					self.elapsedTime = self.lastElapsedTime + Date().timeIntervalSince(startTime)
//				}
//				// Restart the timer
//				timer = Timer.publish(every: 0.01, on: .main, in: .common)
//					.autoconnect()
//					.sink { [weak self] _ in
//						guard let self = self else { return }
//						if let startTime = self.startTime {
//							self.elapsedTime = self.lastElapsedTime + Date().timeIntervalSince(startTime)
//						}
//					}
//			}
//		} catch {
//			print("Failed to restore stopwatch state: \(error)")
//		}
//	}
//}

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
		self.status = .unstarted
	}
	
	func lap() {
		let prevLap = laps.last ?? Lap(index: 0, timeRunningTotal: 0, timeElapsedSinceLastLap: 0)
		laps.append(Lap(index: laps.count + 1, timeRunningTotal: elapsedTime, timeElapsedSinceLastLap: calculateTimeInterval(lap: prevLap)))
	}
	
	func sortLapsByElapsedTime() {
		laps.sort { $0.timeElapsedSinceLastLap < $1.timeElapsedSinceLastLap }
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
	
	func calculateTimeInterval(lap: Lap) -> Double {
		return elapsedTime - lap.timeRunningTotal
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
