//
// ControllerManager.swift
// ReachControl
//
// Created by oc7o on 22.11.25.
// Copyright © 2025 Sloow. All rights reserved. 


import GameController
import Combine

class ControllerManager: ObservableObject {
    @Published var isConnected = false
    @Published var currentState = ControllerState()
    
    private var controller: GCController?
    private var observers: [Any] = []
    
    init() {
        setupControllerObservers()
        connectToController()
    }
    
    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    private func setupControllerObservers() {
        let connectedObserver = NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let controller = notification.object as? GCController {
                self?.connectToController(controller)
            }
        }
        
        let disconnectedObserver = NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.disconnectController()
        }
        
        observers = [connectedObserver, disconnectedObserver]
    }
    
    private func connectToController(_ controller: GCController? = nil) {
        if let controller = controller {
            self.controller = controller
        } else {
            self.controller = GCController.controllers().first
        }
        
        guard let controller = self.controller else {
            isConnected = false
            return
        }
        
        isConnected = true
        setupInputHandlers(for: controller)
    }
    
    private func disconnectController() {
        controller = nil
        isConnected = false
        currentState = ControllerState()
    }
    
    private func setupInputHandlers(for controller: GCController) {
        // Extended gamepad is the most common profile for PS5 controller
        guard let gamepad = controller.extendedGamepad else { return }
        
        // Left stick
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.currentState.leftStick = Vector2D(x: xValue, y: yValue)
        }
        
        // Right stick
        gamepad.rightThumbstick.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.currentState.rightStick = Vector2D(x: xValue, y: yValue)
        }
        
        // D-Pad
        gamepad.dpad.valueChangedHandler = { [weak self] _, xValue, yValue in
            self?.currentState.dpad = Vector2D(x: xValue, y: yValue)
        }
        
        // Buttons
        gamepad.buttonA.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonCross = pressed
        }
        
        gamepad.buttonB.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonCircle = pressed
        }
        
        gamepad.buttonX.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonSquare = pressed
        }
        
        gamepad.buttonY.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonTriangle = pressed
        }
        
        // Shoulder buttons
        gamepad.leftShoulder.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonL1 = pressed
        }
        
        gamepad.rightShoulder.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonR1 = pressed
        }
        
        // Triggers
        gamepad.leftTrigger.valueChangedHandler = { [weak self] _, value, pressed in
            self?.currentState.triggerL2 = value
        }
        
        gamepad.rightTrigger.valueChangedHandler = { [weak self] _, value, pressed in
            self?.currentState.triggerR2 = value
        }
        
        // Menu buttons
        gamepad.buttonMenu?.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonOptions = pressed
        }
        
        gamepad.buttonOptions?.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonShare = pressed
        }
        
        // Thumbstick buttons (L3/R3)
        gamepad.leftThumbstickButton?.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonL3 = pressed
        }
        
        gamepad.rightThumbstickButton?.valueChangedHandler = { [weak self] _, _, pressed in
            self?.currentState.buttonR3 = pressed
        }
    }
}

// Data structures
struct Vector2D: Codable {
    var x: Float
    var y: Float
    
    init(x: Float = 0, y: Float = 0) {
        self.x = x
        self.y = y
    }
}

struct ControllerState: Codable {
    var leftStick = Vector2D()
    var rightStick = Vector2D()
    var dpad = Vector2D()
    
    var buttonCross = false
    var buttonCircle = false
    var buttonSquare = false
    var buttonTriangle = false
    
    var buttonL1 = false
    var buttonR1 = false
    var buttonL3 = false
    var buttonR3 = false
    
    var triggerL2: Float = 0
    var triggerR2: Float = 0
    
    var buttonOptions = false
    var buttonShare = false
    
    var timestamp = Date()
}
