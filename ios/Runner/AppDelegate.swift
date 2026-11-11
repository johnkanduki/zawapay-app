import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ZawapayFaceVision") {
      FaceVision.register(messenger: registrar.messenger())
    }
  }
}

/// Profile photo: finds faces in a front-camera frame with Apple Vision
/// (built into iOS). Google ML Kit crashes on iOS 27 while writing its own
/// usage logs, so it is used on Android only.
enum FaceVision {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "zawapay/face", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "faces",
        let args = call.arguments as? [String: Any],
        let data = args["bytes"] as? FlutterStandardTypedData,
        let width = args["width"] as? Int,
        let height = args["height"] as? Int,
        let bytesPerRow = args["bytesPerRow"] as? Int
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        let widths = faceWidths(data.data, width: width, height: height, bytesPerRow: bytesPerRow)
        DispatchQueue.main.async { result(widths) }
      }
    }
  }

  /// Width of each face, as a share of the upright picture width (0 to 1).
  static func faceWidths(_ bytes: Data, width: Int, height: Int, bytesPerRow: Int) -> [Double] {
    var buffer: CVPixelBuffer?
    guard CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &buffer) == kCVReturnSuccess,
      let pixels = buffer, bytes.count >= bytesPerRow * height
    else { return [] }
    CVPixelBufferLockBaseAddress(pixels, [])
    if let base = CVPixelBufferGetBaseAddress(pixels) {
      let target = CVPixelBufferGetBytesPerRow(pixels)
      let rowLength = min(target, bytesPerRow)
      bytes.withUnsafeBytes { raw in
        guard let source = raw.baseAddress else { return }
        for row in 0..<height {
          memcpy(base + row * target, source + row * bytesPerRow, rowLength)
        }
      }
    }
    CVPixelBufferUnlockBaseAddress(pixels, [])

    // Phone held upright, front camera: the frame is turned and mirrored.
    for orientation in [CGImagePropertyOrientation.leftMirrored, .right] {
      let request = VNDetectFaceRectanglesRequest()
      let handler = VNImageRequestHandler(cvPixelBuffer: pixels, orientation: orientation, options: [:])
      try? handler.perform([request])
      let faces = request.results ?? []
      if !faces.isEmpty { return faces.map { Double($0.boundingBox.width) } }
    }
    return []
  }
}
