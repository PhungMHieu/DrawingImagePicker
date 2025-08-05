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
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var changeFlashMode: FlashMode = .off
    var isUsingFrontCamera = false
    var addImage:((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCamera()
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.previewLayer?.frame = self.capturePreviewView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global().async {
            self.captureSession.stopRunning()
        }
    }
    
    func setUpCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Không tìm thấy camera sau")
            return
        }
        do  {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput){
                captureSession.addOutput(photoOutput)
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            capturePreviewView.layer.addSublayer(previewLayer)
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
        } catch {
            print("Lỗi khởi tạo camera: \(error)")
        }
    }
    
    func switchCameraAnimation() {
        let transitionOptions: UIView.AnimationOptions = isUsingFrontCamera
        ? .transitionFlipFromLeft
        : .transitionFlipFromRight
        UIView.transition(with: capturePreviewView, duration: 0.3, options: transitionOptions, animations: nil, completion: nil)
    }
    
    func switchCamera() {
        switchCameraAnimation()
        
        captureSession.beginConfiguration()
        if let currentInput = captureSession.inputs.first {
            captureSession.removeInput(currentInput)
        }
        let newPosition:AVCaptureDevice.Position = isUsingFrontCamera ? .back : .front
        if let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) {
            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                }
                isUsingFrontCamera.toggle()
            } catch {
                print("Không thể chuyển camera")
            }
        }
        
        if let output = photoOutput {
            if(!captureSession.outputs.contains(output)){
                if captureSession.canAddOutput(output){
                    captureSession.addOutput(output)
                }
            }
        }
        
        captureSession.commitConfiguration()
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
        switch changeFlashMode {
        case .off:
            changeFlashMode = .auto
            toggleFlashButton.setImage(.flashAuto, for: .normal)
        case .auto:
            changeFlashMode = .on
            toggleFlashButton.setImage(.flashOn, for: .normal)
        case .on:
            changeFlashMode = .off
            toggleFlashButton.setImage(.flashOff, for: .normal)
        }
    }
    
    @IBAction func toggleCamera(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        if let device = AVCaptureDevice.default(for: .video),
           device.hasFlash {
            switch changeFlashMode {
            case .auto:
                settings.flashMode = .auto
            case .off:
                settings.flashMode = .off
            case .on:
                settings.flashMode = .on
            }
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
        showCaptureAnimation()
        AudioServicesPlaySystemSound(1108)
    }
}

extension CameraVC:AVCapturePhotoCaptureDelegate{
    enum FlashMode{
        case auto
        case off
        case on
        var checkFlash:Bool{
            if self == .on{
                return true
            }else{
                return false
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.addImage?(image)
        }
    }
}
