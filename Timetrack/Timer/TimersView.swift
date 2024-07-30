//
//  TimersView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
	@Published var timerModel = TimerModel()
	@Published var newTimerLabel: String = ""
	@Published var newTimerDuration: Double = 0.0
}

struct TimersView: View {
	
	@StateObject private var viewModel = TimerViewModel()
	@State private var showDeleteAlert = false
	
	@EnvironmentObject var settings: Settings
	@State var selectedTimer: CountdownTimer?
	
	var body: some View {
		VStack {
			HStack {
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
				} label: {
					Image(systemName: "plus.circle.fill")
						.font(.title)
				}
			}
			.padding()
			
			ForEach(viewModel.timerModel.timerSet.timers) { timer in
				TimerRow(timer: timer, viewModel: viewModel)
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
							if let timerToDelete = selectedTimer {
								viewModel.timerModel.removeTimer(byId: timer.id)
							}
							showDeleteAlert = false
						}
					}
			}
			if !viewModel.timerModel.timerSet.timers.isEmpty {
				Spacer()
			}
		}
	}
}

struct TimerRow: View {
	@ObservedObject var timer: CountdownTimer
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
