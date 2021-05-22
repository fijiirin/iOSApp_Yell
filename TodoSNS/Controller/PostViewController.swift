//
//  PostViewController.swift
//  TodoSNS
//
//  Created by 藤井凜 on 2021/01/05.
//

import UIKit
import Firebase
import FirebaseFirestore

class PostViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  let db = Firestore.firestore() //決まった宣言なので変数化
  var userName = String() //保存した値を入れる変数
  var userIdString = String() //作成した自分のIDを代入する用の変数
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textView.backgroundColor = .white
    textView.layer.borderWidth = 2.0
    textView.layer.borderColor = UIColor.black.cgColor
    textView.layer.cornerRadius = 4.0
    
    if UserDefaults.standard.object(forKey: "userName") != nil {
      userName = UserDefaults.standard.object(forKey: "userName") as! String
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if UserDefaults.standard.object(forKey: "documentID") != nil { //nilでなければ
      userIdString = UserDefaults.standard.object(forKey: "documentID") as! String //自身のIDを代入
    } else {
      userIdString = db.collection("Rooms").document().path //pathをidとして代入
      print(userIdString) //idStringにはRooms/lijf734g8f3gのような投稿者の
      userIdString = String(userIdString.dropFirst(6)) //pathのRooms/までを削除
      UserDefaults.standard.set(userIdString, forKey: "documentID") //アプリ内に保存
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    textView.resignFirstResponder()
  }
  
  
  @IBAction func createRoom(_ sender: Any) {
    
    if textView.text?.isEmpty == true { //空での送信を許可しない
      return
    }
    //Rooms内の作成されたidString(自身のid)に送信する
    db.collection("Rooms").document(/*userIdString*/).setData(
      ["roomName":textView.text as Any, "userName":userName as Any, "postDate":Date().timeIntervalSince1970, "like":0, "likeFlagDic":[userIdString:false]]
    )
   
    textView.text = ""
    navigationController?.popViewController(animated: true)
    print("目標を作成しました！")
  }
  
  
  
  @IBAction func back(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
  
  
}

