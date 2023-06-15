import UIKit
import SnapKit
import Foundation


class TrackTableViewCell: UITableViewCell {
    
    let fileManager = FileManager()
    let tempDir = NSTemporaryDirectory()
    
    let identifier = "TrackCell"
    
    var titleLabel: UILabel!
    var artistLabel: UILabel!
    var downloadButton: UIButton!
    var progressBar: UIProgressView!
    var deleteButton: UIButton!
    var track: PlayListViewController.Track?
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: identifier)
        
        setupUI()
        setupConstraints()
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(67)
            make.width.equalToSuperview()
            //            make.width.equalToSuperview()
        }
        //        contentView.backgroundColor = .systemYellow
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        artistLabel = UILabel()
        artistLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        artistLabel.textColor = .lightGray
        
        downloadButton = UIButton()
        downloadButton.setTitle("Скачать", for: .normal)
        downloadButton.setTitleColor(.systemBlue, for: .normal)
        
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        
        progressBar = UIProgressView()
        //        progressBar.isHidden = false
        progressBar.trackTintColor = .lightGray
        progressBar.progressTintColor = .systemBlue
        
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(downloadButton)
        contentView.addSubview(progressBar)
        //        contentView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            //            make.trailing.equalTo(downloadButton.snp.leading).offset(-8)
        }
        
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
        }
        
        downloadButton.snp.makeConstraints { make in
            
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            
        }
        
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(downloadButton)
        }
        
    }
    
    func configure(with track: PlayListViewController.Track) {
        titleLabel.text = track.title
        artistLabel.text = track.artist
        
    }
    
    @objc func downloadButtonTapped() {
        let trackName = track?.url
        let fileName = "\(String(describing: trackName)).mp3"
        
        print("SUCCESS: DownloadButtonTapped ")
        
        guard let track = track else {
            return
        }
        
        downloadButton.isEnabled = false
        downloadButton.setTitle("Идет загрузка", for: .disabled)
        progressBar.isHidden = false
        
        // Выполнение загрузки файла с использованием URLSession или другой библиотеки
        guard let downloadURL = URL(string: track.url ?? "") else {
            print("Некорректный URL для загрузки трека")
            return
        }
        
        // Пример кода URLSession:
        let downloadTask = URLSession.shared.downloadTask(with: downloadURL) { (location, response, error) in
            // Проверяем наличие ошибок при загрузке
            if let error = error {
                print("Ошибка загрузки файла: \(error.localizedDescription)")
                return
            }
            
            // Получаем временное расположение загруженного файла
            guard let location = location else {
                print("Не удалось получить расположение загруженного файла")
                return
            }
            
            // Создаем URL для желаемого расположения файла в файловой системе
            let fileManager = FileManager.default
            let documentsDirectoryURL = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationURL = documentsDirectoryURL?.appendingPathComponent(fileName)
            
            // Перемещаем загруженный файл в желаемое расположение
            do {
                try fileManager.moveItem(at: location, to: destinationURL!)
                print("Файл успешно загружен и перемещен в \(destinationURL?.path ?? "")")
            } catch {
                print("Ошибка перемещения файла: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                self.downloadButton.isEnabled = true
                self.downloadButton.setTitle("Удалить", for: .normal)
                self.progressBar.isHidden = true
            }
        }
        
        downloadTask.resume()
    }
}
    
    
    
    extension JSONSerialization {
        
        static func loadJSON(withFilename filename: String) throws -> Any? {
            let fm = FileManager.default
            let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
            if let url = urls.first {
                var fileURL = url.appendingPathComponent(filename)
                fileURL = fileURL.appendingPathExtension("json")
                let data = try Data(contentsOf: fileURL)
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .mutableLeaves])
                return jsonObject
            }
            return nil
        }
        
        static func save(jsonObject: Any, toFilename filename: String) throws -> Bool{
            let fm = FileManager.default
            let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
            if let url = urls.first {
                var fileURL = url.appendingPathComponent(filename)
                fileURL = fileURL.appendingPathExtension("json")
                let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
                try data.write(to: fileURL, options: [.atomicWrite])
                return true
            }
            
            return false
        }
    }

