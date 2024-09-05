//
//  StopwatchesMainView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 6/7/24.
//

import SwiftUI
import SwiftData

struct StopwatchMainView: View {
	@Query var stopwatchSets: [StopwatchSet] = [StopwatchSet(stopwatches: [Stopwatch(label: "Stopwatch")])]
	@EnvironmentObject var settings: Settings
	@Environment(\.modelContext) private var modelContext
	
	var body: some View {
		NavigationStack {
			ScrollView {
				ForEach(stopwatchSets.first?.stopwatches ?? [Stopwatch(label: "SStopwatch")]) { stopwatch in
					StopwatchItemView(stopwatch: stopwatch)
						.contextMenu {
							Button(role: .destructive) {
								stopwatchSets.first?.deleteStopwatch(stopwatch)
							} label: {
								HStack {
									Text("Delete stopwatch")
									Image(systemName: "trash")
								}
							}
						}
				}
			}
			.navigationTitle("Stopwatch")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				Button(role: .destructive) {
					if let stopwatchSet = stopwatchSets.first {
						withAnimation {
							stopwatchSet.stopwatches = [Stopwatch(label: "Stopwatch 1")]
						}
					}
				} label: {
					Label("Clear all stopwatches", systemImage: "trash")
						.symbolEffect(.bounce.down.byLayer , value: true)
				}
				Button {
					if let stopwatchSet = stopwatchSets.first {
						let newStopwatch = Stopwatch(label: "Stopwatch \(stopwatchSet.stopwatches.count + 1)")
						stopwatchSet.stopwatches.append(newStopwatch)
					} else {
						let newStopwatchSet = StopwatchSet(stopwatches: [Stopwatch()])
						modelContext.insert(newStopwatchSet)
					}
				} label: {
					Label("Add Stopwatch", systemImage: "plus")
				}
			}
		}
	}
}


#Preview {
	StopwatchMainView()
}
