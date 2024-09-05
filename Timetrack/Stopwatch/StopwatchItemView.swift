//
//  StopwatchItemView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import SwiftUI
import SwiftData

struct StopwatchItemView: View {
	@Bindable var stopwatch: Stopwatch
	@EnvironmentObject var settings: Settings
	let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
	
	@State var showLaps: Bool = false
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.foregroundStyle(Color("ListBGColor"))
				.onTapGesture {
					withAnimation {
						showLaps.toggle()
					}
				}
			VStack {
				HStack {
					VStack(alignment: .leading) {
						Text(String(stopwatch.label))
							.foregroundStyle(.gray)
						Text(stopwatch.elapsedTimeString)
							.font(.title)
							.monospaced(settings.fontChoice == .monospace)
					}
					.padding(.leading, 4)
					Spacer()
					if stopwatch.status != .running {
						Button {
							let impactMed = UIImpactFeedbackGenerator(style: .medium)
							impactMed.impactOccurred()
							stopwatch.start()
						} label: {
							ZStack {
								Image(systemName: "circle.fill")
									.foregroundStyle(.green.opacity(0.25))
									.font(.custom(
										"Helvetica",
										size: 48,
										relativeTo: .largeTitle))
								Image(systemName: "play.fill")
									.foregroundStyle(.green)
									.font(.title)
							}
						}
						if stopwatch.status != .unstarted {
							Button {
								let impactMed = UIImpactFeedbackGenerator(style: .heavy)
								impactMed.impactOccurred()
								stopwatch.reset()
							} label: {
								ZStack {
									Image(systemName: "circle.fill")
										.foregroundStyle(.yellow.opacity(0.25))
										.font(.custom(
											"Helvetica",
											size: 48,
											relativeTo: .largeTitle))
									Image(systemName: "arrow.trianglehead.counterclockwise")
										.foregroundStyle(.yellow)
										.font(.title)
								}
							}
						}
					} else {
						Button {
							let impactMed = UIImpactFeedbackGenerator(style: .medium)
							impactMed.impactOccurred()
								stopwatch.stop()
							
						} label: {
							ZStack {
								Image(systemName: "circle.fill")
									.foregroundStyle(.red.opacity(0.25))
									.font(.custom(
										"Helvetica",
										size: 48,
										relativeTo: .largeTitle))
								Image(systemName: "stop.fill")
									.foregroundStyle(.red)
									.font(.title)
							}
						}
						Button {
							let impactMed = UIImpactFeedbackGenerator(style: .light)
							impactMed.impactOccurred()
							if settings.expandLapsOnLap {
								showLaps = true
							}
							withAnimation {
								stopwatch.lap()
							}
							
						} label: {
							ZStack {
								Image(systemName: "circle.fill")
									.foregroundStyle(stopwatch.isRunning ? .cyan.opacity(0.25) : .gray.opacity(0.25))
									.font(.custom(
										"Helvetica",
										size: 48,
										relativeTo: .largeTitle))
								Image(systemName: "point.forward.to.point.capsulepath.fill")
									.foregroundStyle(stopwatch.isRunning ? .cyan : .gray)
									.font(.title)
							}
						}
						.disabled(!stopwatch.isRunning)
					}
					
				}
				if showLaps {
					ForEach(stopwatch.laps) { lap in
						HStack {
							Text("Lap \(lap.index)")
								.foregroundStyle(.primary.opacity(0.75))
							Spacer()
							Text(timeString(from: lap.timeElapsedSinceLastLap))
								.monospaced(settings.fontChoice == .monospace)
								.foregroundStyle(getLapTextColor(lap: lap))
							Text(timeString(from: lap.timeRunningTotal))
								.monospaced(settings.fontChoice == .monospace)
								.foregroundStyle(getLapTextColor(lap: lap))
						}
						.padding(2)
					}
				}
			}
			.padding(8)
		}
		.padding(.horizontal, 8)
		.padding(.top, 4)
		.onReceive(timer) { _ in
			if stopwatch.isRunning {
				stopwatch.updateElapsedTime()
			}
		}
	}
	func timeString(from input: TimeInterval) -> String {
		let seconds = Int(input) % 60
		let minutes = (Int(input) / 60) % 60
		let hours = Int(input) / 3600
		let milliseconds = Int((input.truncatingRemainder(dividingBy: 1)) * 100)
		
		if hours > 0 {
			//			return settings.showMillisecondsAfterHour ? String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, milliseconds) : String(format: "%02d:%02d:%02d", hours, minutes, seconds)
			return String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, milliseconds)
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
}

#Preview {
	StopwatchItemView(stopwatch: Stopwatch(label: "Stopwatch 1"))
}
