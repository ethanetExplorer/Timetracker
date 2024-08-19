//
//  TimerOptionsSheet.swift
//  Stopwatch
//
//  Created by Ethan Lim on 17/8/24.
//

import SwiftUI

struct TimerOption: Identifiable {
	var id = UUID()
	
	var label: String
	var duration: TimeInterval
}

struct TimerOptionsSet: Identifiable {
	var id = UUID()
	
	var label: String
	var timers: [TimerOption]
}

struct TimerOptionsSheet: View {
	
	@ObservedObject var timerSet: TimerSet
	
	@State var showAddTimerOptionSheet = false
	@State var showAddTimeOptionsSetSheet = false
	
	@State var timerOptions: [TimerOption] = [
		TimerOption(label: "30s", duration: 30),
		TimerOption(label: "1m", duration: 60),
		TimerOption(label: "5m", duration: 300),
		TimerOption(label: "10m", duration: 600),
		TimerOption(label: "15m", duration: 900),
		TimerOption(label: "20m", duration: 1200),
		TimerOption(label: "30m", duration: 1800),
		TimerOption(label: "45m", duration: 2700),
		TimerOption(label: "1h", duration: 3600),
	]
	
	
	@State var timerSetOptions: [TimerOptionsSet] = [
		TimerOptionsSet(label: "Pomodoro (Example)", timers: [TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest (Extended)", duration: 1200)]
					   ),
		TimerOptionsSet(label: "Pomodoro (Example)", timers: [TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest (Extended)", duration: 1200)]
					   ),
		TimerOptionsSet(label: "Pomodoro (Example)", timers: [TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest (Extended)", duration: 1200)]
					   ),
		TimerOptionsSet(label: "Pomodoro (Example)", timers: [TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest", duration: 300),
															  TimerOption(label: "Work", duration: 1500),
															  TimerOption(label: "Rest (Extended)", duration: 1200)]
					   )
	]
	var body: some View {
		NavigationStack {
			VStack(alignment: .leading) {
				Text("Timers")
					.padding(.top, 20)
					.bold()
					.font(.title)
					.multilineTextAlignment(.leading)
				ScrollView(.horizontal) {
					HStack {
						ForEach(timerOptions) { option in
							Button {
								timerSet.timers.append(TimerItem(label: "Timer \(timerSet.timers.count + 1)", time: option.duration))
							} label: {
								Text(option.label)
									.font(.title2)
									.padding()
									.foregroundStyle(Color("TextColor"))
									.background(getBackgroundColor(number: option.duration))
									.clipShape(.circle)
							}
						}
						
						
						Button {
							showAddTimerOptionSheet = true
						} label: {
							Image(systemName: "plus")
								.font(.title2)
								.padding()
								.foregroundStyle(Color("TextColor"))
								.background(.accent)
								.clipShape(.circle)
						}
					}
				}
				.scrollIndicators(ScrollIndicatorVisibility.visible)
				Text("Timer Sets")
					.padding(.top, 20)
					.bold()
					.font(.title)
					.multilineTextAlignment(.leading)
				Text("Note that setting a timer set resets your timers.")
					.foregroundStyle(.gray)
				ScrollView {
					VStack {
						ForEach(timerSetOptions) { option in
							Button {
								timerSet.clearTimers()
								for timer in option.timers {
									timerSet.addTimer(label: timer.label, time: timer.duration)
								}
							} label: {
								VStack {
									LazyVStack {
										ForEach(option.timers) { timer in
											Text(formatTime(input: timer.duration))

										}
									}
									.background(.accent)
									Text(option.label)
								}
								.padding(4)
								.foregroundStyle(Color("TextColor"))
							}
						}
					}
				}
				.scrollIndicators(ScrollIndicatorVisibility.visible)
				Spacer()
			}
			.padding(.horizontal)
		}
	}
	
	func getBackgroundColor(number: Double) -> Color {
		if number <= 300 {
			return .blue
		} else if number <= 1200 {
			return .teal
		} else if number <= 3600 {
			return .green
		} else {
			return .clear
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
	
	func formatTime(input: Double) -> String {
		let seconds = Int(input) % 60
		let minutes = (Int(input) / 60) % 60
		let hours = Int(input) / 3600
		
		if hours > 0 {
			return String(format: "%02dh:%02dm", hours, minutes)
		} else  {
			return String(format: "%02dm:%02ds", minutes, seconds)
		}
	}
}
