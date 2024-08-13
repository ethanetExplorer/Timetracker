//
//  StopwatchItemView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import SwiftUI

struct StopwatchView: View {
	@ObservedObject var stopwatch: Stopwatch
	@EnvironmentObject var settings: Settings
	
	@State private var isExpanded = false
	
	var body: some View {
		VStack {
			HStack {
				VStack(alignment: .leading) {
					Text(stopwatch.label)
						.multilineTextAlignment(.leading)
						.foregroundStyle(.gray)
					Text(settings.largerFont == .runningTotal ? formatTime(input: stopwatch.elapsedTime) : formatTime(input: stopwatch.elapsedTime - (stopwatch.laps.last?.timeRunningTotal ?? 0)))
						.font(.title)
						.monospaced(settings.fontChoice == .monospace)
						.multilineTextAlignment(.leading)
					if settings.showSecondaryText, !stopwatch.laps.isEmpty {
						Text(settings.largerFont == .timeSinceLastLap ? formatTime(input: stopwatch.elapsedTime) : formatTime(input: stopwatch.elapsedTime - (stopwatch.laps.last?.timeRunningTotal ?? 0)))
							.font(.title3)
							.foregroundStyle(.gray)
							.monospaced(settings.fontChoice == .monospace)
							.multilineTextAlignment(.leading)
					}
				}
				Spacer()
				HStack {
					if stopwatch.isRunning {
						Button(action: stopwatch.stop) {
							actionButtonLabel(image: "stop.fill", color: .red)
						}
					} else {
						Button(action: stopwatch.start) {
							actionButtonLabel(image: "play.fill", color: .green)
						}
					}
					
					Button(action: addLap) {
						actionButtonLabel(image: "point.forward.to.point.capsulepath.fill", color: .teal)
					}
					
					if isExpanded {
						Button(action: stopwatch.reset) {
							actionButtonLabel(image: "arrow.circlepath", color: .yellow)
						}
					}
				}
			}
//			.padding(.bottom, 8)
			
			if isExpanded {
				ForEach(stopwatch.laps.reversed()) { lap in
					HStack {
						Text("Lap \(lap.index)")
							.padding(.horizontal, 4)
							.foregroundStyle(.gray)
						Spacer()
						Text(formatTime(input: lap.timeElapsedSinceLastLap))
							.padding(.horizontal, 4)
							.monospaced(settings.fontChoice == .monospace)
							.foregroundStyle(getLapTextColor(lap: lap))
						Text(formatTime(input: lap.timeRunningTotal))
							.padding(.horizontal, 4)
							.monospaced(settings.fontChoice == .monospace)
					}
				}
			}
		}
		.padding(.horizontal)
		.contentShape(Rectangle())
		.onTapGesture {
			withAnimation {
				isExpanded.toggle()
			}
		}
	}

	private func addLap() {
		stopwatch.lap()
		if settings.expandLapsOnLap {
			withAnimation {
				isExpanded = true
			}
		}
	}
	
	func formatTime(input: Double) -> String {
		let seconds = Int(input) % 60
		let minutes = (Int(input) / 60) % 60
		let hours = Int(input) / 3600
		let milliseconds = Int((input.truncatingRemainder(dividingBy: 1)) * 100)
		
		if hours > 0 {
			if settings.showMillisecondsAfterHour {
				return String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, milliseconds)
			} else {
				return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
			}
		} else if minutes > 0 {
			return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
		} else {
			return String(format: "00:%02d:%02d", seconds, milliseconds)
		}
	}
	
	func getLapTextColor(lap: Lap) -> Color {
		let bestLap = stopwatch.laps.min(by: { $0.timeElapsedSinceLastLap < $1.timeElapsedSinceLastLap })
		let worstLap = stopwatch.laps.max(by: { $0.timeElapsedSinceLastLap < $1.timeElapsedSinceLastLap })
		
		if lap.timeElapsedSinceLastLap == bestLap?.timeElapsedSinceLastLap {
			return .green
		} else if lap.timeElapsedSinceLastLap == worstLap?.timeElapsedSinceLastLap {
			return .red
		} else {
			return .primary
		}
	}
	
	func actionButtonLabel(image: String, color: Color) -> some View {
			Image(systemName: image)
				.font(.title)
				.foregroundStyle(color)
				.padding(10)
				.background(color.opacity(0.2))
				.clipShape(Circle())
	}
}
