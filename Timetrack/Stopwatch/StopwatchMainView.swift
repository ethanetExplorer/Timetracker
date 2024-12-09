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
                                    .padding(8)
                                    .background(.green.opacity(0.2))
                                    .clipShape(Circle())
                                Text("Start all")
                            }
                        }
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
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
                                    .padding(8)
                                    .background(.teal.opacity(0.2))
                                    .clipShape(Circle())
                                Text("Reset all")
                            }
                            .font(.headline)
                            .fontWeight(.medium)
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
                                    .padding(8)
                                    .background(.gray.opacity(0.2))
                                    .clipShape(Circle())
                                Text("Clear all")
                            }
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(.gray)
                            .fontWeight(.medium)
                            .font(.headline)
                            .padding(6)
                        }
                        HStack {
                            TextField("Stopwatch \(stopwatchSets.first?.stopwatches.count ?? 0)", text: $newStopwatchLabel)
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
                                .foregroundStyle(.blue)
                                .background(.blue.opacity(0.2))
                                .clipShape(Circle())
                                .font(.headline)
                                .fontWeight(.medium)
                            }
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
