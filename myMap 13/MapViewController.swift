import UIKit
import MapKit
import RealmSwift

//протокол для работы делегата
protocol MapDrawDelegate: AnyObject {
    func drawTrackOnMap(switcherNum: Int)
    func removeTrackOnMap(switcherNum: Int)
}


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MapDrawDelegate {
    

    //    создаем аутлеты
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var compasButtun: MKCompassButton!
    
//  константа для работы со временем и датой
    let now = Date()
//  для работы геопозици
    let locationManager = CLLocationManager()
//    переменная, которая говорит нажата кнопка REC или нет
    var recMode = false
//    массив для хранения местоположения прия записи трека
    var geoLocationArray: [CLLocationCoordinate2D] = []

//  создает объект Realm
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("запускается мэп")
        
//      определяем с какого контроллера пойдет команда делегата
        let destination = tabBarController?.viewControllers![2] as? TracksViewController
        destination?.delegate = self
        
        mapView.delegate = self
        
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

//    запускаем определение геопозиции
    func setupManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

//  функция, которая дает дату в виде строки (для записи в название трека)
    func getDate() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd-MM-yy"
        let trackTime = formatter.string(from: now)
        print(trackTime)
        return trackTime
    }
    
//    функция для определения доступности геопозиции
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
    
//    функция наложения отрисованных треков на карте
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("mapView start")
        let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        polylineRenderer.strokeColor = UIColor.red
        polylineRenderer.lineWidth = 3.0
        return polylineRenderer
      }
    
//    кнопка переноса экрана к геопозиции пользователя
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
//        в данный момент не востребована
    }
    
    @IBAction func minusButtun(_ sender: UIButton) {
//        в данный момент не востребована
    }
    
//    кнопка записи REC
    @IBAction func recButton(_ sender: UIButton) {
        print("REC = \(recMode)")
//        если запись трека ранее была выключена - просто включаем ее
        if recMode == false{
            recMode = true
            print("change REC = true")
//        если была включена, то массив с геопозицией записываем в базу данных, переменную меняем на False и обнуляем массив с геопозицией.
        }else{
            recMode = false
            print("change REC = false")
            let locationListTable = realm.objects(locationList.self)
//        здесь мы сохраняем в переменные индексы геолокаций, которые записаны в базу, для последующей их записи в tracklist
            let firstIndexLocationList = locationListTable.count
            let lastIndexLocationList = locationListTable.count + geoLocationArray.count - 1
            print(locationListTable.count, geoLocationArray.count, firstIndexLocationList, lastIndexLocationList)
//        записываем массив с геопозицией в базу данныъ
            for elem in geoLocationArray{
                let writeCoordinates = locationList()
                realm.beginWrite()
                writeCoordinates.longitude = elem.longitude
                writeCoordinates.latitude = elem.latitude
                realm.add(writeCoordinates)
                try! realm.commitWrite()
                print("coordinates write in locationList")
            }
            print(locationListTable.count)
            let writeCoordinatesArray = trackList()
            realm.beginWrite()
//         записываем название трека в виде даты
            writeCoordinatesArray.nameTrack = getDate()
            writeCoordinatesArray.coordinates.append(objectsIn: locationListTable[firstIndexLocationList...lastIndexLocationList])
            realm.add(writeCoordinatesArray)
            try! realm.commitWrite()
            print("Track записан!")
//         обнуляем массив с геолокацией
            geoLocationArray = []
        }
    }
    
//  функция, которая запускается через делегат для отрисовки трека при его активации в таблице треков
    func drawTrackOnMap(switcherNum: Int) {
        print("Delegate start")
        print("CellSwitcher N: \(switcherNum)")
        let trackListTable = realm.objects(trackList.self)
        var addTrackArray: [CLLocationCoordinate2D] = []
//      трек считывается из базы и сохраняется в массив
        for elem in trackListTable[switcherNum].coordinates{
            addTrackArray.append(elem.coordinate)
        }
        print(addTrackArray.count)
//      массив передается в метод отрисовки трека
        let polyline: MKPolyline = MKPolyline(coordinates: addTrackArray, count: addTrackArray.count)
//      для того чтобы в последующем можно было этот трек удалить, в его subtitle добавляется номер строки
        polyline.subtitle = String(switcherNum)
        mapView.addOverlay(polyline)
        print("Track draw")
    }
    
//    функция удаления трека работает несколько необычно...
//    при выключении переключателя в таблице, в функцию передается номер строки
//    который сравнивается с subtitle и при совпадении трек удаляется
    func removeTrackOnMap(switcherNum: Int) {
        for overlay in mapView.overlays{
            if overlay.subtitle == String(switcherNum){
                mapView.removeOverlay(overlay)
                print("remove track")
            }
        }
    }
}

//расширения для функции определения геопозиции
extension MapViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last?.coordinate
//        при активации режима REC геолокация сохраняется в массив
        if recMode == true{
            print(geoLocationArray.count)
            if location != nil {
                geoLocationArray.append(location!)
            }
        }
    }
}

