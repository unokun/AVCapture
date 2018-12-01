//
//  ViewController.swift
//  AVCapture
//
//  Created by Masaaki Uno on 2018/12/01.
//  Copyright © 2018 Masaaki Uno. All rights reserved.
//
// QRコード読み取り
// https://shinjism.com/blog/2017/10/qrcode.html
// 読み取り範囲の設定
// https://qiita.com/tomosooon/items/9cb7bf161a9f76f3199b

import UIKit
import AVFoundation


class ViewController: UIViewController {

    private let session = AVCaptureSession()
    
    // 読み取り範囲（0 ~ 1.0の範囲で指定）
    let x: CGFloat = 0.1
    let y: CGFloat = 0.4
    let width: CGFloat = 0.4
    let height: CGFloat = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back)
        let devices = discoverySession.devices
        
        if let backCamera = devices.first {
            do {
                // QRコードの読み取りに背面カメラの映像を利用するための設定
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    
                    // 背面カメラの映像からQRコードを検出するための設定
                    let metadataOutput = AVCaptureMetadataOutput()
                    
                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)
                        
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        
                        // 背面カメラの映像を画面に表示するためのレイヤーを生成
                        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        previewLayer.frame = self.view.bounds
                        previewLayer.videoGravity = .resizeAspectFill
                        self.view.layer.addSublayer(previewLayer)
                        
                        // どの範囲を解析するか設定する
                        metadataOutput.rectOfInterest = CGRect(x: y, y: 1-x-width, width: height, height: width)
                        
                        // 解析範囲を表すボーダービューを作成する
                        let borderView = UIView(frame: CGRect(x: x * self.view.bounds.width, y: y * self.view.bounds.height, width: width * self.view.bounds.width, height: height * self.view.bounds.height))
                        borderView.layer.borderWidth = 2
                        borderView.layer.borderColor = UIColor.red.cgColor
                        self.view.addSubview(borderView)
                        
                        // 読み取り開始
                        self.session.startRunning()
                    }
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        // Do any additional setup after loading the view, typically from a nib.
        }
    }
}
extension ViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRコードのデータかどうかの確認
            if metadata.type != .qr { continue }
                
            // QRコードの内容が空かどうかの確認
            if metadata.stringValue == nil { continue }
                
                /*
                 このあたりで取得したQRコードを使ってゴニョゴニョする
                 読み取りの終了・再開のタイミングは用途によって制御が異なるので注意
                 以下はQRコードに紐づくWebサイトをSafariで開く例
                 */
                
            // URLかどうかの確認
            if let url = URL(string: metadata.stringValue!) {
                // 読み取り終了
                self.session.stopRunning()
                print(url);
                // QRコードに紐付いたURLをSafariで開く
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
                break
            }
        }
    }
}

