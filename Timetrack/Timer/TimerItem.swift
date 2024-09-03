//
//  TimerItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//
//
//import Foundation
//import Combine
//import SwiftUI
//
//enum TimerStatus: Codable {
//    case notStarted, paused, running, finished
//}
//
//class TimerItem: ObservableObject, Identifiable, Codable {
//	@Published var id: UUID = UUID()
//    @Published var label: String
//    @Published var time: TimeInterval = 0
//    var status: TimerStatus = .paused
//	var initialTime: TimeInterval = 0
//	var startTime: Date?
//    private var timer: Timer?
//    
//    func start() {
//		if time > 0 {
//			self.initialTime = time
//			self.status = .running
//			timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
//				guard let self = self else { return }
//				DispatchQueue.main.async {
//					self.time -= 0.01
//					if self.time <= 0 {
//						self.stop()
//						self.status = .finished
//					}
//				}
//			}
//		} else {
//			self.status = .finished
//		}
//    }
//    
//    func stop() {
//        self.status = .paused
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    func reset() {
//        self.stop()
//        self.time = self.initialTime
//    }
//	
//	enum CodingKeys: String, CodingKey {
//		case id, label, time, status, initialTime, startTime
//	}
//	
//	required init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		id = try container.decode(UUID.self, forKey: .id)
//		label = try container.decode(String.self, forKey: .label)
//		time = try container.decode(TimeInterval.self, forKey: .time)
//		status = try container.decode(TimerStatus.self, forKey: .status)
//		startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
//	}
//	
//	func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(id, forKey: .id)
//		try container.encode(label, forKey: .label)
//		try container.encode(time, forKey: .time)
//		try container.encode(status, forKey: .status)
//		try container.encode(startTime, forKey: .startTime)
//	}
//	
//	private func saveState() {
//		do {
//			let data = try JSONEncoder().encode(self)
//			UserDefaults.standard.set(data, forKey: "Timer \(id.uuidString)")
//		} catch {
//			print("Failed to save timer state: \(error)")
//		}
//	}
//	
//	func restoreState() {
//		guard let data = UserDefaults.standard.data(forKey: "Timer\(id.uuidString)") else { return }
//		do {
//			let decoded = try JSONDecoder().decode(TimerItem.self, from: data)
//			self.label = decoded.label
//			self.time = decoded.time
//			self.status = decoded.status
//			self.startTime = decoded.startTime
//			
//			if status == .running {
//				if let startTime = self.startTime {
//					// Update elapsedTime to reflect the current time
//					self.time = self.time - Date().timeIntervalSince(startTime)
//				}
//				// Restart the timer
//				timer = Timer.publish(every: 0.01, on: .main, in: .common)
//					.autoconnect()
//					.sink { [weak self] _ in
//						guard let self = self else { return }
//						if let startTime = self.startTime {
//							self.time = self.time - Date().timeIntervalSince(startTime)
//						}
//					}
//			}
//		} catch {
//			print("Failed to restore timer state: \(error)")
//		}
//	}
//	
//	
//	init(label: String, time: TimeInterval) {
//		self.label = label
//		self.time = time
//	}
//}
//
//
//class TimerSet: ObservableObject {
//	@Published var id = UUID()
//	@Published var label = ""
//	@Published var timers: [TimerItem] = []
//	
//	func startAll() {
//		for timer in timers {
//			timer.start()
//		}
//	}
//	
//	func stopAll() {
//		for timer in timers {
//			timer.stop()
//		}
//	}
//	
//	func resetAll() {
//		for timer in timers {
//			timer.reset()
//		}
//	}
//	
//	func deleteTimer(by id: UUID) {
//		if let index = timers.firstIndex(where: { $0.id == id }) {
//			timers.remove(at: index)
//		}
//	}
//	
//	func addTimer(label: String, time: Double) {
//		let timer = TimerItem(label: label, time: time)
//		timers.append(timer)
//	}
//	
//	func clearTimers() {
//		self.timers = []
//	}
//	
//	func sequentialRun() {
//		for index in (0...timers.count-1) {
//			timers[index].start()
//			DispatchQueue.main.asyncAfter(deadline: .now() + Double(index+1) * 0.5) {
//				self.timers[index].stop()
//			}
//		}
//	}
//	
//	func saveAllTimers() {
//		do {
//			let data = try JSONEncoder().encode(timers)
//			UserDefaults.standard.set(data, forKey: "AllTimers")
//		} catch {
//			print("Failed to save all stopwatches: \(error)")
//		}
//	}
//	
//	func restoreAllTimers() {
//		guard let data = UserDefaults.standard.data(forKey: "AllTimers") else { return }
//		do {
//			let decoded = try JSONDecoder().decode([TimerItem].self, from: data)
//			timers = decoded
//			timers.forEach { $0.restoreState() }
//		} catch {
//			print("Failed to restore all timers: \(error)")
//		}
//	}
//}
//
//extension TimerItem {
//	func saveStartTime() {
//		if let startTime = startTime {
//			UserDefaults.standard.set(startTime, forKey: "startTime")
//		} else {
//			UserDefaults.standard.removeObject(forKey: "startTime")
//		}
//	}
//	func fetchStartTime() -> Date? {
//		UserDefaults.standard.object(forKey: "startTime") as? Date
//	}
//}
//
//import Foundation
//import Combine
//import SwiftUI
//
//enum TimerStatus: Codable {
//	case notStarted, paused, running, finished
//}

//class TimerItem: ObservableObject, Identifiable, Codable {
//	@Published var id: UUID = UUID()
//	@Published var label: String
//	@Published var time: TimeInterval = 0
//	@Published var status: TimerStatus = .paused
//	var initialTime: TimeInterval = 0
//	var startTime: Date?
//	var timeWhenAppExited: Date?
//	private var cancellable: AnyCancellable?
//	
//	func start() {
//		if time > 0 {
//			self.initialTime = time
//			self.status = .running
//			self.startTime = Date()
//			self.cancellable = Timer.publish(every: 0.01, on: .main, in: .common)
//				.autoconnect()
//				.sink { [weak self] _ in
//					self?.updateTime()
//				}
//		} else {
//			self.status = .finished
//		}
//	}
//	
//	func stop() {
//		self.status = .paused
//		self.cancellable?.cancel()
//		self.cancellable = nil
//	}
//	
//	func reset() {
//		self.stop()
//		self.time = self.initialTime
//	}
//	
//	private func updateTime() {
//		guard let startTime = startTime else { return }
//		let elapsedTime = Date().timeIntervalSince(startTime)
//		self.time = initialTime - elapsedTime
//		
//		if self.time <= 0 {
//			self.time = 0
//			self.status = .finished
//			self.stop()
//		}
//	}
//	
//	enum CodingKeys: String, CodingKey {
//		case id, label, time, status, initialTime, startTime
//	}
//	
//	required init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		id = try container.decode(UUID.self, forKey: .id)
//		label = try container.decode(String.self, forKey: .label)
//		time = try container.decode(TimeInterval.self, forKey: .time)
//		status = try container.decode(TimerStatus.self, forKey: .status)
//		startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
//	}
//	
//	func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(id, forKey: .id)
//		try container.encode(label, forKey: .label)
//		try container.encode(time, forKey: .time)
//		try container.encode(status, forKey: .status)
//		try container.encode(startTime, forKey: .startTime)
//	}
//	
//	func saveState() {
//		do {
//			let data = try JSONEncoder().encode(self)
//			UserDefaults.standard.set(data, forKey: "Timer \(id.uuidString)")
//		} catch {
//			print("Failed to save timer state: \(error)")
//		}
//	}
//	
//	func restoreState() {
//		guard let data = UserDefaults.standard.data(forKey: "Timer \(id.uuidString)") else { return }
//		do {
//			let decoded = try JSONDecoder().decode(TimerItem.self, from: data)
//			self.label = decoded.label
//			self.time = decoded.time
//			self.status = decoded.status
//			self.startTime = decoded.startTime
//			
//			if status == .running {
//				if let startTime = self.startTime {
//					// Update elapsed time to reflect the current time
//					self.time = decoded.time - Date().timeIntervalSince(startTime)
//				}
//				// Restart the timer
//				self.start()
//			}
//		} catch {
//			print("Failed to restore timer state: \(error)")
//		}
//	}
//	
//		init(label: String, time: TimeInterval) {
//			self.label = label
//			self.time = time
//		}
//}

//class TimerItem: ObservableObject, Codable, Identifiable {
//	var id = UUID()
//	@Published var startTime: Date?
//	@Published var duration: TimeInterval
//	@Published var isRunning: Bool = false
//	@Published var remainingTime: TimeInterval = 0.0
//	
//	enum CodingKeys: String, CodingKey {
//		case id, startTime, duration, isRunning, remainingTime
//	}
//	
//	init(duration: TimeInterval) {
//		self.duration = duration
//		self.remainingTime = duration
//	}
//	
//	// Implement the encoding logic for Codable
//	func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(id, forKey: .id)
//		try container.encode(startTime, forKey: .startTime)
//		try container.encode(duration, forKey: .duration)
//		try container.encode(isRunning, forKey: .isRunning)
//		try container.encode(remainingTime, forKey: .remainingTime)
//	}
//	
//	// Implement the decoding logic for Codable
//	required init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		id = try container.decode(UUID.self, forKey: .id)
//		startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
//		duration = try container.decode(TimeInterval.self, forKey: .duration)
//		isRunning = try container.decode(Bool.self, forKey: .isRunning)
//		remainingTime = try container.decode(TimeInterval.self, forKey: .remainingTime)
//	}
//}
//
//class TimerSet: ObservableObject, Codable {
//	@Published var timers: [TimerItem] = []
//	
//	enum CodingKeys: String, CodingKey {
//		case timers
//	}
//	
//	init(timers: [TimerItem] = []) {
//		self.timers = timers
//	}
//	
//	// Encode the TimerSet object
//	func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		let encodedTimers = try timers.map { timer -> Data in
//			let encoder = JSONEncoder()
//			return try encoder.encode(timer)
//		}
//		try container.encode(encodedTimers, forKey: .timers)
//	}
//	
//	// Decode the TimerSet object
//	required init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		let encodedTimers = try container.decode([Data].self, forKey: .timers)
//		timers = try encodedTimers.map { data -> TimerItem in
//			let decoder = JSONDecoder()
//			return try decoder.decode(TimerItem.self, from: data)
//		}
//	}
//	
//	// Example of adding a timer
//	func addTimer(duration: TimeInterval) {
//		let timer = TimerItem(duration: duration)
//		timers.append(timer)
//	}
//	
//	// Save the timers to UserDefaults (or file)
//	func saveTimers() {
//		do {
//			let encoder = JSONEncoder()
//			let data = try encoder.encode(self)
//			UserDefaults.standard.set(data, forKey: "timers")
//		} catch {
//			print("Failed to save timers: \(error)")
//		}
//	}
//	
//	// Load the timers from UserDefaults (or file)
//	func loadTimers() {
//		guard let data = UserDefaults.standard.data(forKey: "timers") else { return }
//		do {
//			let decoder = JSONDecoder()
//			let timerSet = try decoder.decode(TimerSet.self, from: data)
//			self.timers = timerSet.timers
//		} catch {
//			print("Failed to load timers: \(error)")
//		}
//	}
//}
import Foundation
import SwiftData

@Model
class TimerItem {
	@Attribute(.unique) var id: UUID
	var startTime: Date?
	var duration: TimeInterval
	var isRunning: Bool
	var remainingTime: TimeInterval
	
	init(id: UUID = UUID(), startTime: Date? = nil, duration: TimeInterval, isRunning: Bool = false, remainingTime: TimeInterval) {
		self.id = id
		self.startTime = startTime
		self.duration = duration
		self.isRunning = isRunning
		self.remainingTime = remainingTime
	}
	
	// Method to start the timer
	func start() {
		self.startTime = Date()
		self.isRunning = true
	}
	
	// Method to stop the timer
	func stop() {
		self.isRunning = false
	}
	
	// Calculate the remaining time
	func updateRemainingTime() {
		guard let startTime = startTime else { return }
		let elapsedTime = Date().timeIntervalSince(startTime)
		self.remainingTime = max(self.duration - elapsedTime, 0)
		
		if self.remainingTime <= 0 {
			stop()
		}
	}
}

@Model
class TimerSet {
	@Attribute(.unique) var id: UUID
	var timers: [TimerItem]  // A set of timers
	
	init(id: UUID = UUID(), timers: [TimerItem] = []) {
		self.id = id
		self.timers = timers
	}
	
	func addTimer(duration: TimeInterval) {
		let timer = TimerItem(duration: duration, remainingTime: duration)
		timers.append(timer)
	}
	
	func deleteTimer(_ timer: TimerItem) {
		if let index = timers.firstIndex(where: { $0.id == timer.id }) {
			timers.remove(at: index)
		}
	}
}

