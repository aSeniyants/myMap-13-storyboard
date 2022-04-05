import UIKit
import RealmSwift
import MapKit

class TracksViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    let names = ["Vasya", "Petya", "Hren", "Her", "Piska"]
    let realm = try! Realm()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Tracks открывается")
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    // actions
    @IBAction func listTracks(_ sender: UIButton) {
        let trackListTable = realm.objects(trackListData.self)
        for trackL in trackListTable{
            print(trackL.dateTrack + " - " + String(trackL.trackPoint.count))
        }
    }
}


extension TracksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped")
    }
    
}


extension TracksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
    
}

class trackListData: Object{
    @objc dynamic var dateTrack: String = ""
    dynamic var trackPoint = List<String>()
}
