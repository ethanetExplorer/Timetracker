//
//  ContentView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Stopwatch")
                        .tag(0)
                    Text("Timer")
                        .tag(1)
                    Text("Settings")
                        .tag(2)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .pickerStyle(.palette)
            }
            switch(selectedTab) {
            case 0: StopwatchMainView()
                    .modelContainer(for: [Stopwatch.self, StopwatchSet.self])
            case 1: TimersMainView()
                    .modelContainer(for: TimerItem.self)
            case 2: SettingsView()
            default: SettingsView()
            }
        }
    }
}




