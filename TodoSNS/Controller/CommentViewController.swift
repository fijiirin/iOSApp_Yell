//
//  CommentViewController.swift
//  TodoSNS
//
//  Created by 藤井凜 on 2021/01/07.
//

import UIKit
import Firebase
import FirebaseFirestore

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  
  @IBOutlet weak var roomNameLabel: UILabel!
  @IBOutlet weak var postDateLabel: UILabel!
  @IBOutlet weak var likeCountLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var createRoomUserName: UILabel!
  
  var roomModelDatas:[CommentModel] = []
  let db = Firestore.firestore()
  var userName = String() //保存されたユーザー名を受け取るようの変数
  var idString = String() //タップされたセルのdocIDを受け取る変数
  var roomNameString = String() //部屋の名前を受け取る変数●
  var postDateString = String() //投稿日を受け取るようの変数●
  var createRoomUserNameString = String() //部屋作成者名を受け取るようの変数●
  let screenSize = UIScreen.main.bounds.size //画面サイズを取得して変数化
  var userIdString = String() //自身のIDを受け取る用の変数
  var likeCount = Int() //いいね数を受け取るようの変数
  var likeFlag = Bool() //いいねしたかどうかを受け取るようの変数
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableView.automaticDimension
    textField.backgroundColor = .white
    textField.layer.borderWidth = 1.0
    textField.layer.borderColor = UIColor.black.cgColor
    textField.layer.cornerRadius = 4.0
    sendButton.layer.cornerRadius = 4.0
    
    if UserDefaults.standard.object(forKey: "userName") != nil { //保存されたユーザー名の取得
      userName = UserDefaults.standard.object(forKey: "userName") as! String
    }
    if UserDefaults.standard.object(forKey: "documentID") != nil { //保存されたユーザーIDを取得
      userIdString = UserDefaults.standard.object(forKey: "documentID") as! String
    }
    //受け取った投稿日時を表示
    postDateLabel.text = String("\(Date(timeIntervalSince1970: Double(postDateString)!))".dropLast(14))
    roomNameLabel.text = roomNameString //受け取った部屋名を表示
    createRoomUserName.text = createRoomUserNameString //受け取った投稿者名を表示
    likeCountLabel.text = String(likeCount) + " ガンバッ" //受け取ったいいね数を表示
    
    //キーボードを開いたり閉じた時の時の挙動の検知
    NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.isNavigationBarHidden = false
    loadData()
  }
  
  
  //ノーティフィケーションのメソッドの実行
  @objc func keyboardWillShow(_ notification:NSNotification) {
    //キーボードの高さを取得
    let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue?.height
    //textFieldと送信ボタンのy軸の位置を（画面サイズ-キーボードの高さ-自身のパーツの高さ分引いた高さにする）
    textField.frame.origin.y = screenSize.height - keyboardHeight! - textField.frame.height
    sendButton.frame.origin.y = screenSize.height - keyboardHeight! - sendButton.frame.height
  }
  @objc func keyboardWillHide(_ notification:NSNotification) {
    //高さを元の高さに戻す
    textField.frame.origin.y = screenSize.height - textField.frame.height
    sendButton.frame.origin.y = screenSize.height - sendButton.frame.height
    //durationをかける(アニメーションをかける)
    //キーボードが下がる時間を変数に代入する
    guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
    UIView.animate(withDuration: duration) {
      let transform = CGAffineTransform(translationX: 0, y: 0)
      self.view.transform = transform
    }
  }
  
  
  func loadData() {
    db.collection("Rooms").document(idString).collection("Comments").order(by: "postDate").addSnapshotListener { (snapShot, error) in
      self.roomModelDatas = [] //配列の初期化
      if error != nil {
        return
      }
      if let snapShotDoc = snapShot?.documents {
        for doc in snapShotDoc {
          let data = doc.data()
          if let userName = data["userName"] as? String, let comment = data["comment"] as? String, let postDate = data["postDate"] as? Double {
            let commentModel = CommentModel(userName: userName, comment: comment, postDate: postDate) //構造体に代入
            self.roomModelDatas.append(commentModel) //データの入った構造体を配列に代入
          }
        }
        self.roomModelDatas.reverse() //配列の中身を反転させる
        self.tableView.reloadData() //tableViewを再構築する
      }
    }
  }
  
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return roomModelDatas.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    tableView.estimatedRowHeight = 200 //セルの最低の高さ
    return UITableView.automaticDimension //セルの高さを自動調節
//    tableView.rowHeight = 200
//    return UITableView.automaticDimension
  }
 
  //セルの中身の構築
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    tableView.backgroundColor = .white //tableViewの背景色を変える
    tableView.tableFooterView = UIView() //余分なセルを表示しない
    tableView.rowHeight = 200
    let commentUserNameLabel = cell.contentView.viewWithTag(2) as! UILabel
    let commentLabel = cell.contentView.viewWithTag(3) as! UILabel
    commentLabel.numberOfLines = 0 //可変のセルになる
    commentUserNameLabel.text = "\(roomModelDatas.count - indexPath.row)・\(roomModelDatas[indexPath.row].userName)"
    commentLabel.text = "\(roomModelDatas[indexPath.row].comment)"
    
    return cell
  }
  
  
  //送信
  @IBAction func sendAction(_ sender: Any) {
    if textField.text?.isEmpty == true { //空での送信を許可しない
      return
    }
    //タップされたセルのドキュメントの中にさらにコレクションを作る
    db.collection("Rooms").document(idString).collection("Comments").document().setData(
      ["userName":userName as Any, "comment":textField.text! as Any, "postDate":Date().timeIntervalSince1970])
    textField.text = ""
    textField.resignFirstResponder()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    textField.resignFirstResponder()
  }
  

  
  
  
  
}
