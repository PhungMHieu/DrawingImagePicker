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
    //    @IBOutlet weak var chosenImageView: UIImageView!
    var maxImageCount: Int = 100
    var indexImage:Int = .zero
    var listImage:[UIImage] = []{
        didSet{
            if !listImage.isEmpty {
                chosenImageViews.forEach{$0.image = listImage[$0.tag]}
                //                self.chosenImageViews[indexImage].image = listImage[indexImage]
            }
            print("listImage: \(listImage)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func add(_ sender: UIButton) {
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = maxImageCount
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}
//extension delega
extension ImagePickerVC: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        var listImage = [UIImage]()
        results.forEach { res in
            if(res.itemProvider.canLoadObject(ofClass: UIImage.self)){
                res.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    
                    //                        guard let self else { return }
                    //                        listImage.append(image!)
                    //                        if listImage.count == results.count{
                    //                            self.chosenImageViews
                    //                        }
                    let image = image as! UIImage
                    listImage.append(image)
                    //                        print("========> 1", indexImage, Date())
                    //                        self?.chosenImageViews[indexImage].image = image as? UIImage
                    //                        print("========> 2®", indexImage, Date())
                    self?.indexImage += 1
                    if listImage.count == 3 {
                        DispatchQueue.main.async {
                            self?.listImage = listImage
                        }
                    }
                   
                }
                
                
            }
        }
        
    }
}
//extension ImagePickerVC: PHPickerViewControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        dismiss(animated: true)
//
//        for (index, res) in results.enumerated() {
//            if res.itemProvider.canLoadObject(ofClass: UIImage.self) {
//                res.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//                    guard let self = self, let uiImage = image as? UIImage else { return }
//                    DispatchQueue.main.async {
//                        if index < self.chosenImageViews.count {
//                            self.chosenImageViews[index].image = uiImage
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
