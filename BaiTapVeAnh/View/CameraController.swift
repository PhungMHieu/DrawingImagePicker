//
//  CameraController.swift
//  BaiTapVeAnh
//
//  Created by iKame Elite Fresher 2025 on 4/8/25.
//

import Foundation
import AVFoundation
import UIKit

class CameraController {
    var captureSession:AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer:AVCaptureVideoPreviewLayer?
    var flashMode = AVCaptureDevice.FlashMode.off

}
extension CameraController{
    func prepare(completionHandler : @escaping (Error?)->Void){
        func createCaptureSession(){
            self.captureSession = AVCaptureSession()
        }
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            let cameras = session.devices
            guard !cameras.isEmpty else {
                throw CameraVCError.noCameraAvailable
            }
            for camera in cameras{
                if camera.position == .front{
                    self.frontCamera = camera
                }
                if camera.position == .back{
                    self.rearCamera = camera
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraVCError.captureSessionIsMissing
            }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                if captureSession.canAddInput((self.rearCameraInput!)){
                    captureSession.addInput(self.rearCameraInput!)
                }
                self.currentCameraPosition = .rear
            }
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                if captureSession.canAddInput(self.frontCameraInput!){
                    captureSession.addInput(self.frontCameraInput!)
                } else {
                    throw CameraVCError.inputsAreInvalid
                }
                
                self.currentCameraPosition = .front
            }
            else {
                throw CameraVCError.noCameraAvailable
            }
        }
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraVCError.captureSessionIsMissing
            }
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            if captureSession.canAddOutput(self.photoOutput!){
                captureSession.addOutput(self.photoOutput!)
            }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "").async {
            do{
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
        }
        DispatchQueue.main.async {
            completionHandler(nil)
        }
    }
    func displayPreview(on view: UIView) throws{
        guard let captureSession = self.captureSession, captureSession.isRunning else{
            throw CameraVCError.captureSessionIsMissing
        }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    func switchCameras() throws {
        //5
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraVCError.captureSessionIsMissing }

        //6
        captureSession.beginConfiguration()

        func switchToFrontCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
                    let frontCamera = self.frontCamera else { throw CameraVCError.invalidOperation }

                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)

                captureSession.removeInput(rearCameraInput)

                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)

                    self.currentCameraPosition = .front
                }

                else { throw CameraVCError.invalidOperation }
        }
        func switchToRearCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
                    let rearCamera = self.rearCamera else { throw CameraVCError.invalidOperation }

                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)

                captureSession.removeInput(frontCameraInput)

                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)

                    self.currentCameraPosition = .rear
                }

                else { throw CameraVCError.invalidOperation }
        }

        //7
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()

        case .rear:
            try switchToFrontCamera()
        }

        //8
        captureSession.commitConfiguration()
    }
}

extension CameraController{
    enum CameraVCError: Swift.Error{
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCameraAvailable
        case unknown
    }
    public enum CameraPosition{
        case front
        case rear
    }
}
