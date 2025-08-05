//
//  CameraService.swift
//  BaiTapVeAnh
//
//  Created by Admin on 5/8/25.
//

import Foundation
import AVFoundation
import UIKit
protocol CameraServiceDelegate: AnyObject {
    func addPhoto(_ image: UIImage)
}
class CameraService:NSObject{
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var changeFlashMode: FlashMode = .off
    var isUsingFrontCamera = false
    weak var cameraServiceDelegate: CameraServiceDelegate?
    var updatePreview: ((UIView)->Void)?
    
    func setUpCamera(capturePreviewView:UIView){
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
    
    func switchCamera() {
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
    
    func changeFlashModeFunc(toggleFlashButton:UIButton) {
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
    
    func capturePhoto() {
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
        if let photoOutput{
            photoOutput.capturePhoto(with: settings, delegate: self)
        } else {
            print("Không có flash")
        }
    }
    
    func stopCamera(){
        captureSession.stopRunning()
    }
    
    func setFrame(frame: CGRect){
        self.previewLayer?.frame = frame
    }
}
extension CameraService:AVCapturePhotoCaptureDelegate{
    enum FlashMode:Int{
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
            cameraServiceDelegate?.addPhoto(image)
        }
    }
}
