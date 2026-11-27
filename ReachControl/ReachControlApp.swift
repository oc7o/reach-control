//
// ReachControlApp.swift
// ReachControl
//
// Created by oc7o on 07.10.25.
// Copyright © 2025 Sloow. All rights reserved. 


import SwiftUI

@main
struct ReachControlApp: App {
    @StateObject private var controllerManager = ControllerManager()
    @StateObject private var grpcClient = ControllerGRPCClient()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controllerManager)
                .environmentObject(grpcClient)
        }
    }
}
