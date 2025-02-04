//
//  ViewController.swift
//  MapkitAndWeather
//
//  Created by youngkyun park on 2/3/25.
//

import UIKit
import MapKit
import CoreLocation
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
    
    private let moveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Move", for: .normal)
        button.backgroundColor = .blue
      
        return button
    }()
    
    private var locationManager = CLLocationManager()
    
    private var currentCoordinate = CLLocationCoordinate2D()
   
    private let refLatitude = 37.654218
    private let refLongitude = 127.049952
    
    var annotation = MKPointAnnotation()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        
        locationManager.delegate = self
        checkDeviceLocation()
        
    }
    
    private func defaultLoction() {
        
        mapView.removeAnnotations(mapView.annotations)
        
        
        let center = CLLocationCoordinate2D(latitude: refLatitude, longitude: refLongitude)
        annotation.coordinate = center
    
        mapView.region =  MKCoordinateRegion(center: center, latitudinalMeters: 300, longitudinalMeters: 300)
        
        mapView.addAnnotation(annotation)
        getWeather(latitude: refLatitude, longitude: refLongitude)
      
    }
    
    
    private func checkDeviceLocation() {
        
        DispatchQueue.global().async {
            // locationServicesEnabled = 앱 기준이 아닌 시스템 기준으로 위치서비스가 꺼져있을 때 False 발생
            if CLLocationManager.locationServicesEnabled() {
                
                let authorization: CLAuthorizationStatus
                
                if #available(iOS 14.0, *) {
                    authorization = self.locationManager.authorizationStatus
                } else {
                    authorization = CLLocationManager.authorizationStatus()
                }
                
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorizationStatus(status: authorization)
                }
                
            } else {
                DispatchQueue.main.async {
                    //  위치서비스 자체가 꺼져있을 때, 위치서비스로 이동하는 방법은 없을까?.
                    self.showSettingAlert()
                }
            }
        }
    }
    
    private func checkCurrentLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            print("위치서비스에 대한 권한이 아직 설정되지 않음")
        case .restricted:
            //defaultLoction()
            //showSettingAlert()
            // 이거 이 조건은 직접적으로 테스트할 수 있는 환경이 불가능함.
            print("앱이 위치설정 거부 된 상태")
        
        case .denied:
            defaultLoction()
            // 여기서 설정 화면으로 유도하게 되면 버튼이 아닌 단순 권한이 변경될 때마다 호출 됨
            //showSettingAlert()
            currentCoordinate.latitude = refLatitude
            currentCoordinate.longitude = refLongitude
            print("요청 얼럿에서 위치설정 거부 된 상태")
        case .authorizedAlways:
            print("백그라운드에서도 실행 가능")
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            print("앱이 사용 중일 때만")
        default:
            print("관리자한테 문의")
            
        }
        
    }
    
    private func getWeather(latitude: CLLocationDegrees,
                            longitude: CLLocationDegrees) {
        NetworkManager.shared.callRequest(api: OpenWeatherRequest.weatherInfo(lat: String(latitude), lon: String(longitude))) { response in
            
            switch response {
            case .success(let success):
                self.weatherInfoLabel.text = "현재온도: \(success.main.temp)\n 최고온도: \(success.main.tempMax) \n 최저온도: \(success.main.tempMin)\n 습도: \(success.main.humidity)%\n 풍속: \(success.wind.speed)m/s"
            case .failure(let failure):
                dump(failure)
            }
            
            
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        [mapView, weatherInfoLabel, currentLocationButton, refreshButton, moveButton].forEach {
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
        
        moveButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(100)
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
    }
    
    private func setupActions() {
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        
        moveButton.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
    }
    
    private func currentLocationUpdate() {
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        let center = CLLocationCoordinate2D(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        annotation.coordinate = center
    
        mapView.region =  MKCoordinateRegion(center: center, latitudinalMeters: 300, longitudinalMeters: 300)
    
        mapView.addAnnotation(annotation)
        getWeather(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
    }
    
    // MARK: - Actions
    @objc private func currentLocationButtonTapped() {
        
        let authorization: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            authorization = self.locationManager.authorizationStatus
        } else {
            authorization = CLLocationManager.authorizationStatus()
        }
        // 버튼이 클릭되었을 때, 현재 권한 상태를 알아야 함.
        // status 기준으로 하려고 했지만, status가 바뀌는 시점과 실제 동작하는 시점에 타밍잉 이슈가 있음
        // (비동기로 처리되어서 그런거 같은데, DispatchQueue안에 status를 넣어도 동일함)
        // 조금 더 깔끔한 방법을 찾아보자. (네이버는 권한허용이 엄청빨리 뜨는거 같은데, 어느 시점에서 호출하면 빨리 뜰 수 있을까?)
        // 백그라운드상태에서 포어그라운드 상태로 바뀐 상태를 알 수 있는 방법?
        if authorization == .denied {
            defaultLoction() // 지도 중심을 도봉캠퍼스로 옮기고 (denied에서 실질적으로 중복이나, 순서때문에 어쩔 수 없음)
            showSettingAlert() // alert 띄우기
        } else {
            currentLocationUpdate()
        }
        
    }
    
    @objc private func refreshButtonTapped() {
        // 날씨 새로고침 구현
    //    checkDeviceLocation()
        
        print(currentCoordinate.latitude,currentCoordinate.longitude)
        getWeather(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        
    }
    
    @objc private func moveButtonTapped() {
        
        let vc = PhotoPikcerViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }

}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinate = locations.last?.coordinate {
            currentCoordinate = coordinate
            currentLocationUpdate()
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        dump(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocation()
     
        
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
