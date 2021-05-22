//
//  CustomViewController.swift
//  TodoSNS
//
//  Created by 藤井凜 on 2021/01/18.
//

import UIKit
import Firebase
import FirebaseAuth
import EMAlertController

class CustomViewController: UIViewController {
  
  
  
  @IBOutlet weak var textField: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textField.backgroundColor = .white
    textField.layer.borderWidth = 2.0
    textField.layer.borderColor = UIColor.black.cgColor
    textField.layer.cornerRadius = 2.0
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  
  //名前変更保存
  @IBAction func nameCustomDone(_ sender: Any) {
    if textField.text != "" {
      UserDefaults.standard.set(self.textField.text, forKey: "userName") //テキストの文字列として更新
      textField.resignFirstResponder()
      //アラートを表示
      let alert = EMAlertController(icon: UIImage(named: ""), title: "名前更新完了！", message: "あなたの名前を更新しました！")
      let doneAction = EMAlertAction(title: "OK", style: .normal)
      alert.addAction(doneAction)
      present(alert, animated: true, completion: nil)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    textField.resignFirstResponder()
  }
  
  
  //ログアウト //後で消すかも
  @IBAction func logout(_ sender: Any) {
    let firebaseAuth = Auth.auth()
    
    do {
      try firebaseAuth.signOut()
      UserDefaults.standard.removeObject(forKey: "userName") //保存した値を削除
      UserDefaults.standard.removeObject(forKey: "documentID")
    } catch let error as NSError {
      print("エラー",error)
    }
    let loginVC = storyboard?.instantiateViewController(identifier: "loginVC") as! LoginViewController
    self.navigationController?.pushViewController(loginVC, animated: true) //ログイン画面まで画面遷移
  }
  
  
}
