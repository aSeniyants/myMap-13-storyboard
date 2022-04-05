import UIKit
import MapKit
import RealmSwift


class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    let now = Date()
    
    //    создаем аутлет зачем от
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var compasButtun: MKCompassButton!
    
//    создаем его для работы с позицией
    let locationManager = CLLocationManager()
//    переменная, которая говорит нажата кнопка REC или нет
    var recMode = false
//    массив для хранения местоположения прия записи трека
    var geoLocationArray: [String] = []
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("запускается мэп")
    }

//    когда экран с картами загрузился, проверяем включена ли геолокация
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationEnabled()
    }

    func checkLocationEnabled(){
//        проверяем включена ли служба геолокации
        if CLLocationManager.locationServicesEnabled(){
//            если да, то запускаем сетапменеджер
            setupManager()
            chekAuthorization()
        }else{
//        если нет, показываем алерт
            let alert = UIAlertController(title: "У вас включена ГПС", message: "Хотите включить?", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Настройки", style: .default) { (alert) in
                if let url = URL(string: "App-Prefs:root=LOCATION_SERVICES"){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }

//    хз зачем она нужна...
    func setupManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd-MM-yy"
        let trackTime = formatter.string(from: now)
        print(trackTime)
        return trackTime
    }
    
//    создаем функцию определения местоположения
    func chekAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            break
        case .denied:
            print("геолокация запрещена")
        case .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    @IBAction func myLocationCenterButton(_ sender: UIButton) {
        if let myLocation = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: myLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            print(myLocation)
            print("я в центре")
        }else{
            print("позиция не обнаружена")
        }
        

    }
    

    @IBAction func plusButton(_ sender: UIButton) {
        
        if geoLocationArray.count > 0{
            print(geoLocationArray)
        }
        getDate()
    }
    @IBAction func recButton(_ sender: UIButton) {
        print("REC START")
        print("REC = \(recMode)")
        if recMode == false{
            recMode = true
            print("change REC = true")
        }else{
            recMode = false
            print("change REC = false")
            let track = trackListData()
            track.dateTrack = getDate()
            track.trackPoint.append(objectsIn: geoLocationArray)
            realm.beginWrite()
            realm.add(track)
            try! realm.commitWrite()
            print("Track записан")
            geoLocationArray = []
        }
    }
}

extension MapViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last?.coordinate
        if recMode == true{
            print(geoLocationArray.count)
            if location != nil {
                let a = String(location?.longitude ?? 0.0)
                let b = String(location?.latitude ?? 0.0)
                let c = "longtitude: " + a + ", latitude: " + b
                geoLocationArray.append(c)
            }
        }
    }
}

