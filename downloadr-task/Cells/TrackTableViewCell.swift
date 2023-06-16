import UIKit
import SnapKit
import Foundation
import Alamofire


class TrackTableViewCell: UITableViewCell {
    
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var downloadTask: URLSessionDownloadTask?

    
    let fileManager = FileManager()
    let tempDir = NSTemporaryDirectory()
    
    let identifier = "TrackCell"
    
    var trackURL: URL?
    var trackTitle: String?
    
    var downloadProgress: Float = 0.0
    
    
    
    var filePath: URL?
    
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
        
        self.track = track
        if let urlString = track.url {
            trackURL = URL(string: urlString)
            filePath = documentDirectory.appendingPathComponent("music.mp3")
            
        }
        
    }
    
    @objc func downloadButtonTapped(_ sender: UIButton) {
        
        downloadButton.isEnabled = false
        downloadButton.setTitle("Идет загрузка", for: .disabled)
        downloadButton.setTitleColor(.systemGreen, for: .disabled)
        print("Идет загрузка")
        
        
        getMP3()
        
        
        
        downloadButton.setTitle("Удалить", for: .normal)
        downloadButton.setTitleColor(.red, for: .normal)
        
        
        
        // MARK: скачивает песню "30 Minute Love Affair.mp3"
        
        func getMP3() {
            
            progressBar.progressTintColor = .red
            progressBar.progressViewStyle = .default
            progressBar.progress += 1
            progressBar.setProgress(progressBar.progress, animated: true)
            
            
            
            
            
            
            let trackName = documentDirectory.appendingPathComponent("music.mp3")
            let urlString = "https://vibze.github.io/downloadr-task/files/02%2030%20Minute%20Love%20Affair.mp3"
            if let trackUrl = URL(string: urlString) {
                
                URLSession.shared.downloadTask(with: trackUrl) { (tempFileUrl, response, error) in
                    
                    
                    if let trackTempFileUrl = tempFileUrl {
                        do {
                            // запись в файловую систему
                            let trackData = try Data(contentsOf: trackTempFileUrl)
                            
                            
                            try trackData.write(to: trackName)
                        } catch {
                            print("Error")
                        }
                    }
                }.resume()
            }
            
            //            URLSession.shared.delegate = self
            
        }
        
        func deleteTrack() {
            guard let filePath = filePath else {
                return
            }
            
            do {
                try FileManager.default.removeItem(at: filePath)
                print("Трек удален")
            } catch {
                print("Ошибка удаления трека: \(error.localizedDescription)")
            }
        }
    }
    }


extension TrackTableViewCell: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Загрузка завершена, обновление интерфейса
        DispatchQueue.main.async {
            self.downloadButton.isEnabled = true
            self.downloadButton.setTitle("Скачать", for: .normal)
            self.downloadButton.setTitleColor(.red, for: .normal)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Обновление прогресса загрузки
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressBar.setProgress(progress, animated: true)
        }
    }
}

