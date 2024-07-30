//
//  TimerItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import Foundation

class TimerSet: ObservableObject, Codable {
	let id: UUID
	@Published var timers: [CountdownTimer]
	
	init(id: UUID = UUID(), timers: [CountdownTimer] = []) {
		self.id = id
		self.timers = timers
	}
	
	enum CodingKeys: String, CodingKey {
		case id
		case timers
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(UUID.self, forKey: .id)
		timers = try container.decode([CountdownTimer].self, forKey: .timers)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(timers, forKey: .timers)
	}
	
	func addTimer(_ timer: CountdownTimer) {
		timers.append(timer)
	}
	
	func removeTimer(_ timer: CountdownTimer) {
		timers.removeAll { $0.id == timer.id }
	}
}

class CountdownTimer: ObservableObject, Codable, Identifiable {
	let id: UUID
	@Published var label: String
	@Published var duration: Double
	@Published var remainingTime: Double
	@Published var isRunning: Bool = false
	
	private var timer: Timer?
	
	init(id: UUID = UUID(), label: String, duration: Double) {
		self.id = id
		self.label = label
		self.duration = duration
		self.remainingTime = duration
	}
	
	enum CodingKeys: String, CodingKey {
		case id
		case label
		case duration
		case remainingTime
		case isRunning
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(UUID.self, forKey: .id)
		label = try container.decode(String.self, forKey: .label)
		duration = try container.decode(Double.self, forKey: .duration)
		remainingTime = try container.decode(Double.self, forKey: .remainingTime)
		isRunning = try container.decode(Bool.self, forKey: .isRunning)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(label, forKey: .label)
		try container.encode(duration, forKey: .duration)
		try container.encode(remainingTime, forKey: .remainingTime)
		try container.encode(isRunning, forKey: .isRunning)
	}
	
	func start() {
		guard !isRunning else { return }
		isRunning = true
		timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			if self.remainingTime > 0 {
				self.remainingTime -= 0.01
				print("\(self.label) remaining time: \(self.remainingTime) seconds")
			} else {
				self.stop()
				print("\(self.label) is done!")
			}
		}
	}
	
	func stop() {
		isRunning = false
		timer?.invalidate()
		timer = nil
	}
	
	func reset() {
		stop()
		remainingTime = duration
	}
}

class TimerModel: ObservableObject {
	@Published var timerSet = TimerSet()
	
	func addTimer(label: String, duration: Double) {
		let newTimer = CountdownTimer(label: label, duration: duration)
		timerSet.addTimer(newTimer)
	}
	
	func removeTimer(byId id: UUID) {
		if let timer = timerSet.timers.first(where: { $0.id == id }) {
			timer.stop()
			timerSet.removeTimer(timer)
		}
	}
	
	func startTimer(byId id: UUID) {
		if let timer = timerSet.timers.first(where: { $0.id == id }) {
			timer.start()
		}
	}
	
	func stopTimer(byId id: UUID) {
		if let timer = timerSet.timers.first(where: { $0.id == id }) {
			timer.stop()
		}
	}
	
	func resetTimer(byId id: UUID) {
		if let timer = timerSet.timers.first(where: { $0.id == id }) {
			timer.reset()
		}
	}
	
	func listTimers() -> [CountdownTimer] {
		return timerSet.timers
	}
}
