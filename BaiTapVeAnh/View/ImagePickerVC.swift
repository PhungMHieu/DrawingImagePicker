//
//  ImagePickerVC.swift
//  BaiTapVeAnh
//
//  Created by iKame Elite Fresher 2025 on 30/7/25.
//

import UIKit
import PhotosUI
class ImagePickerVC: UIViewController{
    @IBOutlet var addImageBtn: [UIButton]!
    @IBOutlet var chosenImageViews: [UIImageView]!
    @IBOutlet var nameTextFields: [UITextField]!
    @IBOutlet var finalImageView: UIImageView!
    
    var maxImageCount: Int = 5
    var listImage: [UIImage] = [] {
        didSet{
            for imageView in chosenImageViews {
                if(imageView.tag < listImage.count){
                    imageView.image = listImage[imageView.tag]
                }
            }
        }
    }

    private var listText: [NSAttributedString] {
        return nameTextFields.sorted { $0.tag < $1.tag }.map({ nameTextField in
                .init(string: nameTextField.text ?? "Khuyết danh", attributes: textAttributes)
        })
    }
    private var finalImage: UIImage?
    
    
    lazy var textAttributes: [NSAttributedString.Key: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [
            .font: UIFont.systemFont(ofSize: 16, weight: .heavy),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EF - Meme Generator"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            view.addGestureRecognizer(tapGesture)
    }
    
    func drawLineSeperate (numOfImage:Int,singleImageWidth:CGFloat,additionWidth:CGFloat,height:CGFloat) {
        let path =  UIBezierPath()
        for i in 1..<numOfImage {
            let iCGFloat = CGFloat(i)
            if(i % 2 != 0) {
                path.move(to: CGPoint(x: (iCGFloat*singleImageWidth)-additionWidth, y: 0))
                path.addLine(to: CGPoint(x: (iCGFloat*singleImageWidth)+additionWidth, y: height))
            }
            else{
                path.move(to: CGPoint(x: (iCGFloat*singleImageWidth)+additionWidth, y: 0))
                path.addLine(to: CGPoint(x: (iCGFloat*singleImageWidth)-additionWidth, y: height))
            }
        }
        UIColor.white.setStroke()
        path.lineWidth = 4
        path.stroke()
        path.close()
    }
    
    func drawText(height: CGFloat, width: CGFloat, textBoundHeight: CGFloat) {
        UIColor.systemBrown.setFill()
        UIBezierPath(rect: CGRect(origin: .init(x: .zero, y: height), size: .init(width: width, height: textBoundHeight))).fill()
        
        let listAttributedText = listText
        let numOfImage: Int = listImage.count
        for i in 0..<listImage.count {
            listAttributedText[i].draw(in: .init(x: CGFloat(i)*width/CGFloat(numOfImage), y: height, width: width/CGFloat(numOfImage), height: textBoundHeight))
        }
    }
    
    func drawImageWithoutDistorted(_ image: UIImage, in frame: CGRect) {
        let imageAspect = image.size.width / image.size.height
        let frameAspect = frame.width / frame.height
        
        var drawRect = frame
        if imageAspect > frameAspect {
            // Ảnh rộng hơn → crop 2 bên
            let scale = frame.height / image.size.height
            let width = image.size.width * scale
            drawRect.origin.x = frame.midX - width / 2
            drawRect.size.width = width
        } else {
            // Ảnh cao hơn → crop trên dưới
            let scale = frame.width / image.size.width
            let height = image.size.height * scale
            drawRect.origin.y = frame.midY - height / 2
            drawRect.size.height = height
        }
        image.draw(in: drawRect)
    }
    
    func drawPathAroundImage(startPoint: CGPoint,linePoint1: CGPoint, linePoint2: CGPoint, linePoint3: CGPoint, i:Int, path: UIBezierPath) {
        path.move(to: startPoint)
        path.addLine(to: linePoint1)
        path.addLine(to: linePoint2)
        path.addLine(to: linePoint3)
        path.close()
        path.addClip()
    }
    
    func drawImage(finalImageView: UIImageView, numOfImage: Int) {
        let frame = finalImageView.bounds
        let textBoundHeight:CGFloat = 24
        let width = frame.width
        let height = frame.height - textBoundHeight
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(bounds: frame, format: rendererFormat)
        let additionWidth:CGFloat = width / CGFloat(6*numOfImage)
        let singleImageWidth = (width/CGFloat(numOfImage))
        
        if(numOfImage % 2 != 0) {
            let img = renderer.image { ctx in
                for i in 0..<numOfImage {
                    if(i%2 == 0) {
                        let path =  UIBezierPath()
                        let iCGFloat = CGFloat(i)
                        let numOfImageCGFloat:CGFloat = CGFloat(numOfImage)
                        print(i)
                        if(i == 0) {
                            let startPoint = CGPoint(x: (iCGFloat*width/numOfImageCGFloat), y: 0)
                            let linePoint1 = CGPoint(x: (iCGFloat*singleImageWidth), y: height)
                            let linePoint2 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: height)
                            let linePoint3 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: 0)
                            drawPathAroundImage(startPoint: startPoint, linePoint1: linePoint1, linePoint2: linePoint2, linePoint3: linePoint3, i: i,path: path)
                            let frame = CGRect(x: width*CGFloat(i)/CGFloat(numOfImage), y: 0, width: singleImageWidth+CGFloat(additionWidth), height: height)
                            drawImageWithoutDistorted(listImage[i], in: frame)
                            UIGraphicsGetCurrentContext()?.resetClip()
                        } else if(i == numOfImage-1) {
                            let startPoint = CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-CGFloat(additionWidth), y: 0)
                            let linePoint1 = CGPoint(x: (iCGFloat*singleImageWidth)-CGFloat(additionWidth), y: height)
                            let linePoint2 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: height)
                            let linePoint3 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: 0)
                            drawPathAroundImage(startPoint: startPoint, linePoint1: linePoint1, linePoint2: linePoint2, linePoint3: linePoint3, i: i,path:path)
                            let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage) - additionWidth, y: 0, width: singleImageWidth+CGFloat(additionWidth), height: height)
                            drawImageWithoutDistorted(listImage[i], in: frame)
                            UIGraphicsGetCurrentContext()?.resetClip()
                        } else {
                            let startPoint = CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-(CGFloat(additionWidth)), y: 0)
                            let linePoint1 = CGPoint(x: (iCGFloat*singleImageWidth)-(CGFloat(additionWidth)), y: height)
                            let linePoint2 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+2*(CGFloat(additionWidth)), y: height)
                            let linePoint3 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+2*(CGFloat(additionWidth)), y:0)
                            drawPathAroundImage(startPoint: startPoint, linePoint1: linePoint1, linePoint2: linePoint2, linePoint3: linePoint3, i: i,path:path)
                            let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: singleImageWidth+2*additionWidth, height: height)
                            drawImageWithoutDistorted(listImage[i], in: frame)
                            UIGraphicsGetCurrentContext()?.resetClip()
                        }
                    }
                }
                for i in 1..<numOfImage {
                    let path =  UIBezierPath()
                    let iCGFloat = CGFloat(i)
                    let numOfImageCGFloat:CGFloat = CGFloat(numOfImage)
                    if(i % 2 != 0) {
                        let startPoint = CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-(CGFloat(additionWidth)), y: 0)
                        let linePoint1 = CGPoint(x: (iCGFloat*singleImageWidth)+(CGFloat(additionWidth)), y: height)
                        let linePoint2 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)-(CGFloat(additionWidth)), y: height)
                        let linePoint3 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: 0)
                        drawPathAroundImage(startPoint: startPoint, linePoint1: linePoint1, linePoint2: linePoint2, linePoint3: linePoint3, i: i,path: path)
                        let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: width/CGFloat(numOfImage)+2*additionWidth, height: height)
                        drawImageWithoutDistorted(listImage[i], in: frame)
                        UIGraphicsGetCurrentContext()?.resetClip()
                    }
                }
                drawLineSeperate(numOfImage: numOfImage, singleImageWidth: singleImageWidth, additionWidth: additionWidth, height: height)
                drawText(height: height, width: width, textBoundHeight: textBoundHeight)
            }
            finalImage = img
            finalImageView.image = img
            
        } else {
            let img = renderer.image { ctx in
                for i in 0..<numOfImage {
                    if(i%2 == 0) {
                        let path =  UIBezierPath()
                        let iCGFloat = CGFloat(i)
                        let numOfImageCGFloat:CGFloat = CGFloat(numOfImage)
                        if(i == 0) {
                            let startPoint = CGPoint(x: (iCGFloat*width/numOfImageCGFloat), y: 0)
                            let linePoint1 = CGPoint(x: (iCGFloat*singleImageWidth), y: height)
                            let linePoint2 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: height)
                            let linePoint3 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: 0)
                            drawPathAroundImage(startPoint: startPoint, linePoint1: linePoint1, linePoint2: linePoint2, linePoint3: linePoint3, i: i,path: path)
                            let frame = CGRect(x: width*CGFloat(i)/CGFloat(numOfImage), y: 0, width: singleImageWidth+CGFloat(additionWidth), height: height)
                            drawImageWithoutDistorted(listImage[i], in: frame)
                            UIGraphicsGetCurrentContext()?.resetClip()
                        }
                        else {
                            let startPoint = CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-(CGFloat(additionWidth)), y: 0)
                            let linePoint1 = CGPoint(x: (iCGFloat*singleImageWidth)-(CGFloat(additionWidth)), y: height)
                            let linePoint2 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+2*(CGFloat(additionWidth)), y: height)
                            let linePoint3 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+2*(CGFloat(additionWidth)), y:0)
                            drawPathAroundImage(startPoint: startPoint, linePoint1: linePoint1, linePoint2: linePoint2, linePoint3: linePoint3, i: i,path: path)
                            let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: singleImageWidth+2*additionWidth, height: height)
                            drawImageWithoutDistorted(listImage[i], in: frame)
                            UIGraphicsGetCurrentContext()?.resetClip()
                        }
                    }
                }
                for i in 1..<numOfImage {
                    let path =  UIBezierPath()
                    let iCGFloat = CGFloat(i)
                    let numOfImageCGFloat:CGFloat = CGFloat(numOfImage)
                    if(i % 2 != 0 && i != numOfImage-1) {
                        let startPoint = CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-(CGFloat(additionWidth)), y: 0)
                        let linePoint1 = CGPoint(x: (iCGFloat*singleImageWidth)+(CGFloat(additionWidth)), y: height)
                        let linePoint2 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)-(CGFloat(additionWidth)), y: height)
                        let linePoint3 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: 0)
                        drawPathAroundImage(startPoint: startPoint, linePoint1: linePoint1, linePoint2: linePoint2, linePoint3: linePoint3, i: i,path:path)
                        let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: width/CGFloat(numOfImage)+2*additionWidth, height: height)
                        drawImageWithoutDistorted(listImage[i], in: frame)
                        UIGraphicsGetCurrentContext()?.resetClip()
                    } else if(i == numOfImage - 1) {
                        let startPoint = CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-(CGFloat(additionWidth)), y: 0)
                        let linePoint1 = CGPoint(x: (iCGFloat*singleImageWidth)+(CGFloat(additionWidth)), y: height)
                        let linePoint2 = CGPoint(x: ((iCGFloat+1)*singleImageWidth), y: height)
                        let linePoint3 = CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: 0)
                        drawPathAroundImage(startPoint: startPoint, linePoint1: linePoint1, linePoint2: linePoint2, linePoint3: linePoint3, i: i,path:path)
                        let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: width/CGFloat(numOfImage)+2*additionWidth, height: height)
                        drawImageWithoutDistorted(listImage[i], in: frame)
                        UIGraphicsGetCurrentContext()?.resetClip()
                    }
                }
                drawLineSeperate(numOfImage: numOfImage, singleImageWidth: singleImageWidth, additionWidth: additionWidth, height: height)
                drawText(height: height, width: width, textBoundHeight: textBoundHeight)
            }
            finalImage = img
            finalImageView.image = img
        }
    }
    
    func resetData() {
        for imageView in chosenImageViews {
            imageView.image = nil
        }
        for textField in nameTextFields {
            textField.text = ""
        }
        listImage.removeAll()
    }
    
    func notificationAboutImageOverLoad() {
        let alert = UIAlertController(title: "Thông báo", message: "Số lượng đã vượt quá giới hạn", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: UIButton) {
        if self.listImage.count < maxImageCount {
            presentImagePicker()
        } else {
            notificationAboutImageOverLoad()
        }
    }
    
    @IBAction func createPoster(_ sender: Any) {
        if(!listImage.isEmpty) {
            drawImage(finalImageView: self.finalImageView,numOfImage: listImage.count)
            resetData()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if let image = finalImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            finalImageView.image = nil
            finalImage = nil
        }
    }
    
    @IBAction func takeScreenShot(_ sender: Any) {
        if (listImage.count >= maxImageCount) {
            notificationAboutImageOverLoad()
        } else {
            let cameraVC = CameraVC()
            cameraVC.addImage = {[weak self] image in
                guard let self = self else { return }
                self.listImage.append(image)
                if(self.listImage.count >= maxImageCount) {
                    self.dismiss(animated: true)
                }
            }
            cameraVC.modalPresentationStyle = .fullScreen
            present(cameraVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func reNewData(_ sender: Any) {
        resetData()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

extension ImagePickerVC: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for i in 0..<results.count {
            let res = results[i]
            if(res.itemProvider.canLoadObject(ofClass: UIImage.self)) {
                res.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        self?.listImage.append(image as! UIImage)
                    }
                }
            }
        }
    }
    
    func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = maxImageCount
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}
