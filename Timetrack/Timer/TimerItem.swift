//
//  TimerItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import Foundation
import Combine
import UIKit

class CountdownTimer: ObservableObject, Identifiable, Codable {
	let id: UUID
	@Published var label: String
	@Published var duration: Double
	@Published var remainingTime: Double
	@Published var isRunning: Bool
	private var startTime: Date?
	
	private enum CodingKeys: String, CodingKey {
		case id, label, duration, remainingTime, isRunning, startTime
	}
	
	init(label: String, duration: Double, remainingTime: Double, isRunning: Bool) {
		self.id = UUID()
		self.label = label
		self.duration = duration
		self.remainingTime = remainingTime
		self.isRunning = isRunning
		self.startTime = isRunning ? Date() : nil
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(UUID.self, forKey: .id)
		label = try container.decode(String.self, forKey: .label)
		duration = try container.decode(Double.self, forKey: .duration)
		remainingTime = try container.decode(Double.self, forKey: .remainingTime)
		isRunning = try container.decode(Bool.self, forKey: .isRunning)
		startTime = try container.decode(Date?.self, forKey: .startTime)
		
		// Adjust remaining time if the timer was running
		if isRunning, let startTime = startTime {
			let elapsedTime = Date().timeIntervalSince(startTime)
			remainingTime -= elapsedTime
			if remainingTime <= 0 {
				remainingTime = 0
				isRunning = false
			}
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(label, forKey: .label)
		try container.encode(duration, forKey: .duration)
		try container.encode(remainingTime, forKey: .remainingTime)
		try container.encode(isRunning, forKey: .isRunning)
		try container.encode(startTime, forKey: .startTime)
	}
	
	func start() {
		self.startTime = Date()
		self.isRunning = true
	}
	
	func stop() {
		if let startTime = startTime {
			let elapsedTime = Date().timeIntervalSince(startTime)
			print("Stopping Timer: Elapsed Time = \(elapsedTime)")
			self.remainingTime -= elapsedTime
			if self.remainingTime < 0 {
				self.remainingTime = 0
			}
			print("Remaining Time after stopping: \(self.remainingTime)")
		}
		self.isRunning = false
		self.startTime = nil
	}
	
	func reset() {
		self.stop()
		self.remainingTime = self.duration
		self.startTime = nil
	}
}


class TimerSet: ObservableObject, Identifiable {
	let id = UUID()
	@Published var timers: [CountdownTimer] = [] {
		didSet {
			saveTimers()
		}
	}
	
	private let userDefaultsKey = "timers"
	private var cancellable: AnyCancellable?
	
	init() {
		loadTimers()
		startBackgroundTimer()
	}
	
	func startAll() {
		for timer in self.timers {
			timer.start()
		}
	}
	
	func stopAll() {
		for timer in self.timers {
			timer.stop()
		}
	}
	
	func deleteTimer(by id: UUID) {
		if let index = timers.firstIndex(where: { $0.id == id }) {
			timers.remove(at: index)
		}
	}
	
	func saveTimers() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(timers) {
			UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
			let lastCloseDate = UserDefaults.standard.double(forKey: "lastCloseDate")
			UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastCloseDate")
		}
	}
	
	func loadTimers() {
		let decoder = JSONDecoder()
		if let savedTimers = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data {
			if let decodedTimers = try? decoder.decode([CountdownTimer].self, from: savedTimers) {
				self.timers = decodedTimers
				
				// Retrieve the last close date
				let lastCloseDate = UserDefaults.standard.double(forKey: "lastCloseDate")
				let currentTime = Date().timeIntervalSince1970
				let elapsedTime = currentTime - lastCloseDate
				
				// Debugging output
				print("lastCloseDate: \(lastCloseDate)")
				print("currentTime: \(currentTime)")
				print("elapsedTime: \(elapsedTime)")
				
				// Adjust each timer based on the elapsed time
				for timer in self.timers where timer.isRunning {
					timer.remainingTime -= elapsedTime
					if timer.remainingTime <= 0 {
						timer.remainingTime = 0
						timer.isRunning = false
					}
				}
			}
		}
	}

	
	func startBackgroundTimer() {
		cancellable = Timer.publish(every: 0.01, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				self?.updateTimers()
			}
	}
	
	func updateTimers() {
		for timer in self.timers where timer.isRunning {
			timer.remainingTime -= 0.01
			if timer.remainingTime <= 0 {
				timer.remainingTime = 0
				timer.isRunning = false
			}
		}
	}
}
