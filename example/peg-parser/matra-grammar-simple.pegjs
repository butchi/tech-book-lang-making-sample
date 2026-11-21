// Matra Grammar
// ==========================
//
// Accepts expressions like `g[x="100" y="200"] {
//   circle[cx="300" cy="400" r="100"]
//   circle[cx="500" cy="600" r="100"]
// }` and computes their value.

{{
  function toMatrast (tag, props, body) {
    return [tag, props, body].filter(part => part != null)
  }
}}

Matra "matra"
  = tag:Tag _ props:Props? _ body:Body? _ {
    return toMatrast(tag, props, body)
  }
  / Value

Tag "tag"
  = Identifier

Props "props"
  = "[" _ propArr:(@PropKeyVal _)+ _ "]" {
    return Object.fromEntries(propArr)
  }

PropKeyVal "propKeyVal"
  = @Identifier _ "=" _ '"' @JsonValue '"'

Body "body"
  = "{" _ @Matra* _ "}"

Matrast "matrast"
  = "[" _ tag:String _ "," _ props:Object _ "," _ body:JsonValue _ "]" {
    return [tag, props, body]
  }

JsonValue "jsonValue"
  = Object
  / Array
  / String
  / Boolean
  / Number

Object "object"
  = "{" _ head:RuleKeyVal "}" {
    return Object.fromEntries([head, ...tail])
  }

RuleKeyVal "ruleKeyVal"
  = _ key:Identifier _ ":" _ val:Identifier _ {
    return [key, val]
  }

Value "value"
  = JsonValue


Array "array"
  = "[" _ head:(Value "," _)* tail:Value _ "]" {
    return [...head.map(item => item[0]), tail]
  }

String "string"
  = '"' @$([^\"]*)  '"'

Number "number"
  = num:$([1-9][0-9]*) {
    return Number(num)
  }
  / "0" { return 0 }

Boolean "boolean"
  = "true"
  / "false"

Identifier "identifier"
  = $([a-zA-Z_][a-zA-Z0-9_]*)

TextLine
  = $([^#$`@][^\n]*)

Empty "empty"
  = "" { return toMatrast() }

_ "whitespace"
  = [ \t\n\r]*
