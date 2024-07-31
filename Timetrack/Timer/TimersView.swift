//
//  TimersView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import SwiftUI
import Combine

struct TimersView: View {
	
	@ObservedObject var timerSet = TimerSet()
	@EnvironmentObject var settings: Settings
	
	@State var selectedTimer: CountdownTimer = CountdownTimer(label: "Timer Example", duration: 0, remainingTime: 0, isRunning: false)
	@State var showDeleteAlert = false
	@State var showCreateTimerAlert = false
	@State var newTimerTimeText = ""
	
	var body: some View {
		NavigationStack {
			ScrollView {
				if !timerSet.timers.isEmpty  {
					ForEach(timerSet.timers) { timer in
						TimerRowView(timer: timer, settings: _settings, selectedTimer: $selectedTimer, showDeleteAlert: $showDeleteAlert)
							.contextMenu {
								Button {
									selectedTimer = timer
									showDeleteAlert = true
								} label: {
									HStack {
										Image(systemName: "trash")
										Text("Delete timer")
									}
								}
							}
					}
				}
				Spacer()
				HStack {
					Button {
						timerSet.timers.append(CountdownTimer(label: "Timer \(timerSet.timers.count + 1)", duration: 60, remainingTime: 60, isRunning: false))
						timerSet.timers.last?.start()
					} label: {
						Text("1m")
					}
					.buttonStyle(.bordered)
					
					Button {
						timerSet.timers.append(CountdownTimer(label: "Timer \(timerSet.timers.count + 1)", duration: 300, remainingTime: 300, isRunning: false))
						timerSet.timers.last?.start()
					} label: {
						Text("5m")
					}
					.buttonStyle(.bordered)
					
					Button {
						timerSet.timers.append(CountdownTimer(label: "Timer \(timerSet.timers.count + 1)", duration: 600, remainingTime: 600, isRunning: false))
						timerSet.timers.last?.start()
					} label: {
						Text("10m")
					}
					.buttonStyle(.bordered)
					Button {
						showCreateTimerAlert = true
					} label: {
						Text("Custom")
					}
					.buttonStyle(.borderedProminent)
				}
				.padding(.vertical)
				
				if timerSet.timers.isEmpty {
					Spacer()
				}
			}
			.navigationTitle("Timers")
			.navigationBarTitleDisplayMode(.inline)
			
			.alert("Delete \(selectedTimer.label ?? "timer")", isPresented: $showDeleteAlert) {
				Button("Cancel", role: .cancel) {
					showDeleteAlert = false
				}
				Button("Delete", role: .destructive) {
					if selectedTimer != nil {
						selectedTimer.isRunning = false
						selectedTimer.remainingTime = 0
						selectedTimer.duration = 0
						timerSet.deleteTimer(by: selectedTimer.id)
					}
					showDeleteAlert = false
				}
			}
			.alert(
				Text("Create timer"),
				isPresented: $showCreateTimerAlert
			) {
				Button("Cancel", role: .cancel) {
					showCreateTimerAlert = false
				}
				Button("OK") {
					if newTimerTimeText != nil {
						timerSet.timers.append(CountdownTimer(label: "Timer \(timerSet.timers.count + 1)", duration: Double(newTimerTimeText)!, remainingTime: Double(newTimerTimeText)!, isRunning: true))
					}
				}
				TextField("Timer duration (s)", text: $newTimerTimeText)
					.keyboardType(.decimalPad)
				//				DatePicker("Timer duration", selection: $newTimerTimeText)
			} message: {
				Text("Time")
			}
		}
	}
}

struct TimerRowView: View {
	@ObservedObject var timer: CountdownTimer
	@EnvironmentObject var settings: Settings
	
	@Binding var selectedTimer: CountdownTimer
	@Binding var showDeleteAlert: Bool
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(timer.label)
					.foregroundStyle(.gray)
					.font(.subheadline)
				Text(formatTime(input: timer.remainingTime))
					.font(.largeTitle)
					.monospaced(settings.fontChoice == .monospace)
			}
			Spacer()
			HStack {
				if timer.isRunning {
					Button {
						timer.stop()
					} label: {
						actionButtonLabel(image: "stop.fill", color: .red)
					}
				} else if timer.remainingTime == 0 {
					Button {
						selectedTimer = timer
						showDeleteAlert = true
					} label: {
						actionButtonLabel(image: "trash.fill", color: .red)
					}
				} else {
					Button {
						timer.start()
					} label: {
						actionButtonLabel(image: "play.fill", color: .green)
					}
				}
				Button {
					timer.reset()
				} label: {
					actionButtonLabel(image: "arrow.circlepath", color: .yellow)
				}
			}
		}
		.padding(.horizontal)
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
	
	func actionButtonLabel(image: String, color: Color) -> some View {
		Image(systemName: image)
			.font(.title)
			.foregroundStyle(color)
			.padding(10)
			.background(color.opacity(0.2))
			.clipShape(Circle())
	}
}
