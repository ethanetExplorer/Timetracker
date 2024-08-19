//
//  TimersView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import SwiftUI
import Combine

struct TimersView: View {
	
	@EnvironmentObject var settings: Settings
	@Environment(\.dismiss) var dismiss
	@ObservedObject var timerSet: TimerSet = TimerSet()
	@State var timerText = ""
	
	@State var presentCreateTimerSheet = false
	@State var showTimerCannotBeNilAlert = false
	@State var showDeleteAlert = false
	@State var provideFeedback = true
	@State var showClearAlert = false
	@State var showMoreOptionsSheet = false
	
	@FocusState private var keyboardShown: Bool
	
	var body: some View {
		NavigationStack {
			VStack {
				if !timerSet.timers.isEmpty {
					ScrollView {
						ForEach(timerSet.timers) { timer in
							if timer.id != timerSet.timers.first?.id {
								Divider()
									.padding(0)
							}
							TimerItemView(timer: timer, showDeleteAlert: $showDeleteAlert)
								.contextMenu {
									Button(role: .destructive) {
										showDeleteAlert = true
									} label: {
										Text("Delete \(timer.label)")
										Image(systemName: "trash.fill")
									}
								}
								.alert("Delete \(timer.label)", isPresented: $showDeleteAlert) {
									Button("Cancel", role: .cancel) {
										showDeleteAlert = false
									}
									Button("Delete", role: .destructive) {
										timerSet.deleteTimer(by: timer.id)
										showDeleteAlert = false
									}
								}
						}
					}
					Spacer()
				}
				if !keyboardShown || showMoreOptionsSheet == false {
					HStack {
						Button {
							timerSet.timers.append(TimerItem(label: "Timer \(timerSet.timers.count + 1)", time: 30))
							timerText = ""
						} label: {
							Text("30s")
								.padding(.horizontal, 4)
						}
						.buttonStyle(.borderedProminent)
						Button {
							timerSet.timers.append(TimerItem(label: "Timer \(timerSet.timers.count + 1)", time: 60))
							timerText = ""
						} label: {
							Text("1m")
								.padding(.horizontal, 4)
						}
						.buttonStyle(.borderedProminent)
						Button {
							timerSet.timers.append(TimerItem(label: "Timer \(timerSet.timers.count + 1)", time: 300))
							timerText = ""
						} label: {
							Text("5m")
								.padding(.horizontal, 4)
						}
						.buttonStyle(.borderedProminent)
						Button {
							timerSet.timers.append(TimerItem(label: "Timer \(timerSet.timers.count + 1)", time: 600))
							timerText = ""
						} label: {
							Text("10m")
								.padding(.horizontal, 4)
						}
						.buttonStyle(.borderedProminent)
						Button {
							showMoreOptionsSheet = true
						} label: {
							HStack {
								Image(systemName: "plus")
								Text("More")
							}
							.padding(.horizontal, 8)
						}
						.buttonStyle(.borderedProminent)
						.opacity(0.75)
					}
					.padding(.horizontal, 8)
				}
				TextField("Custom time", text: $timerText)
					.keyboardType(.decimalPad)
					.padding(.horizontal, 8)
					.padding(.vertical, 5)
					.focused($keyboardShown)
					.overlay {
						RoundedRectangle(cornerRadius: 8, style: .continuous)
							.stroke(Color.gray, lineWidth: 0.75)
							.opacity(0.25)
					}
					.customKeyboard(.timerInputBoard)
					.onCustomSubmit {
						if timerText != "" {
							timerSet.timers.append(TimerItem(label: "Timer \(timerSet.timers.count + 1)", time: processTimerText(input: timerText)))
						} else {
							dismiss()
						}
						
						timerText = ""
					}
				
					.alert("Timer must have a value", isPresented: $showTimerCannotBeNilAlert) {
						Button("OK", role: .cancel) {
							showTimerCannotBeNilAlert = false
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
			.onTapGesture {
				keyboardShown = false
			}
			.sheet(isPresented: $showMoreOptionsSheet, onDismiss: {
				showMoreOptionsSheet = false
			}) {
				TimerOptionsSheet(timerSet: timerSet)
					.presentationDetents([.medium, .large])
					.presentationBackgroundInteraction(.enabled)
					.presentationBackground(.thinMaterial)
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						showClearAlert = true
					} label: {
						Image(systemName: "xmark.circle")
							.foregroundStyle(.red)
					}
				}
			}
			
			.alert("Clear all timers?", isPresented: $showClearAlert) {
				Button("Cancel", role: .cancel) {
					showClearAlert = false
				}
				Button("Clear", role: .destructive) {
					timerSet.clearTimers()
					showClearAlert = false
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

