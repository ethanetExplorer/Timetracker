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
		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.foregroundStyle(Color("ListBGColor"))
			HStack {
				VStack(alignment: .leading) {
					Text(String(stopwatch.label))
						.foregroundStyle(.gray)
					Text(stopwatch.elapsedTimeString)
						.font(.title)
				}
				.padding(.leading, 4)
				Spacer()
				if stopwatch.status != .running {
					Button {
						stopwatch.start()
					} label: {
						Image(systemName: "play.fill")
							.foregroundStyle(.green)
							.font(.title)
					}
					.padding(.horizontal, 8)
				} else {
					Button {
						stopwatch.stop()
					} label: {
						Image(systemName: "stop.fill")
							.foregroundStyle(.red)
							.font(.title)
					}
					.padding(.horizontal, 8)
				}
				Button {
					stopwatch.reset()
				} label: {
					Image(systemName: "arrow.trianglehead.counterclockwise")
						.foregroundStyle(.cyan)
						.font(.title)
				}
				.padding(.horizontal, 8)
			}
			.padding(8)
		}
		.padding(.horizontal, 4)
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
	StopwatchItemView(stopwatch: Stopwatch(label: "Stopwatch 1"))
}
