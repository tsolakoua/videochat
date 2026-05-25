import OpenTok
import SwiftUI
import Combine

final class VideoManager: NSObject, ObservableObject, OTPublisherKitDelegate, OTSubscriberKitDelegate {
    
    enum Secrets {
        static let appId = value(for: "APP_ID")
        static let sessionId = value(for: "SESSION_ID")
        static let sessionToken = value(for: "SESSION_TOKEN")

        private static func value(for key: String) -> String {
            guard let val = Bundle.main.infoDictionary?[key] as? String else {
                fatalError("'\(key)' not found.")
            }
            return val
        }
    }
    
    private var session: OTSession?
    
    private var subscriber: OTSubscriber?
    private lazy var publisher: OTPublisher? = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        let publisher = OTPublisher(delegate: self, settings: settings)
        publisher?.publishAudio = isAudioEnabled
        return publisher
    }()
    
    @Published var pubView: UIView?
    @Published var subView: UIView?
    
    @Published private(set) var isAudioEnabled = false
    @Published private(set) var isVideoEnabled = true
    
    public func setup() {
        doConnect()
    }

    public func toggleAudio() {
        isAudioEnabled.toggle()
        publisher?.publishAudio = isAudioEnabled
    }

    public func toggleVideo() {
        isVideoEnabled.toggle()
        publisher?.publishVideo = isVideoEnabled
    }
    
    private func doConnect() {
        session = OTSession(applicationId: Secrets.appId, sessionId: Secrets.sessionId, delegate: self)
        if session == nil {
            fatalError("Check your credentials and try again (appId, sessionId, sessionToken)")
        }
        var error: OTError?
        defer {
            processError(error)
        }
        session?.connect(withToken: Secrets.sessionToken, error: &error)
    }

    private func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            if let error {
                processError(error)
            }
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        session?.subscribe(subscriber!, error: &error)
    }
    
    private func cleanupSubscriber() {
        DispatchQueue.main.async {
            self.subView = nil
        }
    }
    
    private func cleanupPublisher() {
        DispatchQueue.main.async {
            self.pubView = nil
        }
    }
    
    private func processError(_ error: OTError?) {
        print("Got the error \(String(describing: error))")
    }
    
    public func disconnect() {
        var error: OTError?
        session?.disconnect(&error)

        if let error {
            print("Disconnect failed: \(error.localizedDescription)")
        }
    }
    
}

extension VideoManager: OTSessionDelegate {

    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        var error: OTError?
        defer {
            processError(error)
        }
        
        guard let publisher else {
            return
        }
        publisher.publishAudio = isAudioEnabled
        session.publish(publisher, error: &error)
        
        if let view = publisher.view {
            DispatchQueue.main.async {
                self.pubView = view
            }
        }
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("Session failed to connect: \(error.localizedDescription)")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session stream is created: \(stream.streamId)")
        doSubscribe(stream)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session stream is destroyed: \(stream.streamId)")
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
}

extension VideoManager: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Publishing...")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
    
}

extension VideoManager: OTSubscriberDelegate {
    
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("The subscriber is connected to the stream.")
        if let view = subscriber?.view {
            DispatchQueue.main.async {
                self.subView = view
            }
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
}
