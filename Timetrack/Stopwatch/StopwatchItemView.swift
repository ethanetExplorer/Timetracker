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
	
	let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("Stopwatch \(stopwatch.id.uuidString.prefix(4))")
				Text(stopwatch.elapsedTimeString)
					.font(.title)
			}
			.padding(.leading, 4)
			Spacer()
			Button {
				stopwatch.start()
			} label: {
				Image(systemName: "play.fill")
					.foregroundStyle(.green)
					.font(.largeTitle)
			}
			.padding()
			Button {
				stopwatch.stop()
			} label: {
				Image(systemName: "stop.fill")
					.foregroundStyle(.red)
					.font(.largeTitle)
			}
			.padding()
		}
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
}

#Preview {
	StopwatchItemView(stopwatch: Stopwatch())
}
