import SwiftUI

struct ContentView: View {
    @ObservedObject var videoManager = VideoManager()
    @State private var hasLeftCall = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Subscriber (main/full screen)
                ZStack(alignment: .topTrailing) {
                    if let subView = videoManager.subView {
                        Wrap(view: subView)
                            .ignoresSafeArea()
                    } else {
                        placeholderView(icon: "person.fill", label: "Waiting for participant...")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Publisher (picture-in-picture overlay)
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        if videoManager.isVideoEnabled, let pubView = videoManager.pubView {
                            Wrap(view: pubView)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(white: 0.15))
                                .overlay(
                                    Image(systemName: "video.slash.fill")
                                        .foregroundColor(.white.opacity(0.4))
                                        .font(.system(size: 24))
                                )
                        }
                    }
                    .frame(width: 120, height: 160)
                }
                .padding(.top, 56)
                .padding(.trailing, 16)
                Spacer()
            }

            // Bottom control bar (mute toggle, disconnect, video enabled toggle)
            VStack {
                Spacer()
                HStack(spacing: 40) {
                    ControlButton(
                        icon: videoManager.isAudioEnabled ? "mic.fill" : "mic.slash.fill",
                        color: videoManager.isAudioEnabled ? .white.opacity(0.15) : .red,
                        action: videoManager.toggleAudio
                    )
                    ControlButton(
                        icon: "phone.down.fill",
                        color: .red,
                        size: 56,
                        action: leaveCall
                    )
                    ControlButton(
                        icon: videoManager.isVideoEnabled ? "video.fill" : "video.slash.fill",
                        color: videoManager.isVideoEnabled ? .white.opacity(0.15) : .red,
                        action: videoManager.toggleVideo
                    )
                }
                .padding(.bottom, 48)
            }

            if hasLeftCall {
                endedCallView
            }
        }
        .task {
            videoManager.setup()
        }
    }

    private func leaveCall() {
        videoManager.disconnect()
        hasLeftCall = true
    }

    private var endedCallView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "phone.down.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.red)
                Text("Call ended")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                Text("You disconnected from the session.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    @ViewBuilder
    private func placeholderView(icon: String, label: String) -> some View {
        ZStack {
            Color(white: 0.08)
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.2))
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.3))
            }
        }
    }
}

struct ControlButton: View {
    let icon: String
    var color: Color = .white.opacity(0.15)
    var size: CGFloat = 48
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(color)
                .clipShape(Circle())
        }
    }
}

#Preview {
    ContentView()
}
