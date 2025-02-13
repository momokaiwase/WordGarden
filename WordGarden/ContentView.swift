//
//  ContentView.swift
//  WordGarden
//
//  Created by Momoka Iwase on 2025/02/07.
//

import SwiftUI

struct ContentView: View {
    private static let maximumGuesses = 8 //static properties available even before view loads (unlike all other vars declared when view loads) - need to refer to this as Self.maximumGuesses
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var currentWordIndex = 0 //index in wordsToGuess
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = maximumGuesses
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true
    @State private var playAgainButtonLabel = "Another Word?"
    @FocusState private var textFieldIsFocused: Bool
    
    private let wordsToGuess = ["SWIFT", "DOG", "CAT"] //All caps

    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading){
                    Text("Words Guessed : \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }
                Spacer()
                VStack(alignment: .trailing){
                    Text("Words to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                    Text("Words in Game: \(wordsToGuess.count)")
                }
               
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(minHeight: 80)
                .minimumScaleFactor(0.5)
                .padding()
            
            //TODO: Switch to wordsToGuess[currentWordIndex]
            Text(revealedWord)
                .font(.title)
            
            if playAgainHidden {
                HStack {
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5 )
                                .stroke(.gray, lineWidth: 2)
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) {
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let lastChar = guessedLetter.last else {
                                return
                            }
                            guessedLetter = String(lastChar).uppercased()
                        }
                        .focused($textFieldIsFocused)
                        .onSubmit {
                            //As long as guessedLetter is not an empty String we can continue, otherwise don't do anything
                            guard guessedLetter != "" else {
                                return
                            }
                            guessALetter()
                            updateGamePlay()
                        }
                    
                    Button("Guess a Letter:") {
                        guessALetter()
                        updateGamePlay()
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }
            } else {
                Button(playAgainButtonLabel) {
                    //If all the words have been guessed...
                    if currentWordIndex == wordToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }
                    
                    //Reset after a word was guessed or missed
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
                    lettersGuessed = ""
                    guessesRemaining = Self.maximumGuesses //because maximumGuesses is static
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
                    playAgainHidden = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }
            
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
        }
        
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            wordToGuess = wordsToGuess[currentWordIndex]
            //CREATE A STRING FROM A REPEATING VALUE
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
        }
    }
    
    func guessALetter() {
        textFieldIsFocused = false
        lettersGuessed = lettersGuessed + guessedLetter
        revealedWord = wordToGuess.map{ letter in lettersGuessed.contains(letter) ? "\(letter)" : "_"
        }.joined(separator: " ")
    }
    
    func updateGamePlay() {

        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            imageName = "flower\(guessesRemaining)"
        }
        
        //When do we play another word?
        if !revealedWord.contains("_") { //Guessed when no "_" in revealedWord
            gameStatusMessage = "You Guessed It! It Took You \(lettersGuessed.count) Guesses the Word."
            wordsGuessed += 1
            playAgainHidden = false
        } else if guessesRemaining == 0 { //Word missed
            gameStatusMessage = "So Sorry, You're All Out of Guesses"
            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false
        } else { //Keep Guessing
            //TODO: Redo this with LocalizedStringKey & Inflect
            gameStatusMessage = "You've Made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "" : "es")"
        }
        
        if currentWordIndex == wordToGuess.count { //exceeding words to guess
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\nYou've Tried All of the Words. Restart from the beginning?"
        }
        guessedLetter = ""
        
    }
}

#Preview {
    ContentView()
}
