# BookSearchApp-RxSwift

<img src="https://raw.githubusercontent.com/daisuke-t-jp/BookSearchApp-RxSwift/master/demo.gif" width="200px">

## 概要
RxSwift を使った、本を検索するサンプルアプリです。  
本の情報は [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/index.html) から取得しています。

以下のライブラリを利用しています。

- RxSwift
- RxCocoa
- Moya
- Nuke
- SwiftLint
- R.swift


## セットアップ方法
CocoaPods でライブラリを管理しているので、 `pod` コマンドでライブラリをインストールします。

```
% pod install
```

`Sample.xcworkspace` が生成されるので、それを開き、ビルドします。
