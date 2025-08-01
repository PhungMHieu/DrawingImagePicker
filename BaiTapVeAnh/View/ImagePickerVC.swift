//
//  ImagePickerVC.swift
//  BaiTapVeAnh
//
//  Created by iKame Elite Fresher 2025 on 30/7/25.
//

import UIKit
import PhotosUI
class ImagePickerVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    @IBOutlet var addImageBtn: [UIButton]!
    @IBOutlet var chosenImageViews: [UIImageView]!
    @IBOutlet var nameTextFields: [UITextField]!
    @IBOutlet var finalImageView: UIImageView!
    var maxImageCount: Int = 5
    var numberOfImage: Int = 3
    var listImage: [UIImage] = []{
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            view.addGestureRecognizer(tapGesture)
    }
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Thiết bị không hỗ trợ camera")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = self
        
        DispatchQueue.main.async {
            self.present(picker, animated: true)
        }
    }
    func drawLineSeperate(numOfImage:Int,singleImageWidth:CGFloat,additionWidth:CGFloat,height:CGFloat){
        let path =  UIBezierPath()
        for i in 1..<numOfImage{
            let iCGFloat = CGFloat(i)
            if(i % 2 != 0){
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
    func drawText(height: CGFloat, width: CGFloat, textBoundHeight: CGFloat){
        UIColor.systemBrown.setFill()
        UIBezierPath(rect: CGRect(origin: .init(x: .zero, y: height), size: .init(width: width, height: textBoundHeight))).fill()
        
        let listAttributedText = listText
        listAttributedText[0].draw(in: .init(x: 0, y: height, width: width/5, height: textBoundHeight))
        listAttributedText[1].draw(in: .init(x: width/5, y: height, width: width/5, height: textBoundHeight))
        listAttributedText[2].draw(in: .init(x: width * 2/5, y: height, width: width/5, height: textBoundHeight))
        listAttributedText[3].draw(in: .init(x: width * 3/5, y: height, width: width/5, height: textBoundHeight))
        listAttributedText[4].draw(in: .init(x: width * 4/5, y: height, width: width/5, height: textBoundHeight))
    }
    func drawImageWithoutDistorted(_ image: UIImage, in frame: CGRect){
        let imageAspect = image.size.width / image.size.height
        let frameAspect = frame.width / frame.height

        var drawRect = frame
        if imageAspect > frameAspect {
            // Ảnh rộng hơn khung → scale theo chiều dọc, crop 2 bên
            let scale = frame.height / image.size.height
            let width = image.size.width * scale
            drawRect.origin.x += (frame.width - width) / 2
            drawRect.size.width = width
        } else {
            // Ảnh cao hơn khung → scale theo chiều ngang, crop trên dưới
            let scale = frame.width / image.size.width
            let height = image.size.height * scale
            drawRect.origin.y += (frame.height - height) / 2
            drawRect.size.height = height
        }
        image.draw(in: drawRect)
    }
    func drawImage(finalImageView: UIImageView, numOfImage: Int){
        let frame = finalImageView.bounds
        let textBoundHeight:CGFloat = 24
        let width = frame.width
        let height = frame.height - textBoundHeight
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(bounds: frame, format: rendererFormat)
        let additionWidth:CGFloat = width / CGFloat(6*numOfImage)
        let singleImageWidth = (width/CGFloat(numOfImage))
        if(numOfImage % 2 != 0){
            let img = renderer.image { ctx in
                for i in 0..<numOfImage{
                    if(i%2 == 0){
                        if(i == 0){
                            let width = singleImageWidth+CGFloat(additionWidth)
                            let frame = CGRect(x: width*CGFloat(i)/CGFloat(numOfImage), y: 0, width: singleImageWidth+CGFloat(additionWidth), height: height)
                            listImage[i].draw(in: frame)
                        }else if(i == numOfImage-1){
                            let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage) - additionWidth, y: 0, width: singleImageWidth+CGFloat(additionWidth), height: height)
                            listImage[i].draw(in: frame)
                        }else{
                            let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: singleImageWidth+2*additionWidth, height: height)
                            listImage[i].draw(in: frame)
                        }
                    }
                }
                for i in 1..<numOfImage{
                    let path =  UIBezierPath()
                    let iCGFloat = CGFloat(i)
                    let numOfImageCGFloat:CGFloat = CGFloat(numOfImage)
                    if(i % 2 != 0){
                        print(i)
                        path.move(to: CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-(CGFloat(additionWidth)), y: 0))
                        path.addLine(to: CGPoint(x: (iCGFloat*singleImageWidth)+(CGFloat(additionWidth)), y: height))
                        path.addLine(to: CGPoint(x: ((iCGFloat+1)*singleImageWidth)-(CGFloat(additionWidth)), y: height))
                        path.addLine(to: CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: 0))
                        path.close()
                        path.addClip()
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
            
        }else{
            let img = renderer.image { ctx in
                for i in 0..<numOfImage{
                    if(i%2 == 0){
                        if(i == 0){
                            let width = singleImageWidth+CGFloat(additionWidth)
                            let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage), y: 0, width: singleImageWidth+CGFloat(additionWidth), height: height)
                            listImage[i].draw(in: frame)
                        }
                        else{
                            let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: singleImageWidth+2*additionWidth, height: height)
                            listImage[i].draw(in: frame)
                        }
                    }
                }
                for i in 1..<numOfImage{
                    let path =  UIBezierPath()
                    let iCGFloat = CGFloat(i)
                    let numOfImageCGFloat:CGFloat = CGFloat(numOfImage)
                    if(i % 2 != 0 && i != numOfImage-1){
                        path.move(to: CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-(CGFloat(additionWidth)), y: 0))
                        path.addLine(to: CGPoint(x: (iCGFloat*singleImageWidth)+(CGFloat(additionWidth)), y: height))
                        path.addLine(to: CGPoint(x: ((iCGFloat+1)*singleImageWidth)-(CGFloat(additionWidth)), y: height))
                        path.addLine(to: CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: 0))
                        path.close()
                        path.addClip()
                        let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: width/CGFloat(numOfImage)+2*additionWidth, height: height)
                        drawImageWithoutDistorted(listImage[i], in: frame)
                        UIGraphicsGetCurrentContext()?.resetClip()
                    }else if(i == numOfImage - 1){
                        path.move(to: CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-(CGFloat(additionWidth)), y: 0))
                        path.addLine(to: CGPoint(x: (iCGFloat*singleImageWidth)+(CGFloat(additionWidth)), y: height))
                        path.addLine(to: CGPoint(x: ((iCGFloat+1)*singleImageWidth), y: height))
                        path.addLine(to: CGPoint(x: ((iCGFloat+1)*singleImageWidth)+(CGFloat(additionWidth)), y: 0))
                        path.close()
                        path.addClip()
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
    func resetData(){
        for imageView in chosenImageViews {
            imageView.image = nil
        }
        for textField in nameTextFields {
            textField.text = ""
        }
        listImage.removeAll()
    }
    @IBAction func add(_ sender: UIButton) {
        resetData()
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = maxImageCount
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        
    }
    @IBAction func createPoster(_ sender: Any) {
        drawImage(finalImageView: self.finalImageView,numOfImage: listImage.count)
        resetData()
    }
    @IBAction func save(_ sender: Any) {
        if let image = finalImage{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            finalImageView.image = nil
            finalImage = nil
        }
    }
    @IBAction func takeScreenShot(_ sender: Any) {
        openCamera()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
extension ImagePickerVC: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for i in 0..<results.count{
            let res = results[i]
            if(res.itemProvider.canLoadObject(ofClass: UIImage.self)){
                res.itemProvider.loadObject(ofClass: UIImage.self) { [weak self]image, error in
                    DispatchQueue.main.async {
                        self?.listImage.append(image as! UIImage)
                    }
                }
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            listImage.append(image)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }else{
            print("Không lấy được ảnh từ thư viện")
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
