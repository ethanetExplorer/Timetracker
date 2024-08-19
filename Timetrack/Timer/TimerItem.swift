//
//  TimerItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import Foundation
import Combine
import SwiftUI

//enum TimerStatus {
//    case notStarted, paused, running, finished
//}
//
//class TimerItem: ObservableObject, Identifiable {
//	@Published var id: UUID = UUID()
//    @Published var label: String
//    @Published var initialTime: TimeInterval = 0
//    @Published var time: TimeInterval = 0
//    @Published var status: TimerStatus = .paused
//    
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
//}

enum TimerStatus: String, Codable {
	case notStarted, paused, running, finished
}

class TimerItem: ObservableObject, Identifiable, Codable {
	@Published var id: UUID
	@Published var label: String
	@Published var initialTime: TimeInterval
	@Published var time: TimeInterval
	@Published var status: TimerStatus
	
	private var timer: Timer?
	
	enum CodingKeys: String, CodingKey {
		case id, label, initialTime, time, status
	}
	
	init(label: String, time: TimeInterval) {
		self.id = UUID()
		self.label = label
		self.time = time
		self.initialTime = time
		self.status = .notStarted
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.label = try container.decode(String.self, forKey: .label)
		self.initialTime = try container.decode(TimeInterval.self, forKey: .initialTime)
		self.time = try container.decode(TimeInterval.self, forKey: .time)
		self.status = try container.decode(TimerStatus.self, forKey: .status)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(label, forKey: .label)
		try container.encode(initialTime, forKey: .initialTime)
		try container.encode(time, forKey: .time)
		try container.encode(status, forKey: .status)
	}
	
	func start() {
		if status != .running {
			status = .running
			UserDefaults.standard.set(Date(), forKey: "\(id)-startTime")
			timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
				guard let self = self else { return }
				self.time -= 0.01
				if self.time <= 0 {
					self.stop()
					self.status = .finished
				}
			}
		}
		save()  // Save the state when starting the timer
	}
	
	func stop() {
		status = .paused
		timer?.invalidate()
		timer = nil
		UserDefaults.standard.removeObject(forKey: "\(id)-startTime")
		save()  // Save the state when stopping the timer
	}
	
	func reset() {
		stop()
		time = initialTime
		save()  // Save the state when resetting the timer
	}
	
	// Save method to persist the TimerItem state
	func save() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(self) {
			UserDefaults.standard.set(encoded, forKey: id.uuidString)
			print("Saved TimerItem with ID \(id)")
		} else {
			print("Failed to encode TimerItem with ID \(id)")
		}
	}
	
	// Static load method to retrieve a TimerItem by its UUID
	static func load(id: UUID) -> TimerItem? {
		if let savedData = UserDefaults.standard.data(forKey: id.uuidString) {
			let decoder = JSONDecoder()
			if let loadedTimer = try? decoder.decode(TimerItem.self, from: savedData) {
				if loadedTimer.status == .running, let startTime = UserDefaults.standard.object(forKey: "\(loadedTimer.id)-startTime") as? Date {
					let elapsedTime = Date().timeIntervalSince(startTime)
					loadedTimer.time -= elapsedTime
					if loadedTimer.time > 0 {
						loadedTimer.start()  // Resume the timer
					} else {
						loadedTimer.status = .finished
					}
				}
				print("Loaded TimerItem with ID \(id)")
				return loadedTimer
			} else {
				print("Failed to decode TimerItem with ID \(id)")
			}
		} else {
			print("No saved data found for TimerItem with ID \(id)")
		}
		return nil
	}
}

class TimerSet: ObservableObject, Codable {
	@Published var timers: [TimerItem] = []
	
	enum CodingKeys: String, CodingKey {
		case timers
	}
	
	init() {}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.timers = try container.decode([TimerItem].self, forKey: .timers)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(timers, forKey: .timers)
	}
	
	func addTimer(label: String, time: TimeInterval) {
		let timer = TimerItem(label: label, time: time)
		timers.append(timer)
		save()
	}
	
	func deleteTimer(by id: UUID) {
		if let index = timers.firstIndex(where: { $0.id == id }) {
			timers.remove(at: index)
			UserDefaults.standard.removeObject(forKey: id.uuidString)
			save()
		}
	}
	
	func save() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(self) {
			UserDefaults.standard.set(encoded, forKey: "timerSet")
		}
	}
	
	static func load() -> TimerSet {
		if let savedData = UserDefaults.standard.data(forKey: "timerSet") {
			let decoder = JSONDecoder()
			if let loadedSet = try? decoder.decode(TimerSet.self, from: savedData) {
				for timer in loadedSet.timers {
					if timer.status == .running {
						if let startTime = UserDefaults.standard.object(forKey: "\(timer.id)-startTime") as? Date {
							let elapsedTime = Date().timeIntervalSince(startTime)
							timer.time -= elapsedTime
							timer.start()
						}
					}
				}
				return loadedSet
			}
		}
		return TimerSet()
	}
}

class TimersViewModel: ObservableObject {
	@Published var timers: [TimerItem] = []
	
	func addTimer(label: String, time: TimeInterval) {
		let timer = TimerItem(label: label, time: time)
		timers.append(timer)
		timer.save()
	}
	
	func deleteTimer(by id: UUID) {
		if let index = timers.firstIndex(where: { $0.id == id }) {
			timers.remove(at: index)
			UserDefaults.standard.removeObject(forKey: id.uuidString)
		}
	}
	
	func saveTimers() {
		for timer in timers {
			timer.save()
		}
	}
	
	func loadTimers() {
		let savedTimerIds = UserDefaults.standard.dictionaryRepresentation().keys.filter { UUID(uuidString: $0) != nil }
		for timerId in savedTimerIds {
			if let timerUUID = UUID(uuidString: timerId), let timer = TimerItem.load(id: timerUUID) {
				timers.append(timer)
				if timer.status == .running {
					// Calculate time passed since the app was closed
					if let startTime = UserDefaults.standard.object(forKey: "\(timer.id)-startTime") as? Date {
						let elapsedTime = Date().timeIntervalSince(startTime)
						timer.time -= elapsedTime
						timer.start()
					}
				}
			}
		}
	}
}
