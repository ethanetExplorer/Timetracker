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
    
    @State var showControls = false
	
	var body: some View {
		NavigationStack {
            HStack {
                Spacer()
                Button(role: .destructive) {
                    if let stopwatchSet = stopwatchSets.first {
                        withAnimation {
                            stopwatchSet.stopwatches = [Stopwatch(label: "Stopwatch 1")]
                        }
                    }
                } label: {
                    Image(systemName: "trash")
                        .padding(4)
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
                    Image(systemName: "plus")
                        .padding(4)
                }
            }
            .padding()
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
                                .foregroundStyle(.red)
							}
						}
				}
			}
            HStack {
                if showControls {
                    VStack(alignment: .leading) {
                        Text("CONTROLS")
                            .foregroundStyle(.gray)
                        HStack {
                            VStack {
                                Image(systemName: "play")
                                Text("Start all")
                                    .font(.caption)
                            }
                            .padding(8)
                            VStack {
                                Image(systemName: "play")
                                Text("Stop all")
                                    .font(.caption)
                            }
                            .padding(8)
                            VStack {
                                Image(systemName: "play")
                                Text("Reset all")
                                    .font(.caption)
                            }
                            .padding(8)
                        }
                    }
                        Spacer()
                }
                Button {
                    withAnimation {
                        showControls.toggle()
                    }
                } label: {
                    Image(systemName: showControls ? "chevron.down" : "chevron.up")
                        .font(.title)
                }
                .padding(8)
            }
            .padding()
//			.toolbar {
//				Button(role: .destructive) {
//					if let stopwatchSet = stopwatchSets.first {
//						withAnimation {
//							stopwatchSet.stopwatches = [Stopwatch(label: "Stopwatch 1")]
//						}
//					}
//				} label: {
//					Label("Clear all stopwatches", systemImage: "trash")
//						.symbolEffect(.bounce.down.byLayer , value: true)
//				}
//				Button {
//					if let stopwatchSet = stopwatchSets.first {
//						let newStopwatch = Stopwatch(label: "Stopwatch \(stopwatchSet.stopwatches.count + 1)")
//						stopwatchSet.stopwatches.append(newStopwatch)
//					} else {
//						let newStopwatchSet = StopwatchSet(stopwatches: [Stopwatch()])
//						modelContext.insert(newStopwatchSet)
//					}
//				} label: {
//					Label("Add Stopwatch", systemImage: "plus")
//				}
//			}
		}
	}
}


#Preview {
	StopwatchMainView()
}
