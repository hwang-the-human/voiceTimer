//
//  ViewController.swift
//  VoiceTimer
//
//  Created by Nicholas HwanG on 4/15/20.
//  Copyright © 2020 Hwang. All rights reserved.
//

import UIKit
import AVFoundation


let timerLabel = UILabel()
var timerLabelFont = defaults.double(forKey: "Font")
let intervalButton = UIButton(type: .system)
let defaults = UserDefaults.standard
var timer = Timer()
let startTimerButton = UIButton(type: .system)
let resetTimerButton = UIButton(type: .system)
var isSettingsClosed = true
let settingsController = UINavigationController(rootViewController: SettingsController())
let settingsButton = UIButton(type: .system)
var stringFractions = defaults.string(forKey: "Fractions") ?? ".00"
var stringSeconds = defaults.string(forKey: "Seconds") ?? "00"
var stringMinutes = defaults.string(forKey:"Minutes") ?? "00:"
var stringHours = defaults.string(forKey:"Hours") ?? "00:"

func closeSettings() {
    isSettingsClosed = true
    settingsController.popToRootViewController(animated: true)
    let settingsView = settingsController.view!
    UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
        settingsView.frame = CGRect(x: settingsButton.frame.origin.x, y: settingsButton.frame.origin.y, width: 1, height: 1)
        settingsView.layer.cornerRadius = settingsButton.bounds.width / 2
        
    }, completion: { _ in
        if settingsView.frame.width == 1 {
            settingsView.removeFromSuperview()
        }
    })
}


var ruMode = defaults.string(forKey:"Language") ?? "English" {
    didSet {
        changeLanguageButtons()
    }
}


var timerLabelColor = defaults.string(forKey: "Color") ?? "White" {
    didSet {
        timerLabel.textColor = UIColor(named: timerLabelColor)
    }
}

func changeLanguageButtons() {
    intervalButton.setTitle(ruMode == "Russian" || ruMode == "Русский" ? "1 с" : "1 s", for: .normal)
    if ruMode == "Russian" || ruMode == "Русский" {
        if !timer.isValid {
            startTimerButton.setTitle("Пуск", for: .normal)
        } else {
            startTimerButton.setTitle("Стоп", for: .normal)
        }
        resetTimerButton.setTitle("Сброс", for: .normal)
    } else {
        if !timer.isValid {
            startTimerButton.setTitle("Start", for: .normal)
        } else {
            startTimerButton.setTitle("Stop", for: .normal)
        }
        resetTimerButton.setTitle("Reset", for: .normal)
    }
}



var audio = AVAudioPlayer()
var positionVoice = 0
var fixedSeconds = 0
var isClosedInterval = true
var intervalSeconds = 1
var isMute = false
var isBackwards = defaults.string(forKey: "StartAt") ?? "0" == "0" ? false : true


var fractions = 0
var minutes = 0
var hours = 0
var seconds = Int(defaults.string(forKey: "StartAt") ?? "0")! {
    didSet {
        if seconds != 60 && timer.isValid && seconds % intervalSeconds == 0 && !audio.isPlaying && isMute == false {
            playAudio(playSound: String(minutes))
        }
    }
}

let mainController = MainController()
func playAudio(playSound: String) {
    var first = playSound
    
    //start
    if positionVoice == 0 && minutes == 0 {
        fixedSeconds = seconds
        first = String(fixedSeconds)
        positionVoice = 5
    }
    
    //seconds
    if intervalSeconds == 1 && positionVoice == 0 && minutes != 60 {
        fixedSeconds = seconds
        if fixedSeconds == 0 {
            first = String(minutes)
            positionVoice = 0
        } else {
            first = String(fixedSeconds)
            positionVoice = 5
        }
    }
    
    //minutes
    if positionVoice == 0 && minutes != 0 && minutes != 60 {
        fixedSeconds = seconds
        if minutes > 20 {
            first = String(String(minutes).dropLast() + "0")
        } else {
            if ruMode == "Russian" || ruMode == "Русский" {
                if first == ("1") || first == ("2") {
                    first += "f"
                }
            }
        }
    }
    
    //hours
    if minutes == 60 {
        if hours >= 20 {
            first = String(String(hours + 1).dropLast() + "0")
        } else {
            first = String(hours + 1)
        }
    }
    
    if fixedSeconds > 20 && positionVoice == 5 {
        first = String(String(fixedSeconds).dropLast() + "0")
    }
    
    //Backwards
    if isBackwards == true && first.count == 1 {
        first = String(Int(first)! + 1)
    }
    
    let path = Bundle.main.path(forResource: "\(ruMode == "Russian" || ruMode == "Русский" ? first : first + "E").wav", ofType: nil)
    let url = URL(fileURLWithPath: path ?? "")
    
    audio = try! AVAudioPlayer(contentsOf: url)
    audio.enableRate = true
    
    if (intervalSeconds == 1 && fixedSeconds > 20) {
        audio.rate = 1.8
    } else if intervalSeconds == 1 && fixedSeconds <= 20{
        audio.rate = 1.3
    }
    audio.play()
    audio.delegate = mainController
}

