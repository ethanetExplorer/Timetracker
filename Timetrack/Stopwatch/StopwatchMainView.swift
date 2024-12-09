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
    
    @State var newStopwatchLabel = ""
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
                VStack(alignment: .leading) {
                    HStack {
                        Text("CONTROLS")
                            .foregroundStyle(.gray)
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
                    }
                    .padding(.top, 12)
                    .padding(.horizontal)
                    if showControls {
                        Button {
                            if let stopwatchSet = stopwatchSets.first {
                                stopwatchSet.startAll()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                    .padding(8)
                                    .background(.green.opacity(0.2))
                                    .clipShape(Circle())
                                Text("Start all")
                            }
                        }
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                        .padding(.horizontal)
                        
                        
                        Button {
                            if let stopwatchSet = stopwatchSets.first {
                                stopwatchSet.stopAll()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "stop.fill")
                                    .padding(8)
                                    .background(.red.opacity(0.2))
                                    .clipShape(Circle())
                                Text("Stop all")
                            }
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                        }
                        Button {
                            if let stopwatchSet = stopwatchSets.first {
                                stopwatchSet.resetAll()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .padding(8)
                                    .background(.teal.opacity(0.2))
                                    .clipShape(Circle())
                                Text("Reset all")
                            }
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(.teal)
                            .padding(.horizontal)
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
                                    .padding(8)
                                    .background(.gray.opacity(0.2))
                                    .clipShape(Circle())
                                Text("Clear all")
                            }
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(.gray)
                            .padding(.horizontal)
                        }
                        HStack {
                            TextField("Stopwatch \(stopwatchSets.first!.stopwatches.count + 1)", text: $newStopwatchLabel)
                                .textFieldStyle(.roundedBorder)
                            Spacer()
                            Button {
                                if let stopwatchSet = stopwatchSets.first {
                                    if newStopwatchLabel != "" {
                                        let newStopwatch = Stopwatch(label: newStopwatchLabel)
                                        stopwatchSet.stopwatches.append(newStopwatch)
                                        newStopwatchLabel = ""
                                    } else {
                                        let newStopwatch = Stopwatch(label: "Stopwatch \(stopwatchSet.stopwatches.count + 1)")
                                        stopwatchSet.stopwatches.append(newStopwatch)
                                    }
                                } else {
                                    let newStopwatchSet = StopwatchSet(stopwatches: [Stopwatch()])
                                    modelContext.insert(newStopwatchSet)
                                }
                            } label: {
                                Image(systemName: "plus")
                                .padding(8)
                                .font(.title3)
                                .foregroundStyle(.blue)
                                .background(.blue.opacity(0.2))
                                .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            .background(.gray.opacity(0.1))
        }
    }
}


#Preview {
    StopwatchMainView()
}
