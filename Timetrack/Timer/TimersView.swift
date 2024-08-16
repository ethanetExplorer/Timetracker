//
//  TimersView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import SwiftUI
import Combine

class TimersViewModel: ObservableObject {
	@Published var timers: [TimerItem] = [TimerItem(label: "Timer 1", time: 60)]
}

struct TimersView: View {
	
	@EnvironmentObject var settings: Settings
	@ObservedObject var timerSet: TimerSet = TimerSet()
	@Environment(\.dismiss) var dismiss
	@State var timerText = ""
	@State var presentCreateTimerSheet = false
	@State var showAlert = false
	
	var body: some View {
		NavigationStack {
			VStack {
				ScrollView {
					ForEach(timerSet.timers) { timer in
						TimerItemView(timer: timer)
					}
				}
				Spacer()
				HStack {
					TextField("Create new timer", text: $timerText)
						.keyboardType(.decimalPad)
						.padding(.horizontal, 8)
						.padding(.vertical, 5)
						.overlay {
							RoundedRectangle(cornerRadius: 8, style: .continuous)
								.stroke(Color.gray, lineWidth: 0.75)
								.opacity(0.25)
						}
						.customKeyboard(.timerInputBoard)
						.onCustomSubmit {
							timerSet.timers.append(TimerItem(label: "Timer \(timerSet.timers.count + 1)", time: processTimerText(input: timerText)))
							timerText = ""
						}
					Button {
						timerSet.timers.append(TimerItem(label: "Timer \(timerSet.timers.count + 1)", time: 60))
						timerText = ""
					} label: {
						Text("1m")
						
					}
				}
				.padding()
				.navigationTitle("Timers")
				.navigationBarTitleDisplayMode(.inline)
				.sheet(isPresented: $presentCreateTimerSheet) {
					VStack {
						Text("Hello")
					}
				}
			}
		}
	}
	
	func processTimerText(input: String) -> Double {
		
		var totalSeconds: Double = 0
		
		let timeUnits: [(String, Double)] = [
			("h", 3600),  // 1 hour = 3600 seconds
			("m", 60),    // 1 minute = 60 seconds
			("s", 1)      // 1 second = 1 second
		]
		
		// Regular expression to match formats like 1h, 30m, 45s
		let unitRegex = try! NSRegularExpression(pattern: #"(\d+(\.\d+)?)([hms])"#, options: [])
		let matches = unitRegex.matches(in: input, options: [], range: NSRange(input.startIndex..., in: input))
		
		for match in matches {
			let valueRange = Range(match.range(at: 1), in: input)!
			let unitRange = Range(match.range(at: 3), in: input)!
			
			let value = Double(input[valueRange]) ?? 0
			let unit = String(input[unitRange])
			
			if let factor = timeUnits.first(where: { $0.0 == unit })?.1 {
				totalSeconds += value * factor
			}
		}
		
		// Handle hh:mm:ss and mm:ss formats
		let colonSeparated = input.split(separator: ":")
		if colonSeparated.count > 1 {
			var multiplier = 1.0
			for component in colonSeparated.reversed() {
				if let value = Double(component) {
					totalSeconds += value * multiplier
					multiplier *= 60
				}
			}
		}
		return totalSeconds
	}
}

struct TimerItemView: View {

	@EnvironmentObject var settings: Settings
	@ObservedObject var timer: TimerItem
	@State var showAlert = false
	
	var body: some View {
		HStack {
			VStack(alignment:.leading) {
				Text(timer.label)
					.multilineTextAlignment(.leading)
					.foregroundStyle(.gray)
				Text(formatTime(input: timer.time))
					.font(.title)
					.monospaced(settings.fontChoice == .monospace)
//					.onReceive(timer.$time) { _ in
//						// Force a UI update when `time` changes
//						self.objectWillChange.send()
//					}
			}
			Spacer()
			if timer.status == .notStarted || timer.status == .paused {
				Button {
					timer.start()
				} label: {
					actionButtonLabel(image: "play.fill", color: .green)
				}
			} else if timer.status == .finished {
				actionButtonLabel(image: "flag.pattern.checkered", color: .pink)
			} else {
				Button {
					timer.stop()
				} label: {
					actionButtonLabel(image: "stop.fill", color: .red)
				}
			}
			Button {
				timer.reset()
			} label: {
				actionButtonLabel(image: "arrow.circlepath", color: .yellow)
			}
			.contextMenu {
				Button(role: .destructive) {
					showAlert = true
				} label: {
					Text("Delete \(timer.label)")
					Image(systemName: "bin.fill")
				}
			}
			//					.alert("Delete \(timer.label)", isPresented: $showAlert) {
			//						Button("Cancel", role: .cancel) {
			//							showAlert = false
			//						}
			//						Button("Delete", role: .destructive) {
			//							timerViewModel.timers.remove(at: timer.index)
			//							showAlert = false
			//						}
			//					}
			
		}
		.padding()
	}
	
	
	func actionButtonLabel(image: String, color: Color) -> some View {
		Image(systemName: image)
			.font(.title)
			.foregroundStyle(color)
			.padding(10)
			.background(color.opacity(0.2))
			.clipShape(Circle())
	}
	
	func formatTime(input: Double) -> String {
		let seconds = Int(input) % 60
		let minutes = (Int(input) / 60) % 60
		let hours = Int(input) / 3600
		let milliseconds = Int((input.truncatingRemainder(dividingBy: 1)) * 100)
		
		if hours > 0 {
			return settings.showMillisecondsAfterHour ? String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, milliseconds) : String(format: "%02d:%02d:%02d", hours, minutes, seconds)
		} else if minutes > 0 {
			return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
		} else {
			return String(format: "00:%02d:%02d", seconds, milliseconds)
		}
	}
}
