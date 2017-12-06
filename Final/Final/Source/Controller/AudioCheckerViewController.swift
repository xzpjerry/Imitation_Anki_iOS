//
//  AudioCheckerViewController.swift
//  Final
//
//  Created by Zippo Xie on 12/5/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class AudioCheckerViewController: UIViewController {
    
    var mycard : Card!
    var FetRC : NSFetchedResultsController<Audio>!
    private let context = CardService.context
    
    private var audioStatus: AudioStatus = .Stopped
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var current_file_name : String?
    
    @IBOutlet weak var record_btn : UIButton!
    @IBOutlet weak var play_btn : UIButton!
    @IBOutlet weak var save_btn : UIButton!
    @IBOutlet weak var tableview : UITableView!
    
    @IBAction private func onrecord(sender : UIButton) {
        if appHasMicAccess == true {
            if audioStatus != .Playing {
                
                switch audioStatus {
                case .Stopped:
                    record_btn.setTitle("Stop", for: .normal)
                    record()
                case .Recording:
                    play_btn.isHidden = false
                    save_btn.isHidden = false
                    record_btn.setTitle("Record", for: .normal)
                    stopRecording()
                default:
                    break
                }
            }
        } else {
            let theAlert = UIAlertController(title: "Requires Microphone Access",
                                             message: "Go to Settings > PenguinPet > Allow PenguinPet to Access Microphone.\nSet switch to enable.",
                                             preferredStyle: UIAlertControllerStyle.alert)
            
            theAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(theAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction private func onplay(sender : UIButton) {
        if audioStatus != .Recording {
            
            switch audioStatus {
            case .Stopped:
                record_btn.isHidden = true
                save_btn.isHidden = true
                play_btn.setTitle("Stop", for: .normal)
                play()
            case .Playing:
                record_btn.isHidden = false
                save_btn.isHidden = false
                play_btn.setTitle("Play", for: .normal)
                stopPlayback()
            default:
                break
            }
        }
    }
    
    @IBAction private func onsave(sender : UIButton) {
        let tmp = Audio(context: context)
        tmp.file_name = current_file_name!
        tmp.card = mycard
        CardService.shared.saveContext(with: nil, by: mycard)
        
        setupRecorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let request : NSFetchRequest<Audio> = Audio.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor.init(key: "file_name", ascending: true)]
        request.predicate = NSPredicate.init(format: "card = %@", argumentArray: [mycard])
        FetRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try FetRC.performFetch()
            FetRC.delegate = self
            tableview.reloadData()
        } catch let err {fatalError("Looking up related audio files name failed \(err.localizedDescription)")}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPermission()
        save_btn.isHidden = true
        play_btn.isHidden = true
        
        // avfoundation prologue
        let nc = NotificationCenter.default
        let session = AVAudioSession.sharedInstance()
        nc.addObserver(self, selector: #selector(handleInterruption) , name: NSNotification.Name.AVAudioSessionInterruption, object: session)
        nc.addObserver(self, selector: #selector(handleRouteChange), name: NSNotification.Name.AVAudioSessionRouteChange, object: session)
        setupRecorder()
    }

}
// fetrc delegate
extension AudioCheckerViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableview.reloadData() // since we only have limited audio files, just using reload data
    }
}

// tableview
extension AudioCheckerViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FetRC.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "record_cell", for: indexPath)
        cell.textLabel?.text = "Record #\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if audioStatus != .Recording {
            let audio = FetRC.object(at: indexPath)
            switch audioStatus {
            case .Stopped:
                record_btn.isHidden = true
                save_btn.isHidden = true
                play_btn.isHidden = false
                play_btn.setTitle("Stop", for: .normal)
                play(audio.file_name)
            case .Playing:
                record_btn.isHidden = false
                save_btn.isHidden = false
                play_btn.isHidden = true
                play_btn.setTitle("Play", for: .normal)
                stopPlayback()
            default:
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let audio = FetRC.object(at: indexPath)
            context.delete(audio)
            setupRecorder(audio: audio)
            audioRecorder.deleteRecording()
            setupRecorder()
            CardService.shared.saveContext(with: nil, by: mycard)
            tableview.reloadData()
        }
    }
}

