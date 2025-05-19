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
    @IBOutlet weak var guideContainerView: UIView!
    @IBOutlet weak var feedbackContainerView: UIView!
    @IBOutlet weak var feedbackLabel: UILabel!

    var videoCapture: VideoCapture!
    var videoProcessingChain: VideoProcessingChain!
    var actionFrameCounts = [String: Int]()
    
    // ✅ عشان نمنع التقييم أثناء عرض الدليل
    private var guideHasDisappeared = false
    var isFeedbackVisible = false

}

// MARK: - View Controller Events
extension MainViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(UIColor(named: "PrimaryPurple"), for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = UIColor(named: "PrimaryPurple")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        // حط الزر في يسار الناف بار
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        imageView.contentMode = .scaleAspectFill
        setupUI()
        
        feedbackContainerView.layer.cornerRadius = 20
        feedbackContainerView.clipsToBounds = true


        // ✅ عرض دليل البداية ثم إخفاؤه
        guideContainerView.isHidden = false
        guideLabel.text = "Make sure your full body is visible"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.guideContainerView.isHidden = true
            self.guideHasDisappeared = true
        }

        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.delegate = self

        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.isEnabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCapture.updateDeviceOrientation()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        videoCapture.updateDeviceOrientation()
    }

    private func setupUI() {
        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryPurple")
        let views = [labelStack, buttonStack, cameraButton, summaryButton]
        views.forEach {
            $0?.layer.cornerRadius = 10
            $0?.overrideUserInterfaceStyle = .dark
        }
        feedbackContainerView.isHidden = true
        feedbackContainerView.alpha = 0
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
        showFeedbackResult(isCorrect: isCorrect)
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

    private func showFeedbackResult(isCorrect: Bool) {
        guard guideHasDisappeared else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showFeedbackResult(isCorrect: isCorrect)
            }
            return
        }

        DispatchQueue.main.async {
            self.feedbackContainerView.backgroundColor = isCorrect
                ? UIColor(red: 0.65, green: 1.0, blue: 0.0157, alpha: 0.65)
                : UIColor.red.withAlphaComponent(0.65)

            self.feedbackLabel.text = isCorrect ? "Excellent!" : "Wrong Move!"
            self.feedbackLabel.textColor = .white


            self.feedbackContainerView.alpha = 1
            self.feedbackContainerView.isHidden = false

            // ✅ إظهار بدون أنيميشن إذا كان ظاهر مسبقًا
            if self.isFeedbackVisible == false {
                self.feedbackContainerView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.feedbackContainerView.alpha = 1
                }
            }

            self.isFeedbackVisible = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.feedbackContainerView.alpha = 0
                }) { _ in
                    self.feedbackContainerView.isHidden = true
                    self.isFeedbackVisible = false
                }
            }
        }
    }
    @objc private func handleBackButton() {
        navigationController?.popViewController(animated: true)
    }

}
