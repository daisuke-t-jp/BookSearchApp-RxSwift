//
//  MainViewController.swift
//  Sample
//
//  Created by Daisuke TONOSAKI on 2022/09/01.
//

import UIKit
import SafariServices

import RxSwift
import RxCocoa
import Moya

// この View で使用する ViewModel
class BookViewModel {
    let booksRelay = BehaviorRelay<[BookModel]>(value: [])
    
    func updateBooks(array: [BookModel]) {
        booksRelay.accept(array)
    }
}


class MainViewController: UIViewController {
    // MARK: - Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property
    private let disposeBag: DisposeBag = DisposeBag()
    private var provider: MoyaProvider<iTuneSearchAPI>!
    private let viewModel: BookViewModel = BookViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        provider = MoyaProvider<iTuneSearchAPI>()
        
        // ネットワークログを見たい時はこっち
//        let plugin: PluginType = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
//        provider = MoyaProvider<iTuneSearchAPI>(plugins: [plugin])
        
        tableViewSetup()
        searchBarSetup()
    }
    
    // TableView のセットアップ
    func tableViewSetup() {
        tableView.keyboardDismissMode = .onDrag
        
        // セルの登録をする
        tableView.register(UINib(resource: R.nib.bookTableViewCell),
                           forCellReuseIdentifier: R.reuseIdentifier.bookTableViewCellIdentifier.identifier)
        tableView.rowHeight = BookTableViewCell.height
        
        
        // ViewModel を bind する
        viewModel.booksRelay
            .bind(to: tableView.rx.items(cellIdentifier: R.reuseIdentifier.bookTableViewCellIdentifier.identifier,
                                         cellType: BookTableViewCell.self)) { row, element, cell in
                // セルを設定する
                cell.configure(item: element)
            }.disposed(by: disposeBag)
        
        
        // セルを選択した時の動作
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                
                guard let ebook: BookModel = self?.viewModel.booksRelay.value[indexPath.row],
                      let url: URL = ebook.trackViewUrl else {
                    return
                }
                let safariViewController = SFSafariViewController(url: url)
                self?.present(safariViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    // SearchBar のセットアップ
    func searchBarSetup() {
        searchBar.placeholder = "著者名で検索"
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        // テキスト変更の Observable
        let observableChange = rx
            .methodInvoked(#selector(UISearchBarDelegate.searchBar(_:shouldChangeTextIn:replacementText:))) // 入力時の UISearchBarDelegate のメソッドをフック
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)    // 0.3 秒で入力確定とみなす
            .flatMap { [weak self] _ in
                Observable.just(self?.searchBar.text ?? "")
            }
        
        
        // クリアボタンの Observable
        let observableClear = searchBar.rx.text.orEmpty.asObservable()
        
        
        // Observable をマージ
        let observable = Observable.merge(observableChange, observableClear)
            .skip(1)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged() // 変化がある場合のみ、ストリームを流す
        
        
        // 購読して入力テキストを得る
        observable.subscribe(onNext: { [weak self] text in
            if text.count == 0 {
                // 検索テキストがない場合は、リストを空にする
                self?.viewModel.updateBooks(array: [])
            } else {
                // API リクエスト
                self?.provider.request(.searchBook(name: text)) { result in
                    switch result {
                    case let .success(moyaResponse):
                        if let bookResponse: BookResponseModel = try? JSONDecoder().decode(BookResponseModel.self, from: moyaResponse.data) {
                            // ViewModel を更新する
                            self?.viewModel.updateBooks(array: bookResponse.results)
                        }
                    default: break
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}
