//
//  PhotoPikcerViewController.swift
//  MapkitAndWeather
//
//  Created by youngkyun park on 2/4/25.
//

import UIKit
import PhotosUI

import SnapKit

final class PhotoPikcerViewController: UIViewController {
    
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    private var images: [UIImage] = []
    
    var closure: ((UIImage) -> (Void))?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoPikcerCollectionViewCell.self, forCellWithReuseIdentifier: PhotoPikcerCollectionViewCell.id)
        
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(pikcerButtonTapped))
        
        navigationItem.rightBarButtonItem = rightButton
    }
    
    
    
    
    private func setupUI() {
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.edges.equalTo(view.safeAreaLayoutGuide)
            
        }
        
        
    }
    
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        var deviceWidth: Double = 0.0
        
        if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            deviceWidth = window.screen.bounds.size.width
        } else {
            deviceWidth = 200
        }
        
        
        let spacing: CGFloat = 8
        let inset: CGFloat = 16
        let imageCount: CGFloat = 3
        
        let objectWidth = (deviceWidth - ((spacing * (imageCount - 1)) + (inset * 2))) / 3
        
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        layout.itemSize = CGSize(width: objectWidth, height: 100)
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        layout.scrollDirection = .vertical
        
        return layout
    }
    
    
    
    @objc private func pikcerButtonTapped(_ sender: UIButton) {
        
        var congifuration = PHPickerConfiguration()
        congifuration.filter = .images
        congifuration.selectionLimit = 5
        congifuration.mode = .default
        
        let pikcer = PHPickerViewController(configuration: congifuration)
        pikcer.delegate = self
        
        present(pikcer, animated: true)
    }
    
}


// MARK: - UICollectionView Extension
extension PhotoPikcerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPikcerCollectionViewCell.id, for: indexPath) as? PhotoPikcerCollectionViewCell else { return UICollectionViewCell() }
        
        cell.setImage(img: images[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        closure?(images[indexPath.item])
    }
    
}


// MARK: - PHPickerViewController Extension
extension PhotoPikcerViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        images.removeAll()
        
        guard !results.isEmpty else {
            print("결과과 없습니다")
            return
        }
        
        let group = DispatchGroup()
        
        for i in 0..<results.count {
            group.enter()
            let itemProivder = results[i].itemProvider
            if itemProivder.canLoadObject(ofClass: UIImage.self) {
                itemProivder.loadObject(ofClass: UIImage.self) { image, error  in
                    
                 
                    DispatchQueue.main.async {
                        if let img = image as? UIImage {
                            self.images.append(img)
                        } else {
                            print("이미지 로드 실패")
                        }
                    }
                    group.leave()
                    
                    

                    
                }
                
            }
        }
        
        dismiss(animated: true)
        
        group.notify(queue: .main) {
            print(self.images.count)
            self.collectionView.reloadData()
        }
        
       
    }

    
}

