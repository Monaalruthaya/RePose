import UIKit
import Vision
import SwiftUI
import TipKit

@available(iOS 17.0, *)
class MainViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var labelStack: UIStackView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var summaryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var guideLabel: UILabel!

    var videoCapture: VideoCapture!
    var videoProcessingChain: VideoProcessingChain!
    var actionFrameCounts = [String: Int]()

    private var tipHostingController: UIHostingController<AnyView>?
}

// MARK: - View Controller Events
extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        imageView.contentMode = .scaleAspectFill

        // ✅ تفعيل TipKit
        if #available(iOS 17.0, *) {
            try? Tips.configure()
        }

        // ✅ لون زر الرجوع الرسمي
        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryPurple")

        // تهيئة المكونات
        let views = [labelStack, buttonStack, cameraButton, summaryButton]
        views.forEach { view in
            view?.layer.cornerRadius = 10
            view?.overrideUserInterfaceStyle = .dark
        }

        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.delegate = self

        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.isEnabled = true

        guideLabel.text = "Make sure your full body is visible"
        guideLabel.isHidden = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.guideLabel.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCapture.updateDeviceOrientation()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        videoCapture.updateDeviceOrientation()
    }
}

// MARK: - Button Events
extension MainViewController {
    @IBAction func onCameraButtonTapped(_: Any) {
        videoCapture.toggleCameraSelection()
    }
}

// MARK: - Video Capture Delegate
extension MainViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCreate framePublisher: FramePublisher) {
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

// MARK: - Video Processing Chain Delegate
extension MainViewController: VideoProcessingChainDelegate {
    func videoProcessingChain(_ chain: VideoProcessingChain, didPredict actionPrediction: ActionPrediction, for frameCount: Int) {
        if actionPrediction.isModelLabel {
            addFrameCount(frameCount, to: actionPrediction.label)
        }

        let isCorrect = (actionPrediction.confidence ?? 0) >= 0.9
        showFeedbackTip(isCorrect: isCorrect)
    }

    func videoProcessingChain(_ chain: VideoProcessingChain, didDetect poses: [Pose]?, in frame: CGImage) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.drawPoses(poses, onto: frame)
        }
    }
}

// MARK: - Helper methods
extension MainViewController {
    private func addFrameCount(_ frameCount: Int, to actionLabel: String) {
        let totalFrames = (actionFrameCounts[actionLabel] ?? 0) + frameCount
        actionFrameCounts[actionLabel] = totalFrames
    }

    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
        let renderFormat = UIGraphicsImageRendererFormat()
        renderFormat.scale = 1.0
        let frameSize = CGSize(width: frame.width, height: frame.height)

        let frameWithPosesRendering = UIGraphicsImageRenderer(size: frameSize, format: renderFormat).image { context in
            let cg = context.cgContext
            cg.concatenate(cg.ctm.inverted())
            cg.draw(frame, in: CGRect(origin: .zero, size: frameSize))

            let transform = CGAffineTransform(scaleX: frameSize.width, y: frameSize.height)
            poses?.forEach { $0.drawWireframeToContext(cg, applying: transform) }
        }

        DispatchQueue.main.async {
            self.imageView.image = frameWithPosesRendering
        }
    }

    private func showFeedbackTip(isCorrect: Bool) {
        let tipView = TipView(isCorrect ? FeedbackCorrectTip() : FeedbackWrongTip()).padding()

        let hosting = UIHostingController(rootView: AnyView(tipView))
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        if let current = tipHostingController {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
            tipHostingController = nil
        }

        addChild(hosting)
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        hosting.didMove(toParent: self)
        tipHostingController = hosting

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            hosting.willMove(toParent: nil)
            hosting.view.removeFromSuperview()
            hosting.removeFromParent()
            self.tipHostingController = nil
        }
    }
}

// MARK: - TipKit Tips
@available(iOS 17.0, *)
struct FeedbackCorrectTip: Tip {
    var title: Text { Text("✅ Excellent!") }
    var message: Text? { Text("You're doing great!") }
}

@available(iOS 17.0, *)
struct FeedbackWrongTip: Tip {
    var title: Text { Text("❌ Wrong Move!") }
    var message: Text? { Text("Adjust your form and try again.") }
}
