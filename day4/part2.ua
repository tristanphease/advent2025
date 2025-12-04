# Reads the file in, converts to a 2d array where @ = 1, . = 0
x ← ⌝↘ (¯1)_(¯1) ⌝↘ 1_1 ≡±⦷"@" ≡°□ ⊜□ ⊸≠"\n" &fras "input.txt"

# Pad Array
PA ← ⌝↘ (¯1)_(¯1) ⌝↘ 1_1
# Gets the 3x3 Sum
TS ← ≡⧈/+3⧈/+3
# Gets values in array less than 5
LF ← ≡<5
# Does boolean subtraction
SB ← ↥0-
# Converts array to the next array (with packages removed)
ConvertArray ← SB ⊸(LF TS PA)
# Gets amount from the array
GetAmount ← /+/×⊟ ∩♭
GA        ← GetAmount ⊸(LF TS PA)

a ← ⍢(≡SB ×⊸⊸(LF TS PA)|>0 GA) x
/+♭SB a x
