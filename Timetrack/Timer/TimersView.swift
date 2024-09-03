//
//  TimersView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import SwiftUI
import SwiftData

struct TimersView: View {
	@Query var timerSets: [TimerSet]
	@Environment(\.modelContext) private var modelContext
	
	var body: some View {
		NavigationView {
			List {
				ForEach(timerSets.first?.timers ?? []) { timer in
					TimerItemView(timer: timer)
				}
				.onDelete(perform: deleteTimer)
			}
			.navigationTitle("Timers")
			.toolbar {
				Button(action: addTimer) {
					Label("Add Timer", systemImage: "plus")
				}
			}
		}
	}
	
	private func addTimer() {
		if let timerSet = timerSets.first {
			let newTimer = TimerItem(duration: 60.0, remainingTime: 60.0)
			timerSet.timers.append(newTimer)
		} else {
			let newTimerSet = TimerSet(timers: [TimerItem(duration: 60.0, remainingTime: 60.0)])
			modelContext.insert(newTimerSet)
		}
	}
	
	private func deleteTimer(at offsets: IndexSet) {
		if let timerSet = timerSets.first {
			for index in offsets {
				let timerToDelete = timerSet.timers[index]
				timerSet.deleteTimer(timerToDelete)
			}
		}
	}
}
