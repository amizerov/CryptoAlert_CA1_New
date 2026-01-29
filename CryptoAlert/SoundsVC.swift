//
//  SettingsVC.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 05.09.2021.
//

import UIKit
import AVFoundation

var player: AVAudioPlayer?

class SoundsVC: UIViewController {

    var Level = 1
    var sound: Sound?
    let webApi = WebApi()
    
    @IBOutlet weak var segLevel: UISegmentedControl!
    
    @IBOutlet weak var btn_: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    @IBOutlet weak var btn8: UIButton!
    @IBOutlet weak var btn9: UIButton!
    @IBOutlet weak var btn0: UIButton!
    
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var txtToken: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webApi.delegate = self
        
        lblVersion.text = "Версия: " + logger.Version

        txtToken.text = usr.fcmToken + " / " + usr.uuid;
        
        segLevel.selectedSegmentIndex = Level - 1
        webApi.GetSounds()
    }
    
    @IBAction func btnSave_Clicked(_ sender: UIButton) {
        webApi.SetSounds(sound!.str())
        dismiss(animated: true)
    }
    
    @IBAction func Level_Changed(_ sender: UISegmentedControl) {
        Level = sender.selectedSegmentIndex + 1
        SetColors()
    }
    
    @IBAction func btnCopy_Cliced(_ sender: UIButton) {
        UIPasteboard.general.string = usr.fcmToken
    }
    
    @IBAction func btnSoundTest(_ sender: UIButton) {
        let s = sender.tag
        sound!.s[Level-1] = s
        SetColors()
        if(s > 0) {
            playSound(s)
        }
    }
    
    func playSound(_ i: Int) {
        guard let url = Bundle.main.url(forResource: "snd\(i)", withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension SoundsVC: WebApiProtocol {
    func ApiRequestDone(_ jsonDataFromServer: Data) {
        // Доступ к контролам на форме из другого потока
        DispatchQueue.main.async {
            self.sound = Sound(fromData: jsonDataFromServer)
            self.SetColors()
        }
    }
    
    func SetColors() {
        let s = sound!.s[Level-1]
        btn_.backgroundColor = s == 0 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn1.backgroundColor = s == 1 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn2.backgroundColor = s == 2 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn3.backgroundColor = s == 3 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn4.backgroundColor = s == 4 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn5.backgroundColor = s == 5 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn6.backgroundColor = s == 6 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn7.backgroundColor = s == 7 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn8.backgroundColor = s == 8 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn9.backgroundColor = s == 9 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
        btn0.backgroundColor = s == 10 ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9228505492, green: 0.8754799962, blue: 0.8083084226, alpha: 1)
    }
}
