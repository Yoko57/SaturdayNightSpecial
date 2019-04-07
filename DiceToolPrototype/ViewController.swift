

//
//  ViewController.swift
//  DiceTool
//
//  Created by Hiroyuki Nakamura on 2019/02/21.
//  Copyright © 2019 Hiroyuki Nakamura. All rights reserved.
//

import UIKit
import Photos



class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
  
  
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var backImageView: UIImageView!
  
  @IBOutlet weak var frontImageView: UIImageView!
  
  
  @IBOutlet weak var textField: UITextField!
  
  @IBOutlet weak var label: UILabel!
  
  @IBOutlet weak var pickerView: UIPickerView!
  
  ///初期値群
  // UIPickerViewに表示するデータをArrayで作成
  //let dataList = [Int](2...100) としたいけど出来なかった。
  let dataList = ["2","3","4","5","6","7","8","9","10",
                  "11","12","13","14","15","16","17","18","19","20",
                  "21","22","23","24","25","26","27","28","29","30",
                  "31","32","33","34","35","36","37","38","39","40",
                  "41","42","43","44","45","46","47","48","49","50",
                  "51","52","53","54","55","56","57","58","59","60",
                  "61","62","63","64","65","66","67","68","69","70",
                  "71","72","73","74","75","76","77","78","79","80",
                  "81","82","83","84","85","86","87","88","89","90",
                  "91","92","93","94","95","96","97","98","99","100"]
  
  //配列の宣言
  var todos: Array<String> = []
  
  //設定値を覚えるキーを設定
  let settingKey = "phase_value"
  
  //UserDefaults ユーザーデフォルト　一時記憶関連
  let userDefaults = UserDefaults.standard
	
	private weak var frontImagePicker: UIImagePickerController?
	private weak var backImagePicker: UIImagePickerController?
  
 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // pickerViewのデリゲートとデータソースの通知先を指定
    pickerView.delegate = self
    pickerView.dataSource = self
    pickerView.showsSelectionIndicator = true
    
    textField.delegate = self
    tableView.dataSource = self
    
    
    
    
    //aaaをユーザーデフォルトの収納とする
    if let aaa = userDefaults.object(forKey: "todos") {
      todos = aaa as! Array<String>
    }
    
    
    
    
  }
  
  //キーボードの機能////
  ///キーボード以外をタップするとキーボードが解除される/////////
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  
  
  ///キーボード動作
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureObserver()  //Notification発行
  }
  
  // MARK: - Notification
  
  /// Notification発行
  func configureObserver() {
    let notification = NotificationCenter.default
    notification.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                             name: UIResponder.keyboardWillShowNotification, object: nil)
    notification.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                             name: UIResponder.keyboardWillHideNotification, object: nil)
    print("Notificationを発行")
  }
  
  /// キーボードが表示時に画面をずらす。
  @objc func keyboardWillShow(_ notification: Notification?) {
    guard let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
      let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
    UIView.animate(withDuration: duration) {
      let transform = CGAffineTransform(translationX: 0, y: -(rect.size.height))
      self.view.transform = transform
    }
    print("keyboardWillShowを実行")
  }
  
  /// キーボードが降りたら画面を戻す
  @objc func keyboardWillHide(_ notification: Notification?) {
    guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
    UIView.animate(withDuration: duration) {
      self.view.transform = CGAffineTransform.identity
    }
    print("keyboardWillHideを実行")
  }
  

  
  
  
  // セルの数
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todos.count
  }
  // セルの内容を決める
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    //cell > todo > todos と入れていく。
    let todo = todos[indexPath.row]
    cell.textLabel?.text = todo
    
    //以下の一行でcellのtextLabelの位置を右寄せ（right）できる、　中央寄せだと(center)
    cell.textLabel?.textAlignment = NSTextAlignment.right
    
    return cell
  }
  
  
  
  
  
  
  ///UITableViewのセルをスワイプで削除する　arrayName => todos
  ///セルの編集許可
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
  {
    return true
  }
  
  //スワイプしたセルを削除
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCell.EditingStyle.delete {
      todos.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.fade)
      
       //保存処理を追加
       
       userDefaults.set(self.todos, forKey: "todos")
       userDefaults.synchronize()
      
    }
  }
  
  // タップした時の処理
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    if (indexPath.row == todos.count ) {
      // 最後のセルをタップしたときのみに処理される
      
      /*うまくいかなくて未実装
      label.text = "\(todos)"
      //ラベルテキストをテキストフィールドに変換
      textField.text = label.text
      */
    }
  }
  
  
   
   
   
   
   
   
  
 
  // ここからボタンを押したらアルバムを表示 front
  @IBAction func front(_ sender: Any) {
    let sourceType:UIImagePickerController.SourceType =
      UIImagePickerController.SourceType.photoLibrary
    
    // インスタンスの作成
    let frontPicker = UIImagePickerController()
    frontPicker.sourceType = sourceType
    frontPicker.delegate = self
	frontImagePicker = frontPicker
    
    self.present(frontPicker, animated: true, completion: nil)
  
    
  }
  
  // ここからボタンを押したらアルバムを表示 back
  @IBAction func back(_ sender : Any) {
    let sourceType:UIImagePickerController.SourceType =
      UIImagePickerController.SourceType.photoLibrary
    
    // インスタンスの作成
    let backPicker = UIImagePickerController()
    backPicker.sourceType = sourceType
    backPicker.delegate = self
	backImagePicker = backPicker
    
    self.present(backPicker, animated: true, completion: nil)
    
    
  }
  
 
  // UIImagePickerのデリゲートメソッド front
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // 画像を置き換える　1[editedImage] 2[originalImage] で表示される。　ちょー重要。
    // 1のときはインスタンスの生成に frontPicker.allowsEditing = true を書き込む
    // 2のときは frontPicker.allowsEditing = true を消す
	switch picker {
	case frontImagePicker:
		frontImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
		print("frontImageView")
		
	case backImagePicker:
		backImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
		print("backImageView")
		
	default:
		break
	}
      // 前の画面に戻る
      picker.dismiss(animated: true, completion: nil)
    
  }
  
  ////ここから、間違っていると思う文
  
  // UIImagePickerのデリゲートメソッド back
  // 書き方が悪いのかfrontで表示される
  func backImagePickerController(_ backPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    
    backImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    
    // 前の画面に戻る
    self.dismiss(animated: true, completion: nil)
  }
  
    ////ここまで、間違っている文
  
  
  
  
  
  
  
  
  
  
  
  ///textField関連
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {// returnキーを押した時の処理
    if let text = self.textField.text {
      todos.append(text)
      userDefaults.set(todos, forKey: "todos")
      userDefaults.synchronize()
      
      todos = userDefaults.object(forKey: "todos") as! Array<String>
    }
    
    self.textField.text = ""
    
    self.tableView.reloadData() //データをリロードする
    
    ///キーボードを閉じる
    textField.resignFirstResponder()
    return true
  }
  
  
  
  
  // UIPickerViewの列の数
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  // UIPickerViewの行数、要素の全数
  func pickerView(_ pickerView: UIPickerView,
                  numberOfRowsInComponent component: Int) -> Int {
    return dataList.count
  }
  
  // UIPickerViewに表示する配列
  func pickerView(_ pickerView: UIPickerView,
                  titleForRow row: Int,
                  forComponent component: Int) -> String? {
    
    return dataList[row]
  }
  
  // UIPickerViewのRowが選択された時の挙動
  func pickerView(_ pickerView: UIPickerView,
                  didSelectRow row: Int,
                  inComponent component: Int) {
    // 処理
    let settings = UserDefaults.standard
    settings.setValue(dataList[row], forKey: settingKey)
    settings.synchronize()
    
    
    
    
  }
  
  
  @IBAction func roll(_ sender: Any) {
    
    
    // UserDefaultsを生成
    let settings = UserDefaults.standard
    // 取得したピッカービューの値をphaseValueに渡す
    let phaseValue = settings.integer(forKey: settingKey)
    //phaseValueをscore結果に生成
    let score = phaseValue
    //scoreをpointにInt変換
    let point:Int32 = Int32(score)
    
    //ゼロを除く為に1を足す
    let dice = 1 + arc4random_uniform(UInt32(point))
    
    //結果を表示
    label.text = "\(dice)"
    
    //ラベルテキストをテキストフィールドに変換
    textField.text = label.text
    
    
    
  }
  

 }
