//
//  StopwatchItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import Foundation
import Combine

struct Lap: Identifiable, Codable {
	let id = UUID()
	var index: Int
	var timeRunningTotal: TimeInterval
	var timeElapsedSinceLastLap: TimeInterval
}

class Stopwatch: ObservableObject, Identifiable, Codable {
	var id = UUID()
	
	@Published var label: String
	@Published var elapsedTime: TimeInterval = 0
	@Published var isRunning: Bool = false
	@Published var laps: [Lap] = []
	
	private var timer: AnyCancellable?
	private var startTime: Date?
	private var lastElapsedTime: TimeInterval = 0
	
	enum CodingKeys: String, CodingKey {
		case id, label, elapsedTime, isRunning, laps, lastElapsedTime, startTime
	}
	
	init(label: String = "", elapsedTime: TimeInterval = 0, isRunning: Bool = false) {
		self.label = label
		self.elapsedTime = elapsedTime
		self.isRunning = isRunning
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(UUID.self, forKey: .id)
		label = try container.decode(String.self, forKey: .label)
		elapsedTime = try container.decode(TimeInterval.self, forKey: .elapsedTime)
		isRunning = try container.decode(Bool.self, forKey: .isRunning)
		laps = try container.decode([Lap].self, forKey: .laps)
		lastElapsedTime = try container.decode(TimeInterval.self, forKey: .lastElapsedTime)
		startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(label, forKey: .label)
		try container.encode(elapsedTime, forKey: .elapsedTime)
		try container.encode(isRunning, forKey: .isRunning)
		try container.encode(laps, forKey: .laps)
		try container.encode(lastElapsedTime, forKey: .lastElapsedTime)
		try container.encode(startTime, forKey: .startTime)
	}
	
	func start() {
		guard !isRunning else { return }
		isRunning = true
		startTime = Date()
		timer = Timer.publish(every: 0.01, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				guard let self = self else { return }
				if let startTime = self.startTime {
					self.elapsedTime = self.lastElapsedTime + Date().timeIntervalSince(startTime)
				}
			}
		saveState()
	}
	
	func stop() {
		guard isRunning else { return }
		isRunning = false
		timer?.cancel()
		timer = nil
		if let startTime = self.startTime {
			lastElapsedTime += Date().timeIntervalSince(startTime)
		}
		saveState()
	}
	
	func reset() {
		elapsedTime = 0
		lastElapsedTime = 0
		laps.removeAll()
		stop()
		startTime = nil
		saveState()
	}
	
	func calculateTimeInterval(lap: Lap) -> Double {
		return elapsedTime - lap.timeRunningTotal
	}
	
	func lap() {
		let prevLap = laps.last ?? Lap(index: 0, timeRunningTotal: 0, timeElapsedSinceLastLap: 0)
		laps.append(Lap(index: laps.count + 1, timeRunningTotal: elapsedTime, timeElapsedSinceLastLap: calculateTimeInterval(lap: prevLap)))
		saveState()
	}
	
	func sortLapsByElapsedTime() {
		laps.sort { $0.timeElapsedSinceLastLap < $1.timeElapsedSinceLastLap }
	}
	
	private func saveState() {
		do {
			let data = try JSONEncoder().encode(self)
			UserDefaults.standard.set(data, forKey: "Stopwatch_\(id.uuidString)")
		} catch {
			print("Failed to save stopwatch state: \(error)")
		}
	}
	
	func restoreState() {
		guard let data = UserDefaults.standard.data(forKey: "Stopwatch_\(id.uuidString)") else { return }
		do {
			let decoded = try JSONDecoder().decode(Stopwatch.self, from: data)
			self.label = decoded.label
			self.elapsedTime = decoded.elapsedTime
			self.isRunning = decoded.isRunning
			self.laps = decoded.laps
			self.lastElapsedTime = decoded.lastElapsedTime
			self.startTime = decoded.startTime
			
			if isRunning {
				if let startTime = self.startTime {
					// Update elapsedTime to reflect the current time
					self.elapsedTime = self.lastElapsedTime + Date().timeIntervalSince(startTime)
				}
				// Restart the timer
				timer = Timer.publish(every: 0.01, on: .main, in: .common)
					.autoconnect()
					.sink { [weak self] _ in
						guard let self = self else { return }
						if let startTime = self.startTime {
							self.elapsedTime = self.lastElapsedTime + Date().timeIntervalSince(startTime)
						}
					}
			}
		} catch {
			print("Failed to restore stopwatch state: \(error)")
		}
	}
}


