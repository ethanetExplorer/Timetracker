//
//  StopwatchApp.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import SwiftUI

@main
struct TimetrackApp: App {
	@StateObject private var settings = Settings(fontChoice: .sansSerif, largerFont: .runningTotal, showSecondaryText: true, showMillisecondsAfterHour: false, expandLapsOnLap: true)
	@StateObject private var stopwatches = StopwatchViewModel()
	@StateObject private var timers = TimerModel()
	
	var body: some Scene {
		WindowGroup {
			TabView {
				Tab("Stopwatch", systemImage: "stopwatch") {
					StopwatchesMainView()
						.environmentObject(stopwatches)
						.environmentObject(settings)
						.onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
							stopwatches.saveAllStopwatches()
						}
						.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
							stopwatches.saveAllStopwatches()
						}
				}
				
				Tab("Timer", systemImage: "timer") {
					TimersView()
						.environmentObject(settings)
						.environmentObject(timers)
				}
				
				Tab("Settings", systemImage: "gear") {
					SettingsView()
						.environmentObject(settings)
				}
			}
		}
	}
}
