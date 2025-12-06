module Program

open System
open System.IO
open System.Collections.Generic

type CalcOperator =
    | Add
    | Multiply

type Calculations =
    { numbers: Int64 list
      operator: CalcOperator }

let calcValue calcs = 
    let initial = 
        match calcs.operator with 
            | Add -> 0L
            | Multiply -> 1L
    (initial, calcs.numbers) ||> List.fold(fun accum x -> 
        match calcs.operator with 
            | Add -> accum + x
            | Multiply -> accum * x
        )

let printCalc calcs =
    calcs.numbers |> List.iter(fun x -> printf "%d " x)
    printfn "with operator %s" (calcs.operator.ToString())
    printfn "total value = %d" (calcValue calcs)

let convertInput (fileLines: seq<string>) : seq<Calculations> =
    fileLines
    |> Seq.map (fun x -> x.Split(' ', StringSplitOptions.RemoveEmptyEntries ||| StringSplitOptions.TrimEntries))
    |> Seq.collect Seq.indexed
    |> Seq.groupBy fst
    |> Seq.map (snd >> Seq.map snd)
    |> Seq.map (fun x ->
        (([], None), x) ||> Seq.fold(fun (accum: Int64 list * CalcOperator option) (z: string) -> 
            match Int32.TryParse z with
                | true, parsedInt -> (accum |> fst) @ [parsedInt], accum |> snd
                | _ -> 
                match z with
                    | "*" -> accum |> fst, Some Multiply
                    | "+" -> accum |> fst, Some Add
                    | _ -> failwith "Invalid operator"
    ))
    |> Seq.map(fun x -> {
        numbers = x |> fst;
        operator = x |> snd |> Option.get
    })


// this is awful, not functional at all
// but my brain isn't working well enough to work it out
let convertInputPart2 (fileLines: seq<string>) : seq<Calculations> = 
    // iterate through list of strings one char at a time 
    let lineLength = fileLines |> Seq.item 0 |> String.length
    let mutable currentNumbers = []
    let mutable currentOperator = None
    let mutable calcs = []
    for i in 0..lineLength - 1 do
        let mutable number: char list = []
        for line in fileLines do
            match line.[i] with 
                | '*' -> currentOperator <- Some Multiply
                | '+' -> currentOperator <- Some Add
                | ' ' -> ()
                | a -> number <- number @ [a]
        if number |> List.isEmpty then
            let newCalc = {
                numbers = currentNumbers;
                operator = currentOperator |> Option.get
            }
            calcs <- calcs @ [newCalc]
            currentNumbers <- []
            currentOperator <- None
        else
            let newNumber = number |> List.map Char.ToString |> String.concat "" |> Int64.Parse
            currentNumbers <- currentNumbers @ [newNumber]
    let newCalc = {
        numbers = currentNumbers;
        operator = currentOperator |> Option.get
    }
    calcs @ [newCalc]


[<EntryPoint>]
let main args =
    if args.Length > 1 && args[1] = "2" then 
        let inputText = File.ReadLines args[0]
        let calculations = convertInputPart2 inputText 
        // calculations |> Seq.iter printCalc
        let value = calculations |> Seq.map calcValue |> Seq.fold(fun x y -> x + y) 0L
        printfn "Total value is %d" value
    elif args.Length > 0 then
        let inputText = File.ReadLines args[0]
        let calculations = convertInput inputText 
        // calculations |> Seq.iter printCalc
        let value = calculations |> Seq.map calcValue |> Seq.fold(fun x y -> x + y) 0L
        printfn "Total value is %d" value
    else
        printfn "Need to pass through the input file"

    0
