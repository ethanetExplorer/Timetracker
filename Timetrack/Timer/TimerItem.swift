//
//  TimerItem.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import Foundation
import Combine

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
            self.status = .running
            // Assign the created timer to the `timer` property
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.time -= 0.01
                
                // Stop the timer when time reaches zero
                if self.time <= 0 {
                    self.stop()
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
	
	func sequentialRun() {
		for index in (0...timers.count-1) {
			timers[index].start()
			DispatchQueue.main.asyncAfter(deadline: .now() + Double(index+1) * 0.5) {
				self.timers[index].stop()
			}
		}
	}
}
