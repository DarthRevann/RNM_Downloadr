import UIKit
import SnapKit
import Alamofire
import SwiftyJSON

class PlayListViewController: UIViewController {
    
    // структура трека, ее будем использовать для работы
    struct Track: Codable {
        
        let artist: String?
        let title: String?
        let album: String?
        var url: String?
//        var isDownloading: Bool?
        
    }
    
    
    
    var trackListTableView = UITableView()
    var tracks: [Track] = []
    let identifier = "TrackCell"
    
    let navigationBar = UINavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewDidLoad")
        
        view.backgroundColor = .white
        
        configureNavBar()
        setupTrackListTableView()
        getTrackList()

        
    }
    
    // MARK: Создание и настройка навигационного бара
    
    func configureNavBar() {
        
        view.addSubview(navigationBar)
        
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            
            
        }
        
        // Создание и настройка элемента навигационной панели
        let navigationItem = UINavigationItem(title: "Downloadr")
        
        navigationBar.barTintColor = UIColor(red: 41/255, green: 42/255, blue: 47/255, alpha: 1.0)
        
        
//         MARK: Dar play theme:
//       navigationBar.barTintColor = UIColor(red: 233/255, green: 51/255, blue: 69/255, alpha: 1.0)
        
        // Создание атрибутов титульной надписи
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white, // Цвет текста
            .font: UIFont.boldSystemFont(ofSize: 19) // Шрифт текста
        ]
        
        // Установка атрибутов текста для навигационной панели
        navigationBar.titleTextAttributes = textAttributes
        
        // Установка элемента навигационной панели
        navigationBar.setItems([navigationItem], animated: false)
        
    }
    
    
    func setupTrackListTableView() {
        
        view.addSubview(trackListTableView)
        
        trackListTableView.backgroundColor = .clear
        trackListTableView.delegate = self
        trackListTableView.dataSource = self
        trackListTableView.register(TrackTableViewCell.self, forCellReuseIdentifier: identifier)

        
        
        trackListTableView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).offset(-40)
            
        }
        
        
        
        
    }
    
    func getTrackList() {
        let url = URL(string: "https://vibze.github.io/downloadr-task/tracks.json")!
        AF.request(url).responseDecodable(of: [String: [Track]].self) { response in
            switch response.result {
            case .success(let result):
                if let tracks = result["tracks"] {
                    self.tracks = tracks
                    self.trackListTableView.reloadData()
                    print("SUCCESS: TrackList was got succesfull")
                }

            case .failure(let error):
                print("Error getting track list: \(error)")
            }
        }
    }
}



extension PlayListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TrackTableViewCell
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        return cell
    }
    
    
}
