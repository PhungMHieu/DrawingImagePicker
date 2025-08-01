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
    func drawImage(finalImageView: UIImageView, numOfImage: Int){
        let frame = finalImageView.bounds
        let textBoundHeight:CGFloat = 24
        let width = frame.width
        let height = frame.height - textBoundHeight
        let renderer = UIGraphicsImageRenderer(bounds: frame)
        let additionWidth:CGFloat = width / CGFloat(4*numOfImage)
        let singleImageWidth = (width/CGFloat(numOfImage))
        let img = renderer.image { ctx in
            for i in 0..<numOfImage{
                if(i%2 == 0){
                   
                    if(i == 0){
                        let width = singleImageWidth+CGFloat(additionWidth)
                        let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage), y: 0, width: singleImageWidth+CGFloat(additionWidth), height: height)
                        listImage[i].draw(in: frame)
                    }else if(i == numOfImage-1){
                        let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage) - additionWidth, y: 0, width: singleImageWidth+CGFloat(additionWidth), height: height)
                        listImage[i].draw(in: frame)
                    }else{
                        let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: width/CGFloat(numOfImage)+2*additionWidth, height: height)
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
                    path.addLine(to: CGPoint(x: (iCGFloat*width/numOfImageCGFloat)+(CGFloat(additionWidth)), y: height))
                    path.addLine(to: CGPoint(x: ((iCGFloat+1)*width/numOfImageCGFloat)-(CGFloat(additionWidth)), y: height))
                    path.addLine(to: CGPoint(x: ((iCGFloat+1)*width/numOfImageCGFloat)+(CGFloat(additionWidth)), y: 0))
                    path.close()
//                    UIColor.white.setStroke()
//                    path.lineWidth = 4
//                    path.stroke()
                    path.close()
                    path.addClip()
                    let frame = CGRect(x: CGFloat(i)*width/CGFloat(numOfImage)-additionWidth, y: 0, width: width/CGFloat(numOfImage)+2*additionWidth, height: height)
                    listImage[i].draw(in: frame)
                    // Bỏ clip đi để còn vẽ típ
                    UIGraphicsGetCurrentContext()?.resetClip()
                }
//                else{
//                    path.move(to: CGPoint(x: (iCGFloat*width/numOfImageCGFloat)+(width/(4*numOfImageCGFloat)), y: 0))
//                    path.addLine(to: CGPoint(x: (iCGFloat*width/numOfImageCGFloat)-(width/(4*numOfImageCGFloat)), y: height))
//                }
            }
//            for i in 1
            UIColor.white.setStroke()
//            path.lineWidth = 4
//            path.stroke()
//            path.close()
//            path.addClip()
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
//        var listImage: [Int:UIImage] = [:]
        for i in 0..<results.count{
            let res = results[i]
            if(res.itemProvider.canLoadObject(ofClass: UIImage.self)){
                res.itemProvider.loadObject(ofClass: UIImage.self) { [weak self]image, error in
//                    listImage[i] = image as? UIImage
                    //                    listImage[i] = image as! UIImage
                    //                    if(listImage.count == self?.numberOfImage){
                    DispatchQueue.main.async {
                        self?.listImage.append(image as! UIImage)
                    }
                    //                    }
                }
            }
        }
    }
}
