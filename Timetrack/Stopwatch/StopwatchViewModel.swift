//
//  StopwatchViewModel.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import Foundation

class StopwatchViewModel: ObservableObject {
	@Published var stopwatches: [Stopwatch] = [Stopwatch(label: "Stopwatch 1")]
	
	init() {
		restoreAllStopwatches()
	}
	
	func addStopwatch(title: String) {
		stopwatches.append(Stopwatch(label: title))
		saveAllStopwatches()
	}
	
	func deleteStopwatch(at index: Int) {
		guard index < stopwatches.count else { return }
		stopwatches.remove(at: index)
		saveAllStopwatches()
	}
	
	func startAll() {
		stopwatches.forEach { $0.start() }
	}
	
	func stopAll() {
		stopwatches.forEach { $0.stop() }
	}
	
	func resetAll() {
		stopwatches.forEach { $0.reset() }
	}
	
	func saveAllStopwatches() {
		do {
			let data = try JSONEncoder().encode(stopwatches)
			UserDefaults.standard.set(data, forKey: "AllStopwatches")
		} catch {
			print("Failed to save all stopwatches: \(error)")
		}
	}
	
	func restoreAllStopwatches() {
		guard let data = UserDefaults.standard.data(forKey: "AllStopwatches") else { return }
		do {
			let decoded = try JSONDecoder().decode([Stopwatch].self, from: data)
			stopwatches = decoded
			stopwatches.forEach { $0.restoreState() }
		} catch {
			print("Failed to restore all stopwatches: \(error)")
		}
	}
}
