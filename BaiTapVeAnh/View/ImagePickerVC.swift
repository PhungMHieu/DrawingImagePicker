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
    var maxImageCount: Int = 100
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
            print("❌ Thiết bị không hỗ trợ camera")
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
    func drawImage(finalImageView: UIImageView){
        let frame = finalImageView.bounds
        let textBoundHeight:CGFloat = 24
        let width = frame.width
        let height = frame.height - textBoundHeight
        let renderer = UIGraphicsImageRenderer(bounds: frame)
        let img = renderer.image { ctx in
            let frame1 = CGRect(x: 0, y: 0, width:width*7/20, height: height)
            let frame3 = CGRect(x: width*13/20, y: 0, width: width*7/20, height: height)
            listImage[0].draw(in: frame1)
            listImage[2].draw(in: frame3)
            
            let rectPath = UIBezierPath()
            rectPath.move(to: CGPoint(x: width/4, y: 0))
            rectPath.addLine(to: CGPoint(x: 7*width/20, y: height))
            rectPath.addLine(to: CGPoint(x: 13*width/20, y: height))
            rectPath.addLine(to: CGPoint(x: 3*width/4, y: 0))
            rectPath.close()
            
            rectPath.addClip()
            let frame2 = CGRect(x: width/4, y: 0, width: width/2, height: height)
            listImage[1].draw(in: frame2)
            UIGraphicsGetCurrentContext()?.resetClip()
            
            let borderPath = UIBezierPath()
            borderPath.move(to: CGPoint(x: width/4, y: 0))
            borderPath.addLine(to: CGPoint(x: 7*width/20, y: height))
            borderPath.move(to: CGPoint(x: width*3/4, y: 0))
            borderPath.addLine(to: CGPoint(x: 13*width/20, y: height))
            UIColor.white.setStroke()
            borderPath.lineWidth = 4
            borderPath.stroke()
            
            UIColor.systemTeal.setFill()
            UIBezierPath(rect: CGRect(origin: .init(x: .zero, y: height), size: .init(width: width, height: textBoundHeight))).fill()
            
            let listAttributedText = listText
            listAttributedText[0].draw(in: .init(x: 0, y: height, width: width/3, height: textBoundHeight))
            listAttributedText[1].draw(in: .init(x: width/3, y: height, width: width/3, height: textBoundHeight))
            listAttributedText[2].draw(in: .init(x: width * 2/3, y: height, width: width/3, height: textBoundHeight))
        }
        finalImage = img
        finalImageView.image = img
    }
    func resetData(){
        for imageView in chosenImageViews {
            imageView.image = nil
        }
        
        // Reset text field
        for textField in nameTextFields {
            textField.text = ""
        }
        
        // Reset biến dữ liệu
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
        drawImage(finalImageView: self.finalImageView)
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
extension ImagePickerVC: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        //        var listImage: [UIImage] = Array(repeating: UIImage(), count: results.count)
        for i in 0..<results.count{
            let res = results[i]
            if(res.itemProvider.canLoadObject(ofClass: UIImage.self)){
                res.itemProvider.loadObject(ofClass: UIImage.self) { [weak self]image, error in
                    //                    listImage[i] = image as! UIImage
                    //                    if(listImage.count == self?.numberOfImage){
                    DispatchQueue.main.sync {
                        self?.listImage.append(image as! UIImage)
                    }
                    //                    }
                }
            }
        }
    }
}
