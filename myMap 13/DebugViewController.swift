import UIKit


class DebugViewController: UIViewController {
    
    let vc = MapViewController()
    

    override func viewDidLoad() {
                
        super.viewDidLoad()
        print("старт дебаг")
        vc.getDate()
    }
}

