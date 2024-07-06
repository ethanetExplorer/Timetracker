//
//  StopwatchApp.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import SwiftUI

@main
struct TimetrackerApp: App {
	@StateObject private var settings = Settings(fontChoice: .sansSerif, largerFont: .runningTotal, showSecondaryText: true, showMillisecondsAfterHour: false, expandLapsOnLap: true)
	@StateObject private var stopwatches = StopwatchViewModel()
	
	var body: some Scene {
		WindowGroup {
			TabView {
				Tab("Stopwatch", systemImage: "stopwatch") {
					ContentView()
						.environmentObject(stopwatches)
						.environmentObject(settings)
						.onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
							stopwatches.saveAllStopwatches()
						}
						.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
							stopwatches.saveAllStopwatches()
						}
				}
				
				Tab("Settings", systemImage: "gear") {
					SettingsView()
						.environmentObject(settings)
				}
			}
		}
	}
}
