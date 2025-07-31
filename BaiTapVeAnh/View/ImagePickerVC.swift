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
    var maxImageCount: Int = 100
    var numberOfImage: Int = 3
    var listImage: [UIImage] = []{
        didSet{
            chosenImageViews.forEach { imageView in
                imageView.image = listImage[imageView.tag]
            }
        }
    }
    private var finalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
//    import UIKit

    // Ensure this runs on the main thread since UIKit drawing must occur on it.
    func generateCompressedThumbnail(from finalImageView: UIImageView) -> UIImage? {
        let size = finalImageView.bounds.size
        let frame = CGRect(origin: .zero, size: size)

        // Begin graphics context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        finalImageView.draw(frame)
        
        // Get image from current context
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Compress the image to JPEG with 80% quality
        if let renderedImage = renderedImage,
           let jpegData = renderedImage.jpegData(compressionQuality: 0.8) {
            return UIImage(data: jpegData)
        } else {
            return nil
        }
    }

    @IBAction func add(_ sender: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = maxImageCount
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    func drawImage(image: UIImage, frame: CGRect){
        
    }
    @IBAction func createPoster(_ sender: Any) {
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
//            let frame2 = CGRect(x: width/4, y: 0, width: width/2, height: height)
//            listImage[1].draw(in: frame2)
        }
        finalImage = img
        finalImageView.image = img
    }
}
extension ImagePickerVC: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        var listImage: [UIImage] = []
        for i in 0..<results.count{
            var res = results[i]
            if(res.itemProvider.canLoadObject(ofClass: UIImage.self)){
                res.itemProvider.loadObject(ofClass: UIImage.self) { [weak self]image, error in
                    listImage.append(image as! UIImage)
                    if(listImage.count == self?.numberOfImage){
                        DispatchQueue.main.sync {
                            self?.listImage = listImage
                        }
                    }
                }
            }
        }
//        results.forEach { res in
//            if(res.itemProvider.canLoadObject(ofClass: UIImage.self)){
//                res.itemProvider.loadObject(ofClass: UIImage.self) { [weak self]image, error in
//                    listImage.append(image as! UIImage)
//                    if(listImage.count == self?.numberOfImage){
//                        DispatchQueue.main.sync {
//                            self?.listImage = listImage
//                        }
//                    }
//                }
//            }
//        }
    }
}
