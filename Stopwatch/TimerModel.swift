//
//  TimerModel.swift
//  Stopwatch
//
//  Created by Ethan Lim on 6/7/24.
//

import Foundation
import Combine

class TimerModel: ObservableObject {
	@Published var timeRemaining: TimeInterval
	@Published var isRunning = false
	
	private var timer: AnyCancellable?
	private var endTime: Date?
	
	init(time: TimeInterval = 60) {
		self.timeRemaining = time
	}
	
	func start() {
		guard !isRunning else { return }
		isRunning = true
		endTime = Date().addingTimeInterval(timeRemaining)
		timer = Timer.publish(every: 0.01, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				self?.tick()
			}
	}
	
	func stop() {
		isRunning = false
		timer?.cancel()
		timer = nil
	}
	
	func reset(to time: TimeInterval) {
		stop()
		timeRemaining = time
	}
	
	private func tick() {
		guard let endTime = endTime else { return }
		timeRemaining = max(endTime.timeIntervalSinceNow, 0)
		if timeRemaining == 0 {
			stop()
		}
	}
}
