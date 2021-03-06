import Flutter
import UIKit
import SocketIO


public class SwiftAdharaSocketIoPlugin: NSObject, FlutterPlugin {

    var instances: [Int: AdharaSocket];
    var currentIndex: Int;
    let registrar: FlutterPluginRegistrar;

    init(_ _registrar: FlutterPluginRegistrar){
        registrar = _registrar
        instances = [Int: AdharaSocket]()
        currentIndex = 0;
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "adhara_socket_io", binaryMessenger: registrar.messenger())
        let instance = SwiftAdharaSocketIoPlugin(registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: AnyObject]

        switch (call.method) {
            case "newInstance":
                let newIndex = arguments["id"] as! Int
                let config:AdharaSocketIOClientConfig
                    = AdharaSocketIOClientConfig(newIndex, uri: arguments["uri"] as! String,
                                                 namespace: arguments["namespace"] as! String, path: arguments["path"] as! String)
                if let query: [String:String] = arguments["query"] as? [String:String]{
                    config.query = query
                }
                if let enableLogging: Bool = arguments["enableLogging"] as? Bool {
                    config.enableLogging = enableLogging
                }
                instances[newIndex] = AdharaSocket.getInstance(registrar, config)
                currentIndex += 1
                result(newIndex)
            case "clearInstance":
                if(arguments["id"] == nil){
                    result(FlutterError(code: "400", message: "Invalid instance identifier provided", details: nil))
                }else{
                    let socketIndex = arguments["id"] as! Int
                    if (instances[socketIndex] != nil && instances.size > 1) {
                        instances[socketIndex]?.socket.disconnect()
                        instances[socketIndex] = nil
                        result("successfully disconnected socket")
                    } 
                    result("socket instance not found")
                    // else {
                    //     result(FlutterError(code: "403", message: "Instance not found", details: nil))
                    // }
                }
            case "clearAll":
                print("clearAll------")
                print(currentIndex)
                var i = 0
                while (i < currentIndex){
                    if(instances[i] != nil) {
                        instances[i]?.socket.disconnect()
                        instances[i] = nil
                    }
                    
                    i += 1
                    print("disconnected socket")
                    print(i)
                }
                result(nil);
            default:
                result(FlutterError(code: "404", message: "No such method", details: nil))
        }
    }

}
