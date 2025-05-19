/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A `Connection` defines the line between two landmarks.
 The only real purpose for a connection is to draw that line with a gradient.
*/
import UIKit

extension Pose {
    /// Represents a line between two landmarks.
    struct Connection: Equatable {
        static let width: CGFloat = 12.0

        // ✅ اللون: A6FF04 مع شفافية 65%
        static let color = UIColor(red: 0.65, green: 1.0, blue: 0.0157, alpha: 0.65).cgColor

        /// The connection's first endpoint.
        private let point1: CGPoint

        /// The connection's second endpoint.
        private let point2: CGPoint

        /// Creates a connection from two points.
        ///
        /// The order of the points isn't important.
        /// - Parameters:
        ///   - one: The location for one end of the connection.
        ///   - two: The location for the other end of the connection.
        init(_ one: CGPoint, _ two: CGPoint) {
            point1 = one
            point2 = two
        }

        /// Draws a line from the connection's first endpoint to its other
        /// endpoint.
        /// - Parameters:
        ///   - context: The Core Graphics context to draw to.
        ///   - transform: An affine transform that scales and translate each
        ///   endpoint.
        ///   - scale: The scale that adjusts the line's thickness.
        func drawToContext(_ context: CGContext,
                           applying transform: CGAffineTransform? = nil,
                           at scale: CGFloat = 1.0) {
            let start = point1.applying(transform ?? .identity)
            let end = point2.applying(transform ?? .identity)

            context.saveGState()
            defer { context.restoreGState() }

            context.setLineWidth(Connection.width * scale)
            context.setStrokeColor(Connection.color)

            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
        }
    }
}


extension Pose {
    /// A series of joint pairs that define the wireframe lines of a pose.
    static let jointPairs: [(joint1: JointName, joint2: JointName)] = [
        // The left arm's connections.
        (.leftShoulder, .leftElbow),
        (.leftElbow, .leftWrist),

        // The left leg's connections.
        (.leftHip, .leftKnee),
        (.leftKnee, .leftAnkle),

        // The right arm's connections.
        (.rightShoulder, .rightElbow),
        (.rightElbow, .rightWrist),

        // The right leg's connections.
        (.rightHip, .rightKnee),
        (.rightKnee, .rightAnkle),

        // The torso's connections.
        (.leftShoulder, .neck),
        (.rightShoulder, .neck),
        (.leftShoulder, .leftHip),
        (.rightShoulder, .rightHip),
        (.leftHip, .rightHip)
    ]
}
