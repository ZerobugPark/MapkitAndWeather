//
//  ViewController.swift
//  MapkitAndWeather
//
//  Created by youngkyun park on 2/3/25.
//

import UIKit
import MapKit

import SnapKit


final class ViewController: UIViewController {

    private let mapView: MKMapView = {
        let view = MKMapView()
        return view
    }()
    
    private let weatherInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.text = "날씨 정보를 불러오는 중..."
        return label
    }()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        checkDeviceLocation()
    }
    
    private func defaultLoction() {
        let annotation = MKPointAnnotation()
        
        let latitude = 37.654218
        let longitude = 127.049952
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.coordinate = center
    
        mapView.region =  MKCoordinateRegion(center: center, latitudinalMeters: 300, longitudinalMeters: 300)
        
        mapView.addAnnotation(annotation)
    }
    
    
    private func checkDeviceLocation() {
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                
                let authorization: CLAuthorizationStatus
                
                if #available(iOS 14.0, *) {
                    authorization = self.locationManager.authorizationStatus
                } else {
                    authorization = CLLocationManager.authorizationStatus()
                }
                
            } else {
                DispatchQueue.main.async {
                    self.showSettingAlert()
                }
            }
        }
    }
    
    private func checkCurrentLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        [mapView, weatherInfoLabel, currentLocationButton, refreshButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
        }
        
        weatherInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        currentLocationButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(50)
        }
        
        refreshButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(50)
        }
    }
    
    private func setupActions() {
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func currentLocationButtonTapped() {
        // 현재 위치 가져오기 구현
    }
    
    @objc private func refreshButtonTapped() {
        // 날씨 새로고침 구현
    }


}


extension ViewController {
    
    
    private func showSettingAlert() {
        
        var title = "위치 정보 이용"
        let msg = "위치 서비스를 사용할 수 없습니다. '기기의 설정>개인정보 보호'에서 위치서비스를 켜주세요."
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        title = "설정으로 이동"
        let goSetting = UIAlertAction(title: title, style: .default) { _ in
            if let setting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(setting)
            }
        }
        
        title = "취소"
        let cancle = UIAlertAction(title: title, style: .cancel)
        
        alert.addAction(goSetting)
        alert.addAction(cancle)
        
        present(alert,animated: true)
        
    }
}
