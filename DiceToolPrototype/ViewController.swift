

//
//  ViewController.swift
//  DiceTool
//
//  Created by Hiroyuki Nakamura on 2019/02/21.
//  Copyright © 2019 Hiroyuki Nakamura. All rights reserved.
//

import UIKit
import Photos
import AVKit
import AVFoundation



class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
  
  
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var backImageView: UIImageView!
  
  @IBOutlet weak var frontImageView: UIImageView!
  
  @IBOutlet weak var iconImageView: UIImageView!
  
  @IBOutlet weak var movieView: UIImageView!
  
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
	
  //動画関連
  let movieImagePicker = UIImagePickerController()
  var videoURL: URL?

  //アイコン
  private weak var addIconImagePicker: UIImagePickerController?
  private weak var iconImagePicker: UIImagePickerController?
  
  // タッチしたビューの中心とタッチした場所の座標のズレを保持する変数
  var gapX:CGFloat = 0.0  // x座標
  var gapY:CGFloat = 0.0  // y座標
  
  
  /// loveeさんから加筆してもらった文
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
     
      
      
       /// EditingStyle.insert （挿入？）を見つけたが、使い方を理解できていない。　「コピー欄」を実装したい。
    }/*  else if editingStyle == UITableViewCell.EditingStyle.insert {
      todos.append("test")
      tableView.setEditing(false, animated: true)
      tableView.reloadData() */
    }
    
 
  
    
    
  // タップした時の処理
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    if (indexPath.row == todos.count ) {
      // 最後のセルをタップしたときのみに処理される
      
      
      
      /*
      //うまくいかなくて未実装 セルのstringをラベルテキストに書き換え（渡し）たい。
      
      label.text = "\(todos[indexPath.row])"
      //ラベルテキストをテキストフィールドに変換したい。 場合によっては　textField.text = "\(todos[indexPath.row])" と書いたが動作せず。
       textField.text = label.text
       
       */
       
 
      
    }
  }
  
  
  @IBAction func Icon(_ sender: Any) {
    let sourceType:UIImagePickerController.SourceType =
      UIImagePickerController.SourceType.photoLibrary
    
    // インスタンスの作成
    let iconPicker = UIImagePickerController()
    iconPicker.sourceType = sourceType
    iconPicker.delegate = self
    iconPicker.allowsEditing = true
    
    /// loveeさんから加筆もしくは修正してもらった文 frontImagePicker = frontPicker を　switch文のcaseに使っている
    iconImagePicker = iconPicker
    
    
    
    self.present(iconPicker, animated: true, completion: nil)
    
    
  }
  
  
  
  
  
  
    
  
  @IBAction func addIcon(_ sender: Any) {
    //初期位置を調整
    iconImageView.center = CGPoint(x: view.center.x, y: view.center.y + 100)
    //ユーザーの操作を有効にする
    iconImageView.isUserInteractionEnabled = true
    //タッチしたものがアイコンかどうかを判別する用のタグ
    iconImageView.tag = 1
    //ビューに追加
    view.addSubview(iconImageView)
    
    
  }
  
  // タッチした位置で最初に見つかったところにあるビューを取得してしまおうという
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // 最初にタッチした指のみ取得
    if let touch = touches.first {
      // タッチしたビューをviewプロパティで取得する
      if let touchedView = touch.view {
        // tagでアイコンかそうでないかを判断する
        if touchedView.tag == 1 {
          // タッチした場所とタッチしたビューの中心座標がどうずれているか？
          gapX = touch.location(in: view).x - touchedView.center.x
          gapY = touch.location(in: view).y - touchedView.center.y
          // 例えば、タッチしたビューの中心のxが50、タッチした場所のxが60→中心から10ずれ
          // この場合、指を100に持って行ったらビューの中心は90にしたい
          // ビューの中心90 = 持って行った場所100 - ずれ10
          touchedView.center = CGPoint(x: touch.location(in: view).x - gapX, y: touch.location(in: view).y - gapY)
        }
      }
    }
    //キーボードの機能////
    ///キーボード以外をタップするとキーボードが解除される/////////
    //self.view.endEditing(true)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    // touchesBeganと同じ処理だが、gapXとgapYはタッチ中で同じものを使い続ける
    // 最初にタッチした指のみ取得
    if let touch = touches.first {
      // タッチしたビューをviewプロパティで取得する
      if let touchedView = touch.view {
        // tagでアイコンかそうでないかを判断する
        if touchedView.tag == 1 {
          // gapX,gapYの取得は行わない
          touchedView.center = CGPoint(x: touch.location(in: view).x - gapX, y: touch.location(in: view).y - gapY)
        }
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // gapXとgapYの初期化
    gapX = 0.0
    gapY = 0.0
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    // touchesEndedと同じ処理
    self.touchesEnded(touches, with: event)
  }
  
  
  
  
  
  
  
   //ムービーをフォトライブラリから選ぶ
  @IBAction func selectImage(_ sender: Any) {
    movieImagePicker.sourceType = .photoLibrary
    movieImagePicker.delegate = self
    movieImagePicker.mediaTypes = ["public.movie"]
    //画像だけ
    //imagePickerController.mediaTypes = ["public.image"]
    present(movieImagePicker, animated: true, completion: nil)
  }
  
   
   
   
   
  
 
  // ここからボタンを押したらアルバムを表示 front
  @IBAction func front(_ sender: Any) {
    let sourceType:UIImagePickerController.SourceType =
      UIImagePickerController.SourceType.photoLibrary
    
    // インスタンスの作成
    let frontPicker = UIImagePickerController()
    frontPicker.sourceType = sourceType
    frontPicker.delegate = self
    frontPicker.allowsEditing = true
    
       /// loveeさんから加筆もしくは修正してもらった文 frontImagePicker = frontPicker を　switch文のcaseに使っている
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
    backPicker.allowsEditing = true
    
    /// loveeさんから加筆もしくは修正してもらった文 backImagePicker = backPicker を　switch文のcaseに使っている
	backImagePicker = backPicker
    
    
    self.present(backPicker, animated: true)
  }
  
  
 
  
  @IBAction func playMovie(_ sender: Any) {
  
  
  if let videoURL = videoURL{
    let moviePicker = AVPlayer(url: videoURL)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = moviePicker
    
    present(playerViewController, animated: true){
      print("動画再生")
      playerViewController.player!.play()
     }
   }
  }
  // UIImagePickerのデリゲートメソッド
  
    /// loveeさんから加筆もしくは修正してもらった文 UIImagePickerController を picker として引数に渡している。　switch で case に分岐して front と back に応じてそれぞれ表示している。
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // 画像を置き換える　1[editedImage] 2[originalImage] で表示される。　ちょー重要。
    // 1のときはインスタンスの生成に frontPicker.allowsEditing = true を書き込む
    // 2のときは frontPicker.allowsEditing = true を消す
	switch picker {
	case frontImagePicker:
		frontImageView.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
    print("frontImageView")
    
	case backImagePicker:
		backImageView.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
    print("backImageView")
		
  case movieImagePicker:
    videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
    print(videoURL!)
    movieView.image = previewImageFromVideo(videoURL!)!
    print("movieView")
    
  case iconImagePicker:
    iconImageView.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
    print("iconImageView")
    
  default:
		break
	}
      // 前の画面に戻る
    /// loveeさんから加筆もしくは修正してもらった文 引数pickerで前の画面に戻る。
      picker.dismiss(animated: true, completion: nil)
    
  }
  
  
  //動画関連
  func previewImageFromVideo(_ url:URL) -> UIImage? {
    
    print("動画からサムネイルを生成する")
    let asset = AVAsset(url:url)
    let imageGenerator = AVAssetImageGenerator(asset:asset)
    imageGenerator.appliesPreferredTrackTransform = true
    var time = asset.duration
    time.value = min(time.value,2)
    do {
      let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      return UIImage(cgImage: imageRef)
    } catch {
      return nil
    }
  }

  
  
  
  
  
  
  
  
  
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
