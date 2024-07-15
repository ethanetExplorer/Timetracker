//
//  TimersView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 4/7/24.
//

import SwiftUI

struct TimersView: View {
	
	@StateObject private var timerModel = TimerModel(time: 90.5)
	@EnvironmentObject var settings: Settings
	@State private var inputTime: String = ""
	
	var body: some View {
		NavigationStack {
			VStack {
				Text(formatTime(input: String(timerModel.timeRemaining)))
					.font(.largeTitle)
					.monospaced(true)
					.padding()
				
				HStack {
					Button(action: {
						if timerModel.isRunning {
							timerModel.stop()
						} else {
							timerModel.start()
						}
					}) {
						Text(timerModel.isRunning ? "Stop" : "Start")
							.font(.title)
							.padding()
							.background(timerModel.isRunning ? Color.red : Color.green)
							.foregroundColor(.white)
							.cornerRadius(8)
					}
					
					Button(action: {
						timerModel.reset(to: Double(inputTime) ?? 0)
					}) {
						Text("Reset")
							.font(.title)
							.padding()
							.background(Color.blue)
							.foregroundColor(.white)
							.cornerRadius(8)
					}
				}
				.padding()
				
				TextField("Time", text: $inputTime)
					.keyboardType(.decimalPad)
				
				Text("Set Timer: \(Int(inputTime)) seconds")
					.padding()
			}
			.padding()
			.navigationTitle("Timer").navigationBarTitleDisplayMode(.inline)
		}
	}
	func formatTime(input: String) -> String {
		
		let convertedInput = Double(input) ?? 0.0
		
		let seconds = Int(convertedInput) % 60
		let minutes = (Int(convertedInput) / 60) % 60
		let hours = Int(convertedInput) / 3600
		let milliseconds = Int((convertedInput.truncatingRemainder(dividingBy: 1)) * 100)
		
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
}
	

#Preview {
	TimersView()
}
