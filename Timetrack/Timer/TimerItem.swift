//
//  TimerItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//
//
import Foundation
import Combine
import SwiftUI

enum TimerStatus {
    case notStarted, paused, running, finished
}

class TimerItem: ObservableObject, Identifiable {
	@Published var id: UUID = UUID()
    @Published var label: String
    @Published var initialTime: TimeInterval = 0
    @Published var time: TimeInterval = 0
    @Published var status: TimerStatus = .paused
    
    private var timer: Timer?
    
    func start() {
		if time > 0 {
			self.initialTime = time
			self.status = .running
			timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
				guard let self = self else { return }
				DispatchQueue.main.async {
					self.time -= 0.01
					if self.time <= 0 {
						self.stop()
						self.status = .finished
					}
				}
			}
		} else {
			self.status = .finished
		}
    }
    
    func stop() {
        self.status = .paused
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        self.stop()
        self.time = self.initialTime
    }
	
	init(label: String, time: TimeInterval) {
		self.label = label
		self.time = time
	}
}


class TimerSet: ObservableObject {
	@Published var id = UUID()
	@Published var label = ""
	@Published var timers: [TimerItem] = []
	
	func startAll() {
		for timer in timers {
			timer.start()
		}
	}
	
	func stopAll() {
		for timer in timers {
			timer.stop()
		}
	}
	
	func resetAll() {
		for timer in timers {
			timer.reset()
		}
	}
	
	func deleteTimer(by id: UUID) {
		if let index = timers.firstIndex(where: { $0.id == id }) {
			timers.remove(at: index)
		}
	}
	
	func addTimer(label: String, time: Double) {
		let timer = TimerItem(label: label, time: time)
		timers.append(timer)
	}
	
	func clearTimers() {
		self.timers = []
	}
	
	func sequentialRun() {
		for index in (0...timers.count-1) {
			timers[index].start()
			DispatchQueue.main.asyncAfter(deadline: .now() + Double(index+1) * 0.5) {
				self.timers[index].stop()
			}
		}
	}
}
