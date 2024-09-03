//
//  StopwatchesMainView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 6/7/24.
//

import SwiftUI
import SwiftData

struct StopwatchMainView: View {
	@Query var stopwatchSets: [StopwatchSet] = [StopwatchSet()]
	@Environment(\.modelContext) private var modelContext
	
	var body: some View {
		NavigationStack {
			VStack {
				ForEach(stopwatchSets.first?.stopwatches ?? [Stopwatch()]) { stopwatch in
					StopwatchItemView(stopwatch: stopwatch)
				}
			}
			.navigationTitle("Stopwatches")
			.toolbar {
				Button(role: .destructive) {
					if let stopwatchSet = stopwatchSets.first {
						stopwatchSet.stopwatches = [Stopwatch()]
					}
				} label: {
					Label("Clear all stopwatches", systemImage: "trash")
				}
				Button(action: addStopwatch) {
					Label("Add Stopwatch", systemImage: "plus")
				}
			}
		}
		.onAppear() {
			if stopwatchSets.isEmpty {
				addStopwatch()
			}
		}
	}
	
	private func addStopwatch() {
		if let stopwatchSet = stopwatchSets.first {
			let newStopwatch = Stopwatch()
			stopwatchSet.stopwatches.append(newStopwatch)
		} else {
			let newStopwatchSet = StopwatchSet(stopwatches: [Stopwatch()])
			modelContext.insert(newStopwatchSet)
		}
	}
	
	private func deleteStopwatch(at offsets: IndexSet) {
		if let stopwatchSet = stopwatchSets.first {
			for index in offsets {
				let stopwatchToDelete = stopwatchSet.stopwatches[index]
				stopwatchSet.deleteStopwatch(stopwatchToDelete)
			}
		}
	}
}


#Preview {
	StopwatchMainView()
}
