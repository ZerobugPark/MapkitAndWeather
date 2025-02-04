//
//  PhotoPikcerCollectionViewCell.swift
//  MapkitAndWeather
//
//  Created by youngkyun park on 2/4/25.
//

import UIKit

class PhotoPikcerCollectionViewCell: UICollectionViewCell {
 
    static let id = "PhotoPikcerCollectionViewCell"
    let image = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setupUI() {
        contentView.backgroundColor = .white
      
        
        contentView.addSubview(image)
        
    }
    
    private func setupConstraints() {
        image.snp.makeConstraints { make in
            make.top.edges.equalTo(contentView.safeAreaLayoutGuide)
            
        }
        
        image.backgroundColor = .red
    }
    
    
    
}
