//
// ContentView.swift
// ReachControl
//
// Created by oc7o on 23.11.25.
// Copyright © 2025 Sloow. All rights reserved. 


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var controllerManager: ControllerManager
    @EnvironmentObject var grpcClient: ControllerGRPCClient
    
    @State private var serverHost = "localhost"
    @State private var serverPort = "50051"
    @State private var isStreaming = false
    @State private var updateRate: Double = 60 // Hz
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Controller Status
                GroupBox {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(controllerManager.isConnected ? .green : .gray)
                        Text(controllerManager.isConnected ? "Controller Connected" : "No Controller")
                            .font(.headline)
                        Spacer()
                        Circle()
                            .fill(controllerManager.isConnected ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                    }
                } label: {
                    Label("Controller Status", systemImage: "gamecontroller")
                }
                
                // gRPC Connection
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "network")
                                .foregroundColor(grpcClient.isConnected ? .green : .gray)
                            Text(grpcClient.isConnected ? "Connected to Server" : "Disconnected")
                                .font(.headline)
                            Spacer()
                            Circle()
                                .fill(grpcClient.isConnected ? Color.green : Color.gray)
                                .frame(width: 12, height: 12)
                        }
                        
                        if !grpcClient.isConnected {
                            HStack {
                                TextField("Host", text: $serverHost)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: 200)
                                
                                TextField("Port", text: $serverPort)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: 80)
                            }
                            
                            Button(action: {
                                if let port = Int(serverPort) {
                                    grpcClient.serverHost = serverHost
                                    grpcClient.serverPort = port
                                    grpcClient.connect()
                                }
                            }) {
                                Label("Connect", systemImage: "arrow.up.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button(action: {
                                grpcClient.disconnect()
                                isStreaming = false
                            }) {
                                Label("Disconnect", systemImage: "arrow.down.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        if let error = grpcClient.lastError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                } label: {
                    Label("gRPC Connection", systemImage: "network")
                }
                
                // Streaming Control
                if grpcClient.isConnected && controllerManager.isConnected {
                    GroupBox {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Update Rate:")
                                Slider(value: $updateRate, in: 10...120, step: 10)
                                Text("\(Int(updateRate)) Hz")
                                    .frame(width: 60)
                            }
                            
                            Button(action: {
                                if isStreaming {
                                    grpcClient.stopStreaming()
                                    isStreaming = false
                                } else {
                                    grpcClient.startStreaming(
                                        controllerManager: controllerManager,
                                        updateInterval: 1.0 / updateRate
                                    )
                                    isStreaming = true
                                }
                            }) {
                                Label(
                                    isStreaming ? "Stop Streaming" : "Start Streaming",
                                    systemImage: isStreaming ? "stop.circle.fill" : "play.circle.fill"
                                )
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(isStreaming ? .red : .green)
                            
                            if isStreaming {
                                Text("Messages sent: \(grpcClient.messagesSent)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } label: {
                        Label("Streaming", systemImage: "antenna.radiowaves.left.and.right")
                    }
                }
                
                // Controller State Visualization
                if controllerManager.isConnected {
                    ControllerVisualizationView(state: controllerManager.currentState)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("PS5 Controller → gRPC")
        }
    }
}

struct ControllerVisualizationView: View {
    let state: ControllerState
    
    var body: some View {
        GroupBox {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Analog Sticks
                    HStack(spacing: 20) {
                        VStack {
                            Text("Left Stick")
                                .font(.caption)
                            StickVisualizer(x: state.leftStick.x, y: state.leftStick.y)
                            Text("X: \(String(format: "%.2f", state.leftStick.x))")
                                .font(.caption2)
                            Text("Y: \(String(format: "%.2f", state.leftStick.y))")
                                .font(.caption2)
                        }
                        
                        VStack {
                            Text("Right Stick")
                                .font(.caption)
                            StickVisualizer(x: state.rightStick.x, y: state.rightStick.y)
                            Text("X: \(String(format: "%.2f", state.rightStick.x))")
                                .font(.caption2)
                            Text("Y: \(String(format: "%.2f", state.rightStick.y))")
                                .font(.caption2)
                        }
                    }
                    
                    Divider()
                    
                    // Buttons
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Face Buttons")
                            .font(.caption)
                            .fontWeight(.bold)
                        
                        HStack {
                            ButtonIndicator(label: "✕", isPressed: state.buttonCross)
                            ButtonIndicator(label: "○", isPressed: state.buttonCircle)
                            ButtonIndicator(label: "□", isPressed: state.buttonSquare)
                            ButtonIndicator(label: "△", isPressed: state.buttonTriangle)
                        }
                    }
                    
                    Divider()
                    
                    // Shoulder Buttons
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Shoulder Buttons")
                            .font(.caption)
                            .fontWeight(.bold)
                        
                        HStack {
                            ButtonIndicator(label: "L1", isPressed: state.buttonL1)
                            ButtonIndicator(label: "R1", isPressed: state.buttonR1)
                            ButtonIndicator(label: "L3", isPressed: state.buttonL3)
                            ButtonIndicator(label: "R3", isPressed: state.buttonR3)
                        }
                    }
                    
                    Divider()
                    
                    // Triggers
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Triggers")
                            .font(.caption)
                            .fontWeight(.bold)
                        
                        HStack {
                            VStack {
                                Text("L2")
                                ProgressView(value: Double(state.triggerL2), total: 1.0)
                                    .frame(width: 100)
                                Text(String(format: "%.2f", state.triggerL2))
                                    .font(.caption2)
                            }
                            
                            VStack {
                                Text("R2")
                                ProgressView(value: Double(state.triggerR2), total: 1.0)
                                    .frame(width: 100)
                                Text(String(format: "%.2f", state.triggerR2))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        } label: {
            Label("Controller State", systemImage: "info.circle")
        }
        .frame(maxHeight: 400)
    }
}

struct StickVisualizer: View {
    let x: Float
    let y: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 80, height: 80)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .offset(
                    x: CGFloat(x) * 30,
                    y: CGFloat(-y) * 30
                )
        }
    }
}

struct ButtonIndicator: View {
    let label: String
    let isPressed: Bool
    
    var body: some View {
        Text(label)
            .font(.system(size: 16, weight: .bold))
            .frame(width: 40, height: 40)
            .background(isPressed ? Color.green : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

#Preview {
    ContentView()
        .environmentObject(ControllerManager())
        .environmentObject(ControllerGRPCClient())
}
