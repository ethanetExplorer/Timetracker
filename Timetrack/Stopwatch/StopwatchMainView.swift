//
//  StopwatchesMainView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 6/7/24.
//

import SwiftUI

struct StopwatchesMainView: View {
	
	@EnvironmentObject var viewModel: StopwatchViewModel
	@EnvironmentObject var settingsConfiguration: Settings
	
	@State var newStopwatchLabel: String = ""
	@State var showingRenameAlert = false
	@State var renameText = ""
	@State var showDeleteAlert = false
	@State var showClearAlert = false
	@State var selectedStopwatch: Stopwatch?
	@State var showTimeAddingAlert = false
	@State var timeValue: Double = 0
	
	var body: some View {
		NavigationStack {
			VStack {
				if viewModel.stopwatches.isEmpty {
					VStack {
						Spacer()
						TextField("Title", text: $newStopwatchLabel)
							.padding(.horizontal, 8)
							.padding(.vertical, 4)
							.overlay {
								RoundedRectangle(cornerRadius: 8, style: .continuous)
									.stroke(Color.gray, lineWidth: 1)
									.opacity(0.25)
							}
						Button {
							if newStopwatchLabel.isEmpty {
								viewModel.addStopwatch(title: "Stopwatch \(viewModel.stopwatches.count + 1)")
							} else {
								viewModel.addStopwatch(title: newStopwatchLabel)
							}
							newStopwatchLabel = ""
						} label: {
							HStack {
								Text("Create a stopwatch")
									.fontWeight(.medium)
								Image(systemName: "plus.circle.fill")
									.font(.title3)
							}
							.padding(4)
						}
						.buttonStyle(.borderedProminent)
						.padding()
						Spacer()
					}
					.padding()
				} else {
					ScrollView {
						ForEach(viewModel.stopwatches) { stopwatch in
							if stopwatch.id != viewModel.stopwatches.first?.id {
								Divider().padding(.horizontal, 12)
							}
							StopwatchView(stopwatch: stopwatch)
								.contextMenu {
									Button {
										selectedStopwatch = stopwatch
										renameText = stopwatch.label
										showingRenameAlert = true
									} label: {
										HStack {
											Image(systemName: "square.and.pencil")
											Text("Rename")
										}
									}
									Button(role: .destructive) {
										selectedStopwatch = stopwatch
										showDeleteAlert = true
									} label: {
										HStack {
											Image(systemName: "trash")
											Text("Delete \(stopwatch.label)")
										}
									}
								}
								.alert("Rename Stopwatch", isPresented: $showingRenameAlert) {
									VStack {
										TextField("New Name", text: $renameText)
										Button("Cancel", role: .cancel) {
											showingRenameAlert = false
										}
										Button("OK") {
											if let stopwatch = selectedStopwatch {
												stopwatch.label = renameText
											}
											showingRenameAlert = false
										}
									}
								}
								.alert("Delete \(selectedStopwatch?.label ?? "")", isPresented: $showDeleteAlert) {
									Button("Cancel", role: .cancel) {
										showDeleteAlert = false
									}
									Button("Delete", role: .destructive) {
										if let stopwatch = selectedStopwatch,
										   let index = viewModel.stopwatches.firstIndex(where: { $0.id == stopwatch.id }) {
											viewModel.deleteStopwatch(at: index)
										}
										showDeleteAlert = false
									}
								}
						}
						
					}
					HStack {
						Button {
							viewModel.startAll()
						} label: {
							HStack {
								Image(systemName: "play")
								Text("Start all")
							}
							.fontWeight(.medium)
							.padding(8)
							.foregroundStyle(Color("TextColor"))
							.frame(maxWidth: .infinity)
							.background(.green.opacity(0.75))
							.clipShape(RoundedRectangle(cornerRadius: 6))
							.padding(.horizontal, 4)
						}
						Button {
							viewModel.stopAll()
						} label: {
							HStack {
								Image(systemName: "stop")
								Text("Stop all")
							}
							.fontWeight(.medium)
							.padding(8)
							.foregroundStyle(Color("TextColor"))
							.frame(maxWidth: .infinity)
							.background(.red.opacity(0.75))
							.clipShape(RoundedRectangle(cornerRadius: 6))
							.padding(.horizontal, 4)
						}
					}
					.padding(.horizontal, 8)
					HStack {
						TextField("Title", text: $newStopwatchLabel)
							.padding(.horizontal, 8)
							.padding(.vertical, 5)
							.overlay {
								RoundedRectangle(cornerRadius: 8, style: .continuous)
									.stroke(Color.gray, lineWidth: 0.75)
									.opacity(0.25)
							}
						Button {
							if newStopwatchLabel.isEmpty {
								viewModel.addStopwatch(title: "Stopwatch \(viewModel.stopwatches.count + 1)")
							} else {
								viewModel.addStopwatch(title: newStopwatchLabel)
							}
							newStopwatchLabel = ""
						} label: {
							Image(systemName: "plus.circle.fill")
								.font(.largeTitle)
						}
					}
					.padding()
				}
				Spacer()
			}
			.navigationTitle("Stopwatch")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						showClearAlert = true
						//						viewModel.stopwatches = [Stopwatch(label: "Stopwatch 1")]
						//						viewModel.saveAllStopwatches()
					} label: {
						Image(systemName: "xmark.circle")
							.foregroundStyle(.red)
					}
				}
			}
			
			.alert("Clear all stopwatches?", isPresented: $showClearAlert) {
				Button("Cancel", role: .cancel) {
					showClearAlert = false
				}
				Button("Clear", role: .destructive) {
					if settingsConfiguration.resetToOneStopwatch {
						viewModel.stopwatches = [Stopwatch(label: "Stopwatch 1")]
					} else {
						viewModel.stopwatches = []
					}
					showClearAlert = false
				}
			}
		}
	}
}


#Preview {
	StopwatchesMainView()
}
