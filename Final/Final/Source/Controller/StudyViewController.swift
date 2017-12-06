//
//  StudyViewController.swift
//  Final
//
//  Created by Dev on 11/19/17.
//  Copyright © 2017 Zippo Xie. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class StudyViewController: UIViewController {
    
    @IBOutlet weak var easy: UIButton!
    @IBOutlet weak var hard: UIButton!
    @IBOutlet weak var bad: UIButton!
    @IBOutlet weak var good: UIButton!
    @IBOutlet weak var buttonView : UIView!
    @IBOutlet weak var title_label : UILabel!
    @IBOutlet weak var note_text_view : UITextView!
    @IBOutlet var edit_btn : UIBarButtonItem!
    
    private var audios : Array<Audio>!
    private var audioStatus: AudioStatus = .Stopped
    private var last_audioPlayer : AVAudioPlayer!
    private var counter = 0
    
    var current_card : Card?
    private var fetchedRC : NSFetchedResultsController<Card>!
    private var hard_is_hidden = false
    
    @IBAction func attest(_ sender: UIButton) {
        let level : performance!
        switch sender {
        case good:
            level = performance.good
        case bad:
            level = performance.bad
        case easy:
            level = performance.easy
        case hard:
            level = performance.hard
        default:
            level = performance.bad
            NSLog("function attest reached default switch, which should never happen.")
        }
        StudyCardService.shared.study(current_card!, with: level)
        featch_next()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "edit_selected_card_from_study") {
            if let dst = segue.destination as? CardEditTableViewController {
                dst.selectedIndexPath = fetchedRC.indexPath(forObject: current_card!)
                dst.fetchRC = fetchedRC
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        featch_next()
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer()
        //tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        // avfoundation prologue
        let nc = NotificationCenter.default
        let session = AVAudioSession.sharedInstance()
        nc.addObserver(self, selector: #selector(handleInterruption) , name: NSNotification.Name.AVAudioSessionInterruption, object: session)
        nc.addObserver(self, selector: #selector(handleRouteChange), name: NSNotification.Name.AVAudioSessionRouteChange, object: session)
    }
    
    private func featch_next() {
        note_text_view.isHidden = true
        title_label.isHidden = true
        buttonView.isHidden = true
        DispatchQueue.global().async {
            CardService.shared.saveContext(with: nil, by: self.current_card)
            self.fetchedRC = CardService.shared.find(before: CardService.allowed_foreseen_end_point, within: CardService.shared.available_now_amount > 0 ? 1 : 0)
            DispatchQueue.main.async {
                self.current_card = self.fetchedRC.fetchedObjects?.first
                self.loadnotes()
            }
        }
    }
    
    private func loadnotes() {
        if let card = current_card {
            var badge : UIImage? = nil
            if let tmp_badge = card.badge as Data? {
                badge = UIImage(data: tmp_badge)
            }
            if badge != nil {
                /*
                 * Source https://stackoverflow.com/questions/24010035/how-to-add-image-and-text-in-uitextview-in-ios
                 */
                var attributedString :NSMutableAttributedString!
                attributedString = NSMutableAttributedString(string: card.title!)
                let textAttachment = NSTextAttachment()
                textAttachment.image = badge!
                let oldWidth = textAttachment.image!.size.width;
                
                let scaleFactor = oldWidth / (title_label.frame.size.width - 10);
                textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
                let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                attributedString.append(attrStringWithImage)
                title_label.attributedText = attributedString;
            } else {
                title_label.text = current_card?.title
            }
            note_text_view.attributedText = card.note?.content as! NSAttributedString
            title_label.isHidden = false
            DispatchQueue.global().async {
                let good_time = StudyCardService.shared.humanized_interval(card: card, level: .good)
                let easy_time = StudyCardService.shared.humanized_interval(card: card, level: .easy)
                let bad_time = StudyCardService.shared.humanized_interval(card: card, level: .bad)
                let hard_time = StudyCardService.shared.humanized_interval(card: card, level: .hard)
                DispatchQueue.main.async {
                    self.bad.setAttributedTitle(NSAttributedString.init(string:"Bad\n\(bad_time)"), for: .normal)
                    self.good.setAttributedTitle(NSAttributedString.init(string:"Good\n\(good_time)"), for: .normal)
                    self.easy.setAttributedTitle(NSAttributedString.init(string: "Easy\n\(easy_time)") , for: .normal)
                    self.hard.setAttributedTitle(NSAttributedString.init(string: "Hard\n\(hard_time)") , for: .normal)
                }
            }
            navigationItem.rightBarButtonItem = edit_btn
        } else {
            title_label.text = "Congratulations! You are all set for now!"
            title_label.isHidden = false
            navigationItem.rightBarButtonItem = nil
        }
    }

}

// didTapView for showing the detail view of a card and playing audios
extension StudyViewController {
    @objc
    func didTapView(){
        if current_card != nil {
            note_text_view.isHidden = false
            buttonView.isHidden = false
            audios = current_card?.audios?.allObjects as! Array<Audio>
            
            switch audioStatus {
            case .Stopped:
                counter = audios.count - 1
                play()
            case .Playing:
                stopPlayback()
                counter = audios.count - 1
                play()
            default:
                break
            }
        }
    }
}

// play audio one by one
// MARK: - Helpers
extension StudyViewController {
    private func setSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try session.setActive(true)
        } catch let error as NSError {
            print("AVAudioSession configuration error: \(error.localizedDescription)")
        }
    }
    private func getURLforMemo() -> URL {
        let App_path = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                            FileManager.SearchPathDomainMask.userDomainMask, true) as [String])[0]
        // name from coredata
        let audio = audios[counter]
        let relative_path = audio.file_name!
        return URL.init(fileURLWithPath: App_path + relative_path)
    }
}
// MARK: - AVFoundation Methods
extension StudyViewController : AVAudioPlayerDelegate {
    // MARK: Playback
    
    private func play() {
        setSession()
        if counter != -1 {
            let fileURL = getURLforMemo()
            do {
                let tmp_audioPlayer = try AVAudioPlayer.init(contentsOf: fileURL)
                tmp_audioPlayer.delegate = self
                if tmp_audioPlayer.duration > 0.0 {
                    last_audioPlayer = tmp_audioPlayer
                    tmp_audioPlayer.play()
                    audioStatus = .Playing
                }
            } catch {
                print("Error loading audioPlayer.")
            }
        } else {audioStatus = .Stopped}
    }
    
    private func stopPlayback() {
        if last_audioPlayer != nil {
            last_audioPlayer.stop()
        }
        audioStatus = .Stopped
    }
    
    // MARK: Delegates
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NSLog("Previous audioplayer succeed: \(flag)")
        audioStatus = .Stopped
        guard counter > -1 else {
            return
        }
        counter -= 1
        play()
        NSLog("One following audio started playing")
    }
    
    
    // MARK: Notifications
    @objc
    func handleInterruption(notification: NSNotification) {
        if let info = notification.userInfo {
            let type = AVAudioSessionInterruptionType(rawValue: info[AVAudioSessionInterruptionTypeKey] as! UInt)
            if type == .began {
                if audioStatus == .Playing {
                    stopPlayback()
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
                    }
                }
            }
        }
    }
}
