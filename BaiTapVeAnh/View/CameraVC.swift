//
//  CameraVC.swift
//  BaiTapVeAnh
//
//  Created by Admin on 3/8/25.
//

import UIKit
import AVFoundation
class CameraVC: UIViewController , AVCapturePhotoCaptureDelegate{
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isFlashOn = false
    var isUsingFrontCamera = false
    
    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
    @IBOutlet weak var toggleFlashButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCamera()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.previewLayer?.frame = self.capturePreviewView.bounds
    }
    func setUpCamera(){
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
            
            captureSession.startRunning()
            captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        } catch {
            print("Lỗi khởi tạo camera: \(error)")
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data){
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    func switchCamera(){
        let transitionOptions: UIView.AnimationOptions = isUsingFrontCamera
        ? .transitionFlipFromLeft
        : .transitionFlipFromRight
        UIView.transition(with: capturePreviewView, duration: 0.3, options: transitionOptions, animations: nil, completion: nil)
        captureSession.beginConfiguration()
        if let currentInput = captureSession.inputs.first {
            captureSession.removeInput(currentInput)
        }
        let newPosition:AVCaptureDevice.Position = isUsingFrontCamera ? .back : .front
        if let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition){
            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)
                if captureSession.canAddInput(newInput){
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
    @IBAction func toggleFlash(_ sender: Any) {
        isFlashOn.toggle()
        if isFlashOn{
            toggleFlashButton.setImage(.flashOn, for: .normal)
        }else{
            toggleFlashButton.setImage(.flashOff, for: .normal)
        }
    }
    
    @IBAction func toggleCamera(_ sender: Any) {
        switchCamera()
    }
    @objc func capturePhoto(){
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        if let device = AVCaptureDevice.default(for: .video),
           device.hasFlash {
            settings.flashMode = isFlashOn ? .on : .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}
