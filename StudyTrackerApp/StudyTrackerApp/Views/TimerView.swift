import SwiftUI

struct TimerView: View {
    @Binding var elapsed: TimeInterval
    @Binding var isRunning: Bool
    @Binding var hasStartedBefore: Bool

    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void
    let onResumeForeground: () -> Void

    var body: some View {
        VStack(spacing: 16) {

            Text(TimeFormatter.string(from: elapsed))
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )

            HStack(spacing: 16) {

                if isRunning {
                    // RUNNING → Pause + Stop
                    Button(action: onPause) {
                        Label("Pause", systemImage: "pause.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).strokeBorder())
                    }

                    Button(action: onStop) {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(.linearGradient(
                                        colors: [Color.red.opacity(0.8), Color.red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                            .foregroundColor(.white)
                    }

                } else if hasStartedBefore {
                    // PAUSED → Resume + Stop
                    Button(action: onResume) {
                        Label("Resume", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).strokeBorder())
                    }

                    Button(action: onStop) {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(.linearGradient(
                                        colors: [Color.red.opacity(0.8), Color.red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                            .foregroundColor(.white)
                    }

                } else {
                    // FIRST-TIME → ONLY START
                    Button(action: onStart) {
                        Label("Start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(.linearGradient(
                                        colors: [Color.green.opacity(0.8), Color.green],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            onResumeForeground()
        }
    }
}
