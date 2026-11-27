//
// ControllerGRPCClient.swift
// ReachControl
//
// Created by oc7o on 23.11.25.
// Copyright © 2025 Sloow. All rights reserved. 


import Foundation
import GRPC
import NIOCore
import NIOPosix

class ControllerGRPCClient: ObservableObject {
    @Published var isConnected = false
    @Published var lastError: String?
    @Published var messagesSent = 0
    
    private var channel: ClientConnection?
    private var client: Controller_ControllerServiceAsyncClient?
    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    private var streamingTask: Task<Void, Never>?
    private var isStreaming = false
    
    // Configuration
    var serverHost = "localhost"
    var serverPort = 50051
    
    deinit {
        disconnect()
        try? eventLoopGroup.syncShutdownGracefully()
    }
    
    func connect() {
        disconnect()
        
        do {
            channel = try GRPCChannelPool.with(
                target: .host(serverHost, port: serverPort),
                transportSecurity: .plaintext,
                eventLoopGroup: eventLoopGroup
            )
            
            client = Controller_ControllerServiceAsyncClient(channel: channel!)
            isConnected = true
            lastError = nil
            
            print("✅ Connected to gRPC server at \(serverHost):\(serverPort)")
        } catch {
            lastError = "Failed to connect: \(error.localizedDescription)"
            isConnected = false
            print("❌ Connection failed: \(error)")
        }
    }
    
    func disconnect() {
        stopStreaming()
        
        if let channel = channel {
            _ = channel.close()
            self.channel = nil
            self.client = nil
            isConnected = false
            print("🔌 Disconnected from gRPC server")
        }
    }
    
    // Send a single controller state
    func sendState(_ state: ControllerState) async {
        guard let client = client else {
            lastError = "Not connected to server"
            return
        }
        
        let message = state.toProtoMessage()
        
        do {
            let response = try await client.sendControllerState(message)
            if response.success {
                await MainActor.run {
                    messagesSent += 1
                }
            }
        } catch {
            await MainActor.run {
                lastError = "Failed to send state: \(error.localizedDescription)"
            }
            print("❌ Send error: \(error)")
        }
    }
    
    // Start streaming controller states
    func startStreaming(controllerManager: ControllerManager, updateInterval: TimeInterval = 0.016) {
        guard !isStreaming else { return }
        guard client != nil else {
            lastError = "Not connected to server"
            return
        }
        
        isStreaming = true
        
        streamingTask = Task {
            while isStreaming && !Task.isCancelled {
                let state = await MainActor.run { controllerManager.currentState }
                await sendState(state)
                
                try? await Task.sleep(nanoseconds: UInt64(updateInterval * 1_000_000_000))
            }
        }
        
        print("▶️ Started streaming controller data")
    }
    
    func stopStreaming() {
        isStreaming = false
        streamingTask?.cancel()
        streamingTask = nil
        print("⏹️ Stopped streaming controller data")
    }
}

// Extension to convert ControllerState to Proto message
extension ControllerState {
    func toProtoMessage() -> Controller_ControllerStateMessage {
        var message = Controller_ControllerStateMessage()
        
        message.leftStick = Controller_Vector2D.with {
            $0.x = leftStick.x
            $0.y = leftStick.y
        }
        
        message.rightStick = Controller_Vector2D.with {
            $0.x = rightStick.x
            $0.y = rightStick.y
        }
        
        message.dpad = Controller_Vector2D.with {
            $0.x = dpad.x
            $0.y = dpad.y
        }
        
        message.buttonCross = buttonCross
        message.buttonCircle = buttonCircle
        message.buttonSquare = buttonSquare
        message.buttonTriangle = buttonTriangle
        
        message.buttonL1 = buttonL1
        message.buttonR1 = buttonR1
        message.buttonL3 = buttonL3
        message.buttonR3 = buttonR3
        
        message.triggerL2 = triggerL2
        message.triggerR2 = triggerR2
        
        message.buttonOptions = buttonOptions
        message.buttonShare = buttonShare
        
        message.timestamp = Int64(timestamp.timeIntervalSince1970 * 1000)
        
        return message
    }
}
