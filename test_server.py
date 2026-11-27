#
// test_server.py
// ReachControl
//
// Created by oc7o on 23.11.25.
// Copyright © 2025 Sloow. All rights reserved. 


"""
Simple gRPC server to receive PS5 controller data
"""

import grpc
from concurrent import futures
import time
import sys
import os

# Add the generated files to path
sys.path.insert(0, os.path.dirname(__file__))

try:
    import controller_pb2
    import controller_pb2_grpc
except ImportError:
    print("❌ Error: Generated Python files not found!")
    print("\nPlease generate them first:")
    print("python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. proto/controller.proto")
    sys.exit(1)


class ControllerService(controller_pb2_grpc.ControllerServiceServicer):
    def __init__(self):
        self.message_count = 0
        
    def SendControllerState(self, request, context):
        """Handle incoming controller state messages"""
        self.message_count += 1
        
        # Print every 60th message to avoid spam (once per second at 60Hz)
        if self.message_count % 60 == 0:
            print(f"\n📊 Status Update (Message #{self.message_count})")
            print(f"{'='*60}")
            
            # Analog Sticks
            print(f"Left Stick:  X={request.left_stick.x:+.2f}, Y={request.left_stick.y:+.2f}")
            print(f"Right Stick: X={request.right_stick.x:+.2f}, Y={request.right_stick.y:+.2f}")
            
            # D-Pad
            if request.dpad.x != 0 or request.dpad.y != 0:
                print(f"D-Pad:       X={request.dpad.x:+.2f}, Y={request.dpad.y:+.2f}")
            
            # Triggers
            if request.trigger_l2 > 0 or request.trigger_r2 > 0:
                print(f"Triggers:    L2={request.trigger_l2:.2f}, R2={request.trigger_r2:.2f}")
            
            # Buttons pressed
            buttons = []
            if request.button_cross: buttons.append("✕")
            if request.button_circle: buttons.append("○")
            if request.button_square: buttons.append("□")
            if request.button_triangle: buttons.append("△")
            if request.button_l1: buttons.append("L1")
            if request.button_r1: buttons.append("R1")
            if request.button_l3: buttons.append("L3")
            if request.button_r3: buttons.append("R3")
            if request.button_options: buttons.append("Options")
            if request.button_share: buttons.append("Share")
            
            if buttons:
                print(f"Buttons:     {', '.join(buttons)}")
            
            print(f"{'='*60}")
        
        # Return success response
        return controller_pb2.StateResponse(
            success=True,
            message="State received",
            timestamp=int(time.time() * 1000)
        )
    
    def StreamControllerState(self, request_iterator, context):
        """Handle streaming controller state (bidirectional streaming)"""
        print("📡 Started streaming mode")
        
        for request in request_iterator:
            self.SendControllerState(request, context)
        
        return controller_pb2.StreamResponse(
            success=True,
            message="Stream completed"
        )


def serve():
    """Start the gRPC server"""
    # Create server with thread pool
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    
    # Add our service
    controller_pb2_grpc.add_ControllerServiceServicer_to_server(
        ControllerService(), server
    )
    
    # Bind to port
    port = 50051
    server.add_insecure_port(f'[::]:{port}')
    
    # Start server
    server.start()
    print(f"✅ gRPC Server started on port {port}")
    print(f"🎮 Ready to receive PS5 controller data")
    print(f"{'='*60}")
    print("Press Ctrl+C to stop\n")
    
    try:
        server.wait_for_termination()
    except KeyboardInterrupt:
        print("\n\n🛑 Shutting down server...")
        server.stop(0)


if __name__ == '__main__':
    # Check if grpcio is installed
    try:
        import grpc
    except ImportError:
        print("❌ Error: grpcio not installed!")
        print("\nInstall dependencies:")
        print("pip install grpcio grpcio-tools")
        sys.exit(1)
    
    serve()