// MARK: - Helpers
extension AudioCheckerViewController {
    private func getPermission() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try session.setActive(true)
            
            // Check for microphone permission...
            session.requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    appHasMicAccess = true
                } else{
                    appHasMicAccess = false
                }
            })
            
        } catch let error as NSError {
            print("AVAudioSession configuration error: \(error.localizedDescription)")
        }
    }
    private func getURLforMemo(audio : Audio? = nil, current_name : String? = nil) -> URL {
        let App_path = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                            FileManager.SearchPathDomainMask.userDomainMask, true) as [String])[0]
        NSLog("Paths \(App_path)")
        guard audio != nil else {
            // giving a new audio file path or path of audio just recorded
            if current_name != nil {
                current_file_name = current_name!
            } else {
                current_file_name = "/\(UUID.init()).caf"
            }
            let filePath = App_path + current_file_name!
            
            return URL.init(fileURLWithPath: filePath)
        }
        // name from coredata
        let relative_path = audio!.file_name!
        return URL.init(fileURLWithPath: App_path + relative_path)
    }
}

// MARK: - AVFoundation Methods
extension AudioCheckerViewController: AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    // MARK: Recording
    private func setupRecorder(audio : Audio? = nil) {
        let fileURL = getURLforMemo(audio: audio, current_name: nil)
        
        let recordSettings : Dictionary< String , Any > = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder.init(url: fileURL, settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print("Error creating audioRecorder.")
        }
    }
    
    private func record() {
        audioRecorder.record()
        audioStatus = .Recording
    }
    
    private func stopRecording() {
        audioRecorder.stop()
        audioStatus = .Stopped
    }
    
    // MARK: Playback
    private func play(_ name : String? = nil) {
        if current_file_name != nil || name != nil {
            let fileURL = getURLforMemo(audio: nil, current_name: name == nil ? current_file_name! : name)
            do {
                audioPlayer = try AVAudioPlayer.init(contentsOf: fileURL)
                audioPlayer.delegate = self
                if audioPlayer.duration > 0.0 {
                    audioPlayer.play()
                    audioStatus = .Playing
                }
            } catch {
                print("Error loading audioPlayer.")
            }
        }
        
    }
    
    private func stopPlayback() {
        audioPlayer.stop()
        audioStatus = .Stopped
    }
    
    // MARK: Delegates
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        audioStatus = .Stopped
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        record_btn.isHidden = false
        save_btn.isHidden = false
        play_btn.setTitle("Play", for: .normal)
        audioStatus = .Stopped
    }
    
    
    // MARK: Notifications
    @objc
    func handleInterruption(notification: NSNotification) {
        if let info = notification.userInfo {
            let type = AVAudioSessionInterruptionType(rawValue: info[AVAudioSessionInterruptionTypeKey] as! UInt)
            if type == .began {
                if audioStatus == .Playing {
                    stopPlayback()
                } else if audioStatus == .Recording {
                    stopRecording()
                }
            } else {
                let options = AVAudioSessionInterruptionOptions(rawValue: info[AVAudioSessionInterruptionOptionKey] as! UInt)
                
                if options == .shouldResume {
                    // Do something here...
                }
            }
        }
    }
    
    @objc
    func handleRouteChange(notification: NSNotification) {
        if let info = notification.userInfo {
            
            let reason = AVAudioSessionRouteChangeReason(rawValue: info[AVAudioSessionRouteChangeReasonKey] as! UInt)
            if reason == .oldDeviceUnavailable {
                let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
                let previousOutput = previousRoute!.outputs.first!
                if previousOutput.portType == AVAudioSessionPortHeadphones {
                    if audioStatus == .Playing {
                        stopPlayback()
                    } else if audioStatus == .Recording {
                        stopRecording()
                    }
                }
            }
        }
    }
}
