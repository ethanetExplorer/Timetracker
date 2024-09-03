//
//  TImerItemView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 16/8/24.
//

import SwiftUI
import SwiftData

struct TimerItemView: View {
	@Bindable var timer: TimerItem
	@State private var timerUpdate: Timer?
	
	var body: some View {
		HStack {
			Text("Timer \(timer.id.uuidString.prefix(4))")
			Spacer()
			Text("\(timer.remainingTime, specifier: "%.2f") seconds")
				.font(.headline)
			
			Button(action: toggleTimer) {
				Text(timer.isRunning ? "Stop" : "Start")
					.foregroundColor(timer.isRunning ? .red : .green)
			}
		}
		.onAppear {
			startUpdatingTimer()
		}
		.onDisappear {
			stopUpdatingTimer()
		}
	}
	
	private func toggleTimer() {
		if timer.isRunning {
			timer.stop()
		} else {
			timer.start()
		}
	}
	
	private func startUpdatingTimer() {
		timerUpdate = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
			timer.updateRemainingTime()
		}
	}
	
	private func stopUpdatingTimer() {
		timerUpdate?.invalidate()
	}
}
