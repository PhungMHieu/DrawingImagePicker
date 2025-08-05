//
//  CameraVC.swift
//  BaiTapVeAnh
//
//  Created by Admin on 3/8/25.
//

import UIKit
import AVFoundation
import AudioToolbox


class CameraVC: UIViewController {
    
    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleFlashButton: UIButton!
    var addImage:((UIImage) -> Void)?
    
    private let cameraService:CameraService = CameraService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraService.setUpCamera(capturePreviewView: capturePreviewView)
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cameraService.setFrame(frame: self.capturePreviewView.bounds)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global().async {
            self.cameraService.stopCamera()
        }
    }
    
    func switchCameraAnimation(capturePreviewView:UIView) {
        let transitionOptions: UIView.AnimationOptions = cameraService.isUsingFrontCamera
        ? .transitionFlipFromLeft
        : .transitionFlipFromRight
        UIView.transition(with: capturePreviewView, duration: 0.3, options: transitionOptions, animations: nil, completion: nil)
    }
    
    func showCaptureAnimation() {
        let flashView = UIView(frame: capturePreviewView.bounds)
        flashView.backgroundColor = .neutral5
        flashView.alpha = 0
        capturePreviewView.addSubview(flashView)
        UIView.animate(withDuration: 0.5, animations: {
            flashView.alpha = 1
        }, completion: firstAnimationCompleted(_:))
        
        func firstAnimationCompleted(_ finished:Bool) {
            UIView.animate(withDuration: 0.1, animations: {
                flashView.alpha = 0
            }, completion: secondAnimationCompleted(_:))

        }
        
        func secondAnimationCompleted(_ finished:Bool) {
            flashView.removeFromSuperview()
        }
    }
    
    @IBAction func toggleFlash(_ sender: Any) {
        cameraService.changeFlashModeFunc(toggleFlashButton: toggleFlashButton)
    }
    
    @IBAction func toggleCamera(_ sender: Any) {
        switchCameraAnimation(capturePreviewView: capturePreviewView)
        cameraService.switchCamera()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func capturePhoto() {
        cameraService.cameraServiceDelegate = self
        cameraService.capturePhoto()
        showCaptureAnimation()
    }
}

extension CameraVC: CameraServiceDelegate {
    func addPhoto(_ image: UIImage) {
        self.addImage?(image)
    }
}
