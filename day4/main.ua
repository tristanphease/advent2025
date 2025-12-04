# Reads the file in, converts to a 2d array where @ = 1, . = 0
x ← ⌝↘ (¯1)_(¯1) ⌝↘ 1_1 ≡±⦷"@" ≡°□ ⊜□ ⊸≠"\n" &fras "input.txt"

PadArray ← ⌝↘ (¯1)_(¯1) ⌝↘ 1_1

# gets array sum of the 3x3 surrounding (including itself)
y ← ≡⧈/+3⧈/+3 PadArray x

# get values which are 1 and the sum is less than 5 (need to include itself)
z ← ≡<5 y

/+/×⊟(♭x)(♭z)
