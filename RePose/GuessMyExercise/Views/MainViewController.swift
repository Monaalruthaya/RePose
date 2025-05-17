import UIKit
import Vision

@available(iOS 14.0, *)
class MainViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var labelStack: UIStackView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var summaryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!

    // ✅ عناصر جديدة
    @IBOutlet weak var guideLabel: UILabel!
//    @IBOutlet weak var feedbackLabel: UILabel!
//    @IBOutlet weak var feedbackBackgroundView: UIView!

    var videoCapture: VideoCapture!
    var videoProcessingChain: VideoProcessingChain!
    var actionFrameCounts = [String: Int]()
}

// MARK: - View Controller Events
extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        let views = [labelStack, buttonStack, cameraButton, summaryButton]
        views.forEach { view in
            view?.layer.cornerRadius = 10
            view?.overrideUserInterfaceStyle = .dark
        }

        // تجهيز السلسلة
        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.delegate = self

        // تشغيل الكاميرا مباشرة
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.isEnabled = true

        // إظهار التعليمات فوق الكاميرا
        guideLabel.text = "Make sure your full body is visible"
        guideLabel.isHidden = false

//        feedbackLabel.isHidden = true
//        feedbackBackgroundView.isHidden = true

        // إخفاء التعليمات بعد ٣ ثواني
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.guideLabel.isHidden = true
        }

        updateUILabelsWithPrediction(.startingPrediction)
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
        updateUILabelsWithPrediction(.startingPrediction)
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

// MARK: - Video Processing Chain Delegate
extension MainViewController: VideoProcessingChainDelegate {
    func videoProcessingChain(_ chain: VideoProcessingChain, didPredict actionPrediction: ActionPrediction, for frameCount: Int) {
        if actionPrediction.isModelLabel {
            addFrameCount(frameCount, to: actionPrediction.label)
        }

        // إظهار التغذية الراجعة
        let isCorrect = (actionPrediction.confidence ?? 0) >= 0.9
        showFeedback(isCorrect: isCorrect)

        updateUILabelsWithPrediction(actionPrediction)
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

    private func updateUILabelsWithPrediction(_ prediction: ActionPrediction) {
       // DispatchQueue.main.async { self.actionLabel.text = prediction.label }
        let confidenceString = prediction.confidenceString ?? "Observing..."
      //  DispatchQueue.main.async { self.confidenceLabel.text = confidenceString }
    }

    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
        let renderFormat = UIGraphicsImageRendererFormat()
        renderFormat.scale = 1.0

        let frameSize = CGSize(width: frame.width, height: frame.height)
        let poseRenderer = UIGraphicsImageRenderer(size: frameSize, format: renderFormat)

        let frameWithPosesRendering = poseRenderer.image { rendererContext in
            let cgContext = rendererContext.cgContext
            let inverse = cgContext.ctm.inverted()
            cgContext.concatenate(inverse)
            let imageRectangle = CGRect(origin: .zero, size: frameSize)
            cgContext.draw(frame, in: imageRectangle)

            let pointTransform = CGAffineTransform(scaleX: frameSize.width, y: frameSize.height)
            guard let poses = poses else { return }

            for pose in poses {
                pose.drawWireframeToContext(cgContext, applying: pointTransform)
            }
        }

        DispatchQueue.main.async { self.imageView.image = frameWithPosesRendering }
    }

    // ✅ تغذية راجعة للحركة
//    private func showFeedback(isCorrect: Bool) {
//        feedbackLabel.text = isCorrect ? "Excellent! Keep going!✅" : "Wrong Move!❌"
//        feedbackBackgroundView.backgroundColor = isCorrect ? .systemGreen : .systemRed
//
//        feedbackLabel.isHidden = false
//        feedbackBackgroundView.isHidden = false
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.feedbackLabel.isHidden = true
//            self.feedbackBackgroundView.isHidden = true
//        }
//    }
    private func showFeedback(isCorrect: Bool) {
        let feedback = isCorrect ? "✅ Excellent!" : "❌ Wrong Move!"
        DispatchQueue.main.async {
            self.actionLabel.text = feedback
        }
    }


}
