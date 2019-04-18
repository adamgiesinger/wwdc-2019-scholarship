public enum MathOperator: String, CaseIterable {
    case plus = "+"
    case minus = "-"
    case slash = "÷"
    case times = "×"
    case equals = "="
    case clear = "Clear"
    
    public static func isOperator(c: Character) ->  Bool {
        return MathOperator(rawValue: String(c)) != nil
    }
}