class MainController: UIViewController, AVAudioPlayerDelegate {

    func playSound(sound: String) {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: nil)!)
        audio = try! AVAudioPlayer(contentsOf: url)
        audio.play()
    }
    
    
    func setupTimerLabel() {
        timerLabel.text = stringHours + stringMinutes + stringSeconds + stringFractions
        if timerLabel.text?.last == ":" {
            timerLabel.text?.removeLast()
        }
        
        timerLabel.textColor = UIColor(named: timerLabelColor)
        timerLabel.font = UIFont(name: "Courier", size: view.bounds.width / CGFloat(timerLabelFont == 0.0 ? 7.0 : timerLabelFont))
        
        view.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
        ])
    }
    
    
    func setupStartTimerButton() {
        startTimerButton.addTarget(self, action: #selector(handleStartTimerButton), for: .touchUpInside)
        startTimerButton.setTitleColor(#colorLiteral(red: 0.1751384139, green: 0.8418140411, blue: 0.3555551469, alpha: 1), for: .normal)
        startTimerButton.layer.cornerRadius = 27.5
        startTimerButton.backgroundColor = #colorLiteral(red: 0.0304622706, green: 0.1649007201, blue: 0.0674418062, alpha: 1)
    }
    
    func setupResetTimerButton() {
        resetTimerButton.addTarget(self, action: #selector(handleResetTimerButton), for: .touchUpInside)
        resetTimerButton.setTitleColor(.white, for: .normal)
        resetTimerButton.layer.cornerRadius = 27.5
        resetTimerButton.backgroundColor = #colorLiteral(red: 0.08451976627, green: 0.08668354899, blue: 0.0895697549, alpha: 1)
        resetTimerButton.isEnabled = false
    }
    
    func setupSettingsButton() {
        settingsButton.backgroundColor = .black
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        settingsButton.setImage(#imageLiteral(resourceName: "Settings"), for: .normal)
        settingsButton.addTarget(self, action: #selector(handleSettingsButton), for: .touchUpInside)
    }
    
    func setupIntervalButton() {
        intervalButton.setTitle(ruMode == "Russian" || ruMode == "Русский" ? "1 с" : "1 s", for: .normal)
        intervalButton.titleLabel?.font = .systemFont(ofSize: 18)
        intervalButton.addTarget(self, action: #selector(handleIntervalButton), for: .touchUpInside)
        intervalButton.imageView?.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
        intervalButton.setTitleColor(.white, for: .normal)
        intervalButton.clipsToBounds = true
        intervalButton.layer.cornerRadius = 27.5
        intervalButton.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.2, blue: 0.2039215686, alpha: 1)
    }
    
    
    let interval1Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1", for: .normal)
        button.addTarget(self, action: #selector(handleIntervalNumbersButton), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        button.tintColor = .black
        return button
    }()
    
    let interval10Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("10", for: .normal)
        button.addTarget(self, action: #selector(handleIntervalNumbersButton), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        button.tintColor = .black
        return button
    }()
    
    let interval20Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("20", for: .normal)
        button.addTarget(self, action: #selector(handleIntervalNumbersButton), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        button.tintColor = .black
        return button
    }()
    
    let interval30Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("30", for: .normal)
        button.addTarget(self, action: #selector(handleIntervalNumbersButton), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        button.tintColor = .black
        return button
    }()
    
    let interval60Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("60", for: .normal)
        button.addTarget(self, action: #selector(handleIntervalNumbersButton), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        button.tintColor = .black
        return button
    }()
    
    let muteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "noSound"), for: .normal)
        button.addTarget(self, action: #selector(handleIntervalNumbersButton), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        return button
    }()
    
    var pulsatingLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 25, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.fillColor = #colorLiteral(red: 0.0304622706, green: 0.1649007201, blue: 0.0674418062, alpha: 0.5)
        layer.lineCap = .round
        return layer
    }()
    
    let bgView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        view.backgroundColor = .black
        setupTimerLabel()
        changeLanguageButtons()
        setUpConstraints()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        bgView.addGestureRecognizer(tap)
        
        var sound = "enWelcome.wav"
        if ruMode == "Russian" || ruMode == "Русский" {
            sound = "ruWelcome.wav"
        }
        playSound(sound: sound)
        
        
        setupStartTimerButton()
        setupResetTimerButton()
    }
    
    @objc func handleTapGesture() {
        isClosedInterval = true
        performClosingInterval()
        closeSettings()
        bgView.isUserInteractionEnabled = false
    }
    
    
    @objc func handleSettingsButton() {
        if isSettingsClosed {
            openSettings()
        } else {
            closeSettings()
        }
    }
    
    func openSettings() {
        let settingsView = settingsController.view!
        view.addSubview(settingsView)
        isSettingsClosed = false
        bgView.isUserInteractionEnabled = true
        
        let width = self.view.frame.width * 0.5
        let height = self.view.frame.height * 0.6
        
        settingsView.frame = settingsButton.frame
        settingsView.layer.cornerRadius = width * 0.03
        
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
            settingsView.frame = CGRect(x: width * 0.5, y: height * 0.3, width: width, height: height)
            
        }, completion: nil)
    }
    
    @objc func handleIntervalButton() {
        isClosedInterval.toggle()
        performClosingInterval()
        bgView.isUserInteractionEnabled = true
    }
    
    func performClosingInterval() {
        adjustConstraint(centerY: centerXConstraint1, centerX: centerYConstraint1, y: -60, x: 0)
        adjustConstraint(centerY: centerXConstraint10, centerX: centerYConstraint10, y: -40, x: 50)
        adjustConstraint(centerY: centerXConstraint20, centerX: centerYConstraint20, y: 0, x: 70)
        adjustConstraint(centerY: centerXConstraint30, centerX: centerYConstraint30, y: 40, x: 50)
        adjustConstraint(centerY: centerXConstraint60, centerX: centerYConstraint60, y: 60, x: 0)
        adjustConstraint(centerY: centerXConstraintMute, centerX: centerYConstraintMute, y: 40, x: -50)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func adjustConstraint(centerY: NSLayoutConstraint, centerX: NSLayoutConstraint, y: CGFloat, x: CGFloat) {
        if isClosedInterval {
            centerY.constant = 0
            centerX.constant = 0
        } else {
            centerY.constant = x
            centerX.constant = y
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let hourString = wordEnding(time: hours,ending: "hour")
        let minuteString = wordEnding(time: minutes,ending: "minute")
        let secondString = wordEnding(time: fixedSeconds,ending: "second")
        
        let hour = String(String(hours).dropFirst())
        var minute = String(String(minutes).dropFirst())
        let second = String(String(fixedSeconds).dropFirst())

        
        positionVoice += 1
        switch positionVoice {
        case 1:
            //hour second digit
            if minutes == 0 && hour != "0" && hours > 20{
                playAudio(playSound: hour)
            } else {
                positionVoice += 1
                fallthrough
            }
        case 2:
            //hour name
            if minutes == 0 {
                playAudio(playSound: hourString)
            } else {
                positionVoice += 1
                fallthrough
            }
        case 3:
            //minute second digit
            if !minute.isEmpty && minute != "0" && minutes > 20{
                if ruMode == "Russian" || ruMode == "Русский" {
                    if minute == ("1") || minute == ("2") {
                        minute += "f"
                    }
                }
                playAudio(playSound: minute)
            } else {
                positionVoice += 1
                fallthrough
            }
        case 4:
            //minute name
            if minutes != 0 {
                playAudio(playSound: minuteString)
            } else {
                fallthrough
            }
        case 5:
            //second first digit
            if fixedSeconds != 0  {
                playAudio(playSound: String(fixedSeconds))
            } else {
                positionVoice = 0
            }
            
        case 6:
            //second second digit
            if !second.isEmpty && second != "0" && fixedSeconds > 20 {
                playAudio(playSound: second)
            } else {
                positionVoice += 1
                fallthrough
            }
        case 7:
            //second name
            if intervalSeconds != 1 {
                playAudio(playSound: secondString)
            } else {
                fallthrough
            }
        default:
            positionVoice = 0
        }
    }
    
    
    fileprivate func wordEnding(time: Int, ending: String) -> String {
        var word = ending
        var finalTime = time
        
        if ruMode == "Russian" || ruMode == "Русский" {
            if finalTime > 20 && finalTime % 10 != 0 {
                finalTime = Int(String(String(finalTime).dropFirst()))!
            }
            if (finalTime >= 2 && finalTime <= 4) {
                word = ending + "s-i"
            } else if (finalTime >= 5) {
                word = ending + "s"
            }
        } else {
            if finalTime > 1 {
                word = ending + "s"
            }
        }
        return word
    }
    
    
    @objc func handleIntervalNumbersButton(_ sender: UIButton) {
        if let titleButton = sender.titleLabel?.text {
            if !isBackwards {
                intervalSeconds = Int(titleButton)!
            }
            cacheIntervalSeconds = Int(titleButton)!
            
            intervalButton.setImage(nil, for: .normal)
            isMute = false
            let unit = ruMode == "Russian" || ruMode == "Русский" ? " с" : " s"
            intervalButton.setTitle(titleButton + unit, for: .normal)
        } else {
            intervalButton.setTitle(nil, for: .normal)
            intervalButton.setImage(#imageLiteral(resourceName: "noSound"), for: .normal)
            isMute = true
        }
        isClosedInterval = true
        performClosingInterval()
    }
    
    @objc func handleStartTimerButton() {
        isClosedInterval = true
        resetTimerButton.backgroundColor = #colorLiteral(red: 0.195157975, green: 0.2000818253, blue: 0.2043786943, alpha: 1)
        resetTimerButton.isEnabled = true
        performClosingInterval()
        if !timer.isValid {
            if ruMode == "Russian" || ruMode == "Русский" {
                startTimerButton.setTitle("Стоп", for: .normal)
            } else {
                startTimerButton.setTitle("Stop", for: .normal)
            }
            startTimerButton.setTitleColor(#colorLiteral(red: 0.9879780412, green: 0.2754618526, blue: 0.2317728102, alpha: 1), for: .normal)
            startTimerButton.backgroundColor = #colorLiteral(red: 0.1984860599, green: 0.05833175033, blue: 0.04402955621, alpha: 1)
            pulsatingLayer.fillColor = #colorLiteral(red: 0.1984860599, green: 0.05833175033, blue: 0.04402955621, alpha: 0.5)
            animatePulsatingLayer(duration: 0.3)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(keepTimer), userInfo: nil, repeats: true)
        } else {
            if ruMode == "Russian" || ruMode == "Русский" {
                startTimerButton.setTitle("Пуск", for: .normal)
            } else {
                startTimerButton.setTitle("Start", for: .normal)
            }
            startTimerButton.setTitleColor(#colorLiteral(red: 0.1751384139, green: 0.8418140411, blue: 0.3555551469, alpha: 1), for: .normal)
            startTimerButton.backgroundColor = #colorLiteral(red: 0.0304622706, green: 0.1649007201, blue: 0.0674418062, alpha: 1)
            pulsatingLayer.fillColor = #colorLiteral(red: 0.0304622706, green: 0.1649007201, blue: 0.0674418062, alpha: 0.5)
            animatePulsatingLayer(duration: 0.8)
            timer.invalidate()
        }
        if isBackwards {
            intervalSeconds = 1
        }
    }
    var cacheIntervalSeconds = 1
    
    @objc func handleResetTimerButton() {
        isClosedInterval = true
        performClosingInterval()
        timer.invalidate()
        checkTimerLabel()
        if ruMode == "Russian" || ruMode == "Русский" {
            startTimerButton.setTitle("Пуск", for: .normal)
        } else {
            startTimerButton.setTitle("Start", for: .normal)
        }
        startTimerButton.setTitleColor(#colorLiteral(red: 0.1751384139, green: 0.8418140411, blue: 0.3555551469, alpha: 1), for: .normal)
        startTimerButton.backgroundColor = #colorLiteral(red: 0.0304622706, green: 0.1649007201, blue: 0.0674418062, alpha: 1)
        pulsatingLayer.fillColor = #colorLiteral(red: 0.0304622706, green: 0.1649007201, blue: 0.0674418062, alpha: 0.5)
        animatePulsatingLayer(duration: 0.8)
        (hours, minutes, fractions) = (0,0,0)
        let startAt = Int(defaults.string(forKey: "StartAt") ?? "0")!
        if startAt == 0 {
            isBackwards = false
        } else {
            isBackwards = true
        }
        seconds = startAt
        resetTimerButton.backgroundColor = #colorLiteral(red: 0.08451976627, green: 0.08668354899, blue: 0.0895697549, alpha: 1)
        resetTimerButton.isEnabled = false
    }
    
    func checkTimerLabel() {
        var freeText = ""
        if !stringHours.isEmpty {
            freeText += "00:"
        }
        if !stringMinutes.isEmpty {
            freeText += "00:"
        }
        if !stringSeconds.isEmpty {
            freeText += "00"
        }
        if !stringFractions.isEmpty {
            freeText += ".00"
        }
        if freeText.last == ":" {
            freeText.removeLast()
        }
        timerLabel.text! = freeText
    }
    
    
    @objc func keepTimer() {
        if isBackwards {
            fractions -= 1
            if fractions < 1 {
                seconds -= 1
                fractions = 99
            }
            if seconds == 0 && fractions <= 1 {
                isBackwards = false
                playSound(sound: "Beep.mp3")
                intervalSeconds = cacheIntervalSeconds
            }
        } else {
            
            fractions += 1
        }
        
        
        if fractions > 99 {
            seconds += 1
            fractions = 0
        }
        if seconds == 60 {
            minutes += 1
            seconds = 0
        }
        
        if minutes == 60 {
            hours += 1
            minutes = 0
        }
        
        if !stringFractions.isEmpty {
            stringFractions = fractions > 9 ? ".\(fractions)" : ".0\(fractions)"
        }
        if !stringSeconds.isEmpty {
            stringSeconds = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        }
        if !stringMinutes.isEmpty {
            stringMinutes = minutes > 9 ? "\(minutes):" : "0\(minutes):"
        }
        if !stringHours.isEmpty {
            stringHours = hours > 9 ? "\(hours):" : "0\(hours):"
        }
        
        timerLabel.text = stringHours + stringMinutes + stringSeconds + stringFractions
        if timerLabel.text?.last == ":" {
            timerLabel.text?.removeLast()
        }
        
    }
    
    
    var centerYConstraint1: NSLayoutConstraint!
    var centerXConstraint1: NSLayoutConstraint!

    var centerYConstraint10: NSLayoutConstraint!
    var centerXConstraint10: NSLayoutConstraint!
    
    var centerYConstraint20: NSLayoutConstraint!
    var centerXConstraint20: NSLayoutConstraint!
    
    var centerYConstraint30: NSLayoutConstraint!
    var centerXConstraint30: NSLayoutConstraint!
    
    var centerYConstraint60: NSLayoutConstraint!
    var centerXConstraint60: NSLayoutConstraint!
    
    var centerYConstraintMute: NSLayoutConstraint!
    var centerXConstraintMute: NSLayoutConstraint!
    
    
    fileprivate func setUpConstraints() {
        view.addSubview(bgView)
        bgView.backgroundColor = .clear
        bgView.frame = view.frame
        
        setupSettingsButton()
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -26),
            settingsButton.widthAnchor.constraint(equalToConstant: 35),
            settingsButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        
        
        let emptyCircleInterval = UIView()
        view.addSubview(emptyCircleInterval)
        emptyCircleInterval.translatesAutoresizingMaskIntoConstraints = false
        emptyCircleInterval.clipsToBounds = true
        emptyCircleInterval.layer.cornerRadius = 35
        
        let stackViewButtons = UIStackView(arrangedSubviews: [
            resetTimerButton,
            startTimerButton,
            emptyCircleInterval
        ])
        stackViewButtons.spacing = 70
        view.addSubview(stackViewButtons)
        stackViewButtons.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackViewButtons.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            stackViewButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetTimerButton.widthAnchor.constraint(equalToConstant: 55),
            resetTimerButton.heightAnchor.constraint(equalToConstant: 55),
            startTimerButton.widthAnchor.constraint(equalToConstant: 55),
            startTimerButton.heightAnchor.constraint(equalToConstant: 55),
            emptyCircleInterval.widthAnchor.constraint(equalToConstant: 55),
            emptyCircleInterval.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        view.addSubview(interval1Button)
        interval1Button.translatesAutoresizingMaskIntoConstraints = false
        centerYConstraint1 = interval1Button.centerYAnchor.constraint(equalTo: emptyCircleInterval.centerYAnchor, constant: 0)
        centerXConstraint1 = interval1Button.centerXAnchor.constraint(equalTo: emptyCircleInterval.centerXAnchor, constant: 0)
        NSLayoutConstraint.activate([
            centerYConstraint1,
            centerXConstraint1
        ])
        
        view.addSubview(interval10Button)
        interval10Button.translatesAutoresizingMaskIntoConstraints = false
        centerYConstraint10 = interval10Button.centerYAnchor.constraint(equalTo: emptyCircleInterval.centerYAnchor, constant: 0)
        centerXConstraint10 = interval10Button.centerXAnchor.constraint(equalTo: emptyCircleInterval.centerXAnchor, constant: 0)
        NSLayoutConstraint.activate([
            centerYConstraint10,
            centerXConstraint10
        ])
        
        view.addSubview(interval20Button)
        interval20Button.translatesAutoresizingMaskIntoConstraints = false
        centerYConstraint20 = interval20Button.centerYAnchor.constraint(equalTo: emptyCircleInterval.centerYAnchor, constant: 0)
        centerXConstraint20 = interval20Button.centerXAnchor.constraint(equalTo: emptyCircleInterval.centerXAnchor, constant: 0)
        NSLayoutConstraint.activate([
            centerYConstraint20,
            centerXConstraint20
        ])
        
        view.addSubview(interval30Button)
        interval30Button.translatesAutoresizingMaskIntoConstraints = false
        centerYConstraint30 = interval30Button.centerYAnchor.constraint(equalTo: emptyCircleInterval.centerYAnchor, constant: 0)
        centerXConstraint30 = interval30Button.centerXAnchor.constraint(equalTo: emptyCircleInterval.centerXAnchor, constant: 0)
        NSLayoutConstraint.activate([
            centerYConstraint30,
            centerXConstraint30
        ])
        
        view.addSubview(interval60Button)
        interval60Button.translatesAutoresizingMaskIntoConstraints = false
        centerYConstraint60 = interval60Button.centerYAnchor.constraint(equalTo: emptyCircleInterval.centerYAnchor, constant: 0)
        centerXConstraint60 = interval60Button.centerXAnchor.constraint(equalTo: emptyCircleInterval.centerXAnchor, constant: 0)
        NSLayoutConstraint.activate([
            centerYConstraint60,
            centerXConstraint60
        ])
        
        view.addSubview(muteButton)
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        centerYConstraintMute = muteButton.centerYAnchor.constraint(equalTo: emptyCircleInterval.centerYAnchor, constant: 0)
        centerXConstraintMute = muteButton.centerXAnchor.constraint(equalTo: emptyCircleInterval.centerXAnchor, constant: 0)
        NSLayoutConstraint.activate([
            muteButton.widthAnchor.constraint(equalToConstant: 35),
            muteButton.heightAnchor.constraint(equalToConstant: 35),
            centerYConstraintMute,
            centerXConstraintMute
        ])
        
        setupIntervalButton()
        view.addSubview(intervalButton)
        intervalButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            intervalButton.centerYAnchor.constraint(equalTo: emptyCircleInterval.centerYAnchor),
            intervalButton.centerXAnchor.constraint(equalTo: emptyCircleInterval.centerXAnchor),
            intervalButton.widthAnchor.constraint(equalToConstant: 55),
            intervalButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        startTimerButton.layer.addSublayer(pulsatingLayer)
        pulsatingLayer.position = CGPoint(x: 27.5, y: 27.5)
        animatePulsatingLayer(duration: 0.8)
    }
    
    private func animatePulsatingLayer(duration: Double) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.3
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
}
