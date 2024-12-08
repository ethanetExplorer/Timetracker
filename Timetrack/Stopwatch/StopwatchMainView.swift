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
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("CONTROLS")
                            .foregroundStyle(.gray)
                            .padding(.top, 12)
                    }
                    if showControls {
                        Button {
                            if let stopwatchSet = stopwatchSets.first {
                                stopwatchSet.startAll()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start all")
                            }
                            .foregroundStyle(.green)
                            .fontWeight(.medium)
                            .font(.headline)
                            .padding(6)
                        }
                        Button {
                            if let stopwatchSet = stopwatchSets.first {
                                stopwatchSet.stopAll()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop all")
                            }
                            .foregroundStyle(.red)
                            .fontWeight(.medium)
                            .font(.headline)
                            .padding(6)
                        }
                        Button {
                            if let stopwatchSet = stopwatchSets.first {
                                stopwatchSet.resetAll()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset all")
                            }
                            .foregroundStyle(.teal)
                            .fontWeight(.medium)
                            .font(.headline)
                            .padding(6)
                        }
                        Button {
                            if let stopwatchSet = stopwatchSets.first {
                                withAnimation {
                                    stopwatchSet.stopwatches = [Stopwatch(label: "Stopwatch 1")]
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Clear all")
                            }
                            .foregroundStyle(.gray)
                            .fontWeight(.medium)
                            .font(.headline)
                            .padding(6)
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
                            HStack {
                                Image(systemName: "plus")
                                Text("Add stopwatch")
                            }
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                            .font(.headline)
                            .padding(6)
                        }
                    }
                }
                Spacer()
                Button {
                    withAnimation {
                        showControls.toggle()
                    }
                } label: {
                    Image(systemName: showControls ? "chevron.down" : "chevron.up")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(12)
            }
            .cornerRadius(12)
            .padding(8)
            .background(.gray.opacity(0.1))
        }
    }
}


#Preview {
    StopwatchMainView()
}
