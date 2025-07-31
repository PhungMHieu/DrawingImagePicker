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
    var index:Int = .zero
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
        dismiss(animated: true)
        results.forEach { res in
            if(res.itemProvider.canLoadObject(ofClass: UIImage.self)){
                res.itemProvider.loadObject(ofClass: UIImage.self) { [weak self]image, error in
//                    DispatchQueue.main.sync {
//                        self?.chosenImageViews.append(image as! UIImageView)
                        self?.chosenImageViews[self!.index].image = image as? UIImage
                        self?.index += 1
//                    }
                }
            }
        }
        self.index = 0
        //        if let itemProvider = results.last?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
//            let previousImage = chosenImageViews?.image
//            itemProvider.loadObject(ofClass: UIImage.self) {[weak self] image, error in
//                DispatchQueue.main.async {
//                    guard let self = self,
//                          let image = image as? UIImage, self.chosenImageView.image == previousImage else{
//                        return
//                    }
//                    self.chosenImageView.image = image
//                }
//            }
//        }
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
