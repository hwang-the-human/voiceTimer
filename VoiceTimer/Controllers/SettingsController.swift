//
//  SettingsView.swift
//  VoiceTimer
//
//  Created by Nicholas HwanG on 4/27/20.
//  Copyright © 2020 Hwang. All rights reserved.
//

import UIKit


class CustomCell: UITableViewCell {
    
    let bgView: UIView = {
        let v = UIView()
        v.backgroundColor = #colorLiteral(red: 0.2941176471, green: 0.6, blue: 0.5411764706, alpha: 1)
        v.layer.cornerRadius = 6
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 0.139524132, green: 0.1401771903, blue: 0.1417474747, alpha: 1)
        selectionStyle = .none
        
        addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bgView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bgView.centerYAnchor.constraint(equalTo: centerYAnchor),
            bgView.widthAnchor.constraint(equalTo: widthAnchor),
            bgView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
        sendSubviewToBack(bgView)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        bgView.isHidden = !selected
        
        contentView.backgroundColor = selected ? #colorLiteral(red: 0.2941176471, green: 0.6, blue: 0.5411764706, alpha: 1) : .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsController: UITableViewController {
    
    let cellId = "CellId111"
    let arrayEn = ["Text and color","Countdown","Language"]
    let arrayRu = ["Текст и цвет","Обратный отсчет","Язык"]
    
    override func viewDidAppear(_ animated: Bool) {
        title = ruMode == "Russian" || ruMode == "Русский" ? "Настройки" : "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: ruMode == "Russian" || ruMode == "Русский" ? "Отмена" : "Cancel", style: .done, target: self, action: #selector(handleCancelButton))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = #colorLiteral(red: 0.139524132, green: 0.1401771903, blue: 0.1417474747, alpha: 1)
        tableView.alwaysBounceVertical = false
        tableView.register(CustomCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.navigationController?.pushViewController(TextAndColorController(), animated: true)
        case 1:
            self.navigationController?.pushViewController(CountdownController(), animated: true)
        default:
            self.navigationController?.pushViewController(LanguageController(), animated: true)
        }
    }
    
    
    @objc func handleCancelButton() {
        closeSettings()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayEn.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = ruMode == "Russian" || ruMode == "Русский" ? arrayRu[indexPath.row] : arrayEn[indexPath.row]
        cell.textLabel?.textColor = .white
        return cell
    }
}

class LanguageController: UITableViewController {
    var selectedCell = ""
    let arrayLanguagesEn = ["English", "Russian"]
    let arrayLanguagesRu = ["Английский", "Русский"]
    let cellId = "CellId321"
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = #colorLiteral(red: 0.139524132, green: 0.1401771903, blue: 0.1417474747, alpha: 1)
        title = ruMode == "Russian" || ruMode == "Русский" ? "Язык" : "Language"
        tableView.alwaysBounceVertical = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: ruMode == "Russian" || ruMode == "Русский" ? "Сохранить" : "Save", style: .done, target: self, action: #selector(handleSaveButton))
        tableView.register(CustomCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc func handleSaveButton() {
        if !selectedCell.isEmpty {
            ruMode = selectedCell
            defaults.set(selectedCell, forKey: "Language")
        }
        closeSettings()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            for row in 0..<tableView.numberOfRows(inSection: indexPath.section) {
                if let cell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section)) {
                    cell.accessoryType = row == indexPath.row ? .checkmark : .none
                }
            }
            selectedCell = cell.textLabel?.text ?? ""
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayLanguagesEn.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = ruMode == "Russian" || ruMode == "Русский" ? arrayLanguagesRu[indexPath.row] : arrayLanguagesEn[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.tintColor = .white
        checkLanguage(cellText: (cell.textLabel?.text)!)
        if cell.textLabel?.text == ruMode {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func checkLanguage(cellText: String) {
        if cellText == "Русский" {
            if ruMode == "Russian" {
                ruMode = "Русский"
            }
            if ruMode == "English" {
                ruMode = "Английский"
            }
        } else {
            if ruMode == "Английский" {
                ruMode = "English"
            }
            if ruMode == "Русский" {
                ruMode = "Russian"
            }
        }
    }
}


class CountdownController: UITableViewController {
    
    var selectedCell = ""
    let arrayDigitsEn = ["0 s","3 s","6 s","10 s"]
    let arrayDigitsRu = ["0 с","3 с","6 с","10 с"]
    let cellId = "CellId123"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = #colorLiteral(red: 0.139524132, green: 0.1401771903, blue: 0.1417474747, alpha: 1)
        title = ruMode == "Russian"  || ruMode == "Русский" ? "Обратный отсчет" : "Countdown"
        tableView.alwaysBounceVertical = false
        tableView.register(CustomCell.self, forCellReuseIdentifier: cellId)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: ruMode == "Russian" || ruMode == "Русский" ? "Сохранить" : "Save", style: .done, target: self, action: #selector(handleSaveButton))
    }
    
    @objc func handleSaveButton() {
        let cleanedSelectedCell = selectedCell.dropLast(2)
        if !cleanedSelectedCell.isEmpty {
            
            if cleanedSelectedCell == "0" {
                isBackwards = false
            } else {
                isBackwards = true
            }
            if !audio.isPlaying {
                seconds = Int(cleanedSelectedCell)!
            }
            defaults.set(cleanedSelectedCell, forKey: "StartAt")
        }
        closeSettings()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            for row in 0..<tableView.numberOfRows(inSection: indexPath.section) {
                if let cell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section)) {
                    cell.accessoryType = row == indexPath.row ? .checkmark : .none
                }
            }
            selectedCell = cell.textLabel?.text ?? ""
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDigitsEn.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = ruMode == "Russian" || ruMode == "Русский" ? arrayDigitsRu[indexPath.row] : arrayDigitsEn[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.tintColor = .white
        if String((cell.textLabel?.text?.dropLast(2))!) == String(defaults.string(forKey: "StartAt") ?? "0") {
            cell.accessoryType = .checkmark
        }
        return cell
    }
}

