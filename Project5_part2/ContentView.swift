//
//  ContentView.swift
//  Project5_part2
//
//  Created by K.Takahama on R 4/11/24.
//

import SwiftUI

struct ContentView: View {
    //text.fileを読み込みます
    //３つの文字列のプロパティを追加します
    @State private var useWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    //アラートを制御するためのプロパティ
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        //表示させていきます
        NavigationView {
            List {
                Section{
                    TextField("Enter your word", text: $newWord)
                    //大文字の入力を無効化
                        .autocapitalization(.none)
                }
                Section {
                    ForEach(useWords, id: \.self) { word in
                        //Imageを追加
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            //Reternキーでメソッドを追加
            .onSubmit(addNewWord)
            //loadしビューが表示さえたときに呼び出します
            .onAppear(perform: startGame)
            //アラート表示
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    //修正するメソッドを作成します
    func addNewWord() {
        // 単語を小文字にしてトリミングし、大文字と小文字の違いで重複する単語を追加しないようにします
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // 残りの文字列が空の場合は終了します
        guard answer .count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "word used already", message: "Be more original!")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "you can't spell that word from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        // 追加の検証が行われます 入力時のアニメーションを追加
        withAnimation{
            useWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    //取り込んだファイルを使えるメソッド
    func startGame() {
        // 1. アプリ バンドルで start.txt の URL を見つけます
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. start.txt を文字列にロードします
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. 文字列を文字列の配列に分割し、改行で分割します
                let allWords = startWords.components(separatedBy: "\n")
                // 4. ランダムな単語を 1 つ選択するか、適切なデフォルトとして「silkWorm」を使用します
                rootWord = allWords.randomElement() ?? "silkworm"
                // ここまで来ればすべてがうまくいっているので、終了できます
                return
            }
        }
        // *ここに* ある場合「txtが読み込まれなかった・、ファイルがない場合など」、問題が発生しました – クラッシュをトリガーし、エラーを報告します
        fatalError("Could not load start.txt from bundle.")
    }
    //前回からの続き：単語が以前に使用されたかどうかに応じてtrueまたはfalseを返すメソッド
    func isOriginal(word: String) -> Bool {
        !useWords.contains(word)
    }
    //文字が存在する場合はコピーから削除して続行。単語の最後に到達した場合はTrueそれいがいはfalse
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    //UITextChecker: スペルミスのある単語の文字列をスキャン
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
