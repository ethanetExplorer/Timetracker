//
//  TimersView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import SwiftUI
import Combine

<<<<<<< HEAD
//class TimerViewModel: ObservableObject {
//	@Published var timerModel = TimerModel()
//	@Published var newTimerLabel: String = ""
//	@Published var newTimerDuration: Double = 0.0
//}

struct TimersView: View {
	
	@EnvironmentObject var timerModel: TimerModel
	@State var newTimerLabel: String = ""
	@State var newTimerDuration: Double = 0.0
	
	@State private var showDeleteAlert = false
	@State var timeAlert = false
=======
class TimerViewModel: ObservableObject {
	@Published var timerModel = TimerModel()
	@Published var newTimerLabel: String = ""
	@Published var newTimerDuration: Double = 0.0
}

struct TimersView: View {
	
	@StateObject private var viewModel = TimerViewModel()
	@State private var showDeleteAlert = false
	
>>>>>>> main
	@EnvironmentObject var settings: Settings
	@State var selectedTimer: CountdownTimer?
	
	var body: some View {
		VStack {
			HStack {
<<<<<<< HEAD
				TextField("Timer \(timerModel.timerSet.timers.count + 1)", text: $newTimerLabel)
					.textFieldStyle(RoundedBorderTextFieldStyle())
				TextField("Duration (seconds)", value: $newTimerDuration, formatter: NumberFormatter())
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.keyboardType(.decimalPad)
				Button {
					if newTimerLabel == "" {
						timerModel.addTimer(label: "Timer \(timerModel.timerSet.timers.count + 1)", duration: newTimerDuration)
					} else {
						timerModel.addTimer(label: newTimerLabel, duration: newTimerDuration)
					}
					newTimerLabel = ""
					newTimerDuration = 0.0
=======
				TextField("Timer \(viewModel.timerModel.timerSet.timers.count + 1)", text: $viewModel.newTimerLabel)
					.textFieldStyle(RoundedBorderTextFieldStyle())
				TextField("Duration (seconds)", value: $viewModel.newTimerDuration, formatter: NumberFormatter())
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.keyboardType(.decimalPad)
				Button {
					
					if viewModel.newTimerLabel == "" {
						viewModel.timerModel.addTimer(label: "Timer \(viewModel.timerModel.timerSet.timers.count + 1)", duration: viewModel.newTimerDuration)
					} else {
						viewModel.timerModel.addTimer(label: viewModel.newTimerLabel, duration: viewModel.newTimerDuration)
					}
					viewModel.newTimerLabel = ""
					viewModel.newTimerDuration = 0.0
>>>>>>> main
				} label: {
					Image(systemName: "plus.circle.fill")
						.font(.title)
				}
			}
			.padding()
			
<<<<<<< HEAD
			ForEach(timerModel.timerSet.timers) { timer in
				TimerRow(timer: timer)
					.id(timer.id)
=======
			ForEach(viewModel.timerModel.timerSet.timers) { timer in
				TimerRow(timer: timer, viewModel: viewModel)
>>>>>>> main
					.contextMenu {
						Button {
							selectedTimer = timer
							showDeleteAlert = true
						} label: {
							HStack {
								Image(systemName: "trash")
								Text("Delete \(timer.label)")
							}
						}
					}
					.alert("Delete \(selectedTimer?.label ?? "timer")", isPresented: $showDeleteAlert) {
						Button("Cancel", role: .cancel) {
							showDeleteAlert = false
						}
						Button("Delete", role: .destructive) {
<<<<<<< HEAD
							if let selectedTimer {
								timerModel.removeTimer(byId: timer.id)
=======
							if let timerToDelete = selectedTimer {
								viewModel.timerModel.removeTimer(byId: timer.id)
>>>>>>> main
							}
							showDeleteAlert = false
						}
					}
			}
<<<<<<< HEAD
			if !timerModel.timerSet.timers.isEmpty {
				Spacer()
			} else {
				HStack {
					Button {
						timerModel.addTimer(label: "Timer", duration: 60)
//						timerModel.startTimer(byId: timerModel.timerSet.timers[timerModel.timerSet.timers.count-1].id)
					} label: {
						Text("1m")
							.font(.title)
							.padding(4)
							.background(.gray)
							.clipShape(RoundedRectangle)
					}
					.padding()
					Button {
						timerModel.addTimer(label: "Timer", duration: 300)
//						timerModel.startTimer(byId: timerModel.timerSet.timers[timerModel.timerSet.timers.count-1].id)
					} label: {
						Text("5m")
							.font(.title)
							.padding(4)
							.background(.gray)
							.clipShape(RoundedRectangle)
					}
					.padding()
					Button {
						timerModel.addTimer(label: "Timer", duration: 600)
//						timerModel.startTimer(byId: timerModel.timerSet.timers[timerModel.timerSet.timers.count-1].id)
					} label: {
						Text("10m")
							.font(.title)
							.padding(4)
							.background(.gray)
							.clipShape(RoundedRectangle)
					}
					.padding()
				}
=======
			if !viewModel.timerModel.timerSet.timers.isEmpty {
				Spacer()
>>>>>>> main
			}
		}
	}
}

struct TimerRow: View {
	@ObservedObject var timer: CountdownTimer
<<<<<<< HEAD
	@EnvironmentObject var settings: Settings
	var body: some View {
		
		VStack {
			HStack {
				VStack(alignment: .leading) {
					Text(timer.label)
						.multilineTextAlignment(.leading)
						.foregroundStyle(.gray)
					Text(formatTime(input: timer.remainingTime))
						.font(.title)
						.monospaced(settings.fontChoice == .monospace)
						.multilineTextAlignment(.leading)
				}
				Spacer()
				
				if timer.isRunning {
					Button(action: { timer.stop() }) {
						actionButtonLabel(image: "stop.fill", color: .red)
					}
				} else {
					Button(action: { timer.start() }) {
						actionButtonLabel(image: "play.fill", color: .green)
					}
				}
				Button(action: { timer.start() }) {
					actionButtonLabel(image: "arrow.circlepath", color: .yellow)
				}
			}
			.padding(.horizontal)
			Divider()
				.padding(.horizontal)
		}
=======
	var viewModel: TimerViewModel
	@EnvironmentObject var settings: Settings
	var body: some View {
		
		
		HStack {
			VStack(alignment: .leading) {
				Text(timer.label)
					.multilineTextAlignment(.leading)
					.foregroundStyle(.gray)
				Text(formatTime(input: timer.remainingTime))
					.font(.title)
					.monospaced(settings.fontChoice == .monospace)
					.multilineTextAlignment(.leading)
			}
			Spacer()
			
			if timer.isRunning {
				Button(action: { viewModel.timerModel.stopTimer(byId: timer.id) }) {
					actionButtonLabel(image: "stop.fill", color: .red)
				}
			} else {
				Button(action: { viewModel.timerModel.startTimer(byId: timer.id) }) {
					actionButtonLabel(image: "play.fill", color: .green)
				}
			}
			Button(action: { viewModel.timerModel.resetTimer(byId: timer.id) }) {
				actionButtonLabel(image: "arrow.circlepath", color: .yellow)
			}
		}
		.padding()
>>>>>>> main
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

extension TimerModel {
	func removeTimer(by timer: CountdownTimer) {
		removeTimer(byId: timer.id)
	}
}