class TextAndColorController: UIViewController {
    
    var selectedColor = ""
    
    let formatArrayEn = ["Hours","Minutes","Seconds","Hundredths"]
    let formatArrayRu = ["Часы","Минуты","Секунды","Сотые"]
    let colorArray = [
        ["Blue",
         "Brown",
         "Gray",
         "Green",
         "Indigo",
         "Orange"],
        
        ["Pink",
         "Purple",
         "Red",
         "Teal",
         "Yellow",
         "White"]
    ]
    var arrayFormatRow = [UIButton]()
    var arrayRow1 = [UIButton]()
    var arrayRow2 = [UIButton]()
    
    var dummyTimerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Courier", size: 30)
        label.textColor = UIColor(named: timerLabelColor)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.139524132, green: 0.1401771903, blue: 0.1417474747, alpha: 1)
        title = ruMode == "Russian" || ruMode == "Русский" ? "Текст и цвет" : "Text and color"
        setupConstraints()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: ruMode == "Russian" || ruMode == "Русский" ? "Сохранить" : "Save", style: .done, target: self, action: #selector(handleSaveButton))
    }
    
    
    @objc func handleSaveButton() {
        if !selectedColor.isEmpty {
            timerLabel.textColor = UIColor(named: selectedColor)
            timerLabelColor = selectedColor
            defaults.set(selectedColor, forKey: "Color")
        }
        defaults.set(selectedHours, forKey: "Hours")
        defaults.set(selectedMinutes, forKey: "Minutes")
        defaults.set(selectedSeconds, forKey: "Seconds")
        defaults.set(selectedFractions, forKey: "Fractions")
        
        stringHours = selectedHours
        stringMinutes = selectedMinutes
        stringSeconds = selectedSeconds
        stringFractions = selectedFractions
        
        
        switch dummyTimerLabel.text?.count {
        case 2:
            timerLabelFont = 2.5
        case 5:
            timerLabelFont = 3.5
        case 8:
            timerLabelFont = 5
        default:
            timerLabelFont = 7
        }
        
        timerLabel.font = UIFont(name: "Courier", size:  UIScreen.main.bounds.width / CGFloat(timerLabelFont))
        defaults.set(timerLabelFont, forKey: "Font")
        
        timerLabel.text = dummyTimerLabel.text
        closeSettings()
    }
    
    
    @objc func handleColorButton(_ button: UIButton) {
        guard let buttonColor = button.titleLabel?.text else { return }
        dummyTimerLabel.textColor = UIColor(named: buttonColor)
        selectedColor = buttonColor
        
        UIView.animate(withDuration: 0.3) {
            button.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            for button in (self.arrayRow1 + self.arrayRow2) {
                if button.titleLabel?.text != self.selectedColor {
                    button.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
        }
    }
    
    var selectedHours = stringHours == "" ? stringHours : "00:"
    var selectedMinutes = stringMinutes == "" ? stringMinutes : "00:"
    var selectedSeconds = stringSeconds == "" ? stringSeconds : "00"
    var selectedFractions = stringFractions == "" ? stringFractions : ".00"
    
    
    @objc func handleFormatButton(_ button: UIButton) {
        guard let buttonText = button.titleLabel?.text else { return }
        guard let buttonColor = button.backgroundColor else { return }
        switch buttonText {
        case ruMode == "Russian" || ruMode == "Русский" ? "Часы" : "Hours":
            if buttonColor == #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) && dummyTimerLabel.text!.count > 2 {
                selectedHours = ""
                button.backgroundColor = .clear
            } else {
                selectedHours = "00:"
                button.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
        case ruMode == "Russian" || ruMode == "Русский" ? "Минуты" : "Minutes":
            if buttonColor == #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) && dummyTimerLabel.text!.count > 2 {
                selectedMinutes = ""
                button.backgroundColor = .clear
            } else {
                selectedMinutes = "00:"
                button.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
        case ruMode == "Russian" || ruMode == "Русский" ? "Секунды" : "Seconds":
            if selectedFractions.isEmpty {
                if !selectedSeconds.isEmpty && dummyTimerLabel.text!.count > 2 {
                    selectedSeconds = ""
                    button.backgroundColor = .clear
                } else {
                    selectedSeconds = "00"
                    button.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                }
            }
        default:
            if !selectedSeconds.isEmpty {
                if !selectedFractions.isEmpty && dummyTimerLabel.text!.count > 2{
                    selectedFractions = ""
                    button.backgroundColor = .clear
                } else {
                    selectedFractions = ".00"
                    button.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                }
            }
        }
        dummyTimerLabel.text = selectedHours + selectedMinutes + selectedSeconds + selectedFractions
        if dummyTimerLabel.text?.last == ":" {
            dummyTimerLabel.text?.removeLast()
        }
    }
    
    func setupConstraints() {
        
        dummyTimerLabel.text = selectedHours + selectedMinutes + selectedSeconds + selectedFractions
        view.addSubview(dummyTimerLabel)
        dummyTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dummyTimerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 46),
            dummyTimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        setupFormatButtons()
        let stackFormatRow = UIStackView(arrangedSubviews: arrayFormatRow)
        view.addSubview(stackFormatRow)
        stackFormatRow.spacing = 12
        stackFormatRow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackFormatRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackFormatRow.topAnchor.constraint(equalTo: dummyTimerLabel.bottomAnchor, constant: 18)
        ])
        
        setupColorButtons()
        let stackRow1 = UIStackView(arrangedSubviews: arrayRow1)
        view.addSubview(stackRow1)
        stackRow1.spacing = 12
        stackRow1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackRow1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackRow1.topAnchor.constraint(equalTo: stackFormatRow.bottomAnchor, constant: 18)
        ])
        
        let stackRow2 = UIStackView(arrangedSubviews: arrayRow2)
        view.addSubview(stackRow2)
        stackRow2.spacing = 12
        stackRow2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackRow2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackRow2.topAnchor.constraint(equalTo: stackRow1.bottomAnchor, constant: 12)
        ])
    }
    
    func setupFormatButtons() {
        for format in ruMode == "Russian" || ruMode == "Русский" ? formatArrayRu : formatArrayEn {
                let button = UIButton(type: .system)
                button.backgroundColor = UIColor(named: format)
                button.setTitle(format, for: .normal)
                button.layer.cornerRadius = 10
                button.tintColor = .white
                button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
                button.addTarget(self, action: #selector(handleFormatButton), for: .touchUpInside)
                
                switch button.titleLabel?.text {
                case ruMode == "Russian" || ruMode == "Русский" ? "Часы" : "Hours":
                    if !stringHours.isEmpty {
                        button.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    } else {
                        button.backgroundColor = .clear
                    }
                case ruMode == "Russian" || ruMode == "Русский" ? "Минуты" : "Minutes":
                    if !stringMinutes.isEmpty {
                        button.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    } else {
                        button.backgroundColor = .clear
                    }
                case ruMode == "Russian" || ruMode == "Русский" ? "Секунды" : "Seconds":
                    if !stringSeconds.isEmpty {
                        button.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    } else {
                        button.backgroundColor = .clear
                    }
                default:
                    if !stringFractions.isEmpty {
                        button.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    } else {
                        button.backgroundColor = .clear
                    }
                }
                arrayFormatRow.append(button)
            }
        
    }
    
    func setupColorButtons() {
        for array in colorArray {
            for color in array {
                let button = UIButton(type: .system)
                button.backgroundColor = UIColor(named: color)
                button.titleLabel?.text = color
                button.layer.cornerRadius = 10
                if button.titleLabel?.text == timerLabelColor {
                    button.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                }
                button.addTarget(self, action: #selector(handleColorButton), for: .touchUpInside)
                if colorArray[0].contains(color) {
                    arrayRow1.append(button)
                } else {
                    arrayRow2.append(button)
                }
                
            }
        }
    }
}

