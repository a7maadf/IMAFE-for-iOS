func showEncryption(ButtonTextVarName: String) -> String{
    do{
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+"
        let numChar = ButtonTextVarName.count
        var randomizedText = ""
        
        for _ in 0..<numChar{
            randomizedText.append(characters.randomElement()!)
            
        }
        return randomizedText
    } catch {
        print("Error")
    }
}


