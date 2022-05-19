import UIKit
import RealmSwift
import MapKit

class TracksViewController: UIViewController {
    
//    для работы делегата
    weak var delegate: MapDrawDelegate?
   
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Tracks открывается")
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    // кнопка обновления таблица (перечитывание базы)
    @IBAction func listTracks(_ sender: UIButton) {
        let trackListTable = realm.objects(trackList.self)
        let locationListTable = realm.objects(locationList.self)
        print(trackListTable)
        tableView.reloadData()
        }
    }



extension TracksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        действия при нажатии на строку
        print("You tapped")
    }

    //  Блок для удаления строки в таблице
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var trackListTable = realm.objects(trackList.self)
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Удалить", handler: {
            _,_ in print("delete \(indexPath.row)")
            self.realm.beginWrite()
            self.realm.delete(trackListTable[indexPath.row])
            try! self.realm.commitWrite()
            print("row N \(indexPath.row) delete")
            tableView.reloadData()
        })

    return [deleteAction]
    }
    
//    функция для передачи данных через делегат на контроллер с картой
//    при изменении положения свитчера
    @objc func drawTrack(_ sender: UISwitch) {
        print("drawTrack start")
        print(type(of: sender.tag))
        if sender.isOn{
            delegate?.drawTrackOnMap(switcherNum: sender.tag)
            print("cell N: \(sender.tag)")
        }else{
            delegate?.removeTrackOnMap(switcherNum: sender.tag)
            print("delete track N \(sender.tag)")
        }
    }
}


extension TracksViewController: UITableViewDataSource {
    
//    количество строк таблицы равно количеству треков в базе
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let trackListTable = realm.objects(trackList.self)
        return trackListTable.count
    }
    
//    указываем содержимое ячейки
//    нас интересует имя трека и свитчер
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let trackListTable = realm.objects(trackList.self)
        cell.textLabel?.text = trackListTable[indexPath.row].nameTrack
        let cellSwitcher = UISwitch()
        cellSwitcher.tag = indexPath.row
        cellSwitcher.addTarget(self, action: #selector(drawTrack(_:)), for: .valueChanged)
        cell.accessoryView = cellSwitcher
        return cell
    }
}

//объекты базы реалм состоят из двух таблиц:
//  таблица с геопозициями
//  и таблица со списком геопозиции
//
//  Если в базе данных будет одна таблица, то придется координаты типа CLLocationCoordinate2D
//  переформативаровать в String, а потом обратно
class locationList: Object {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
    }
}

class trackList: Object {
    let coordinates = List<locationList>()
    @objc dynamic var nameTrack: String = ""
    }
