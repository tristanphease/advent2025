# shouldn't really be creating functions for everything
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

# x ← [
#   1_0_1_0_1_0
#   0_1_1_1_1_1
#   1_1_0_1_0_1
#   1_1_0_1_0_1
# ]

x ← [
  [0 0 1 1 0 1 1 1 1 0]
  [1 1 1 0 1 0 1 0 1 1]
  [1 1 1 1 1 0 1 0 1 1]
  [1 0 1 1 1 1 0 0 1 0]
  [1 1 0 1 1 1 1 0 1 1]
  [0 1 1 1 1 1 1 1 0 1]
  [0 1 0 1 0 1 0 1 1 1]
  [1 0 1 1 1 0 1 1 1 1]
  [0 1 1 1 1 1 1 1 1 0]
  [1 0 1 0 1 1 1 0 1 0]
]

# y ← PadArray x
# z ← GetThreeByThreeSum y
# w ← GetLessThanFive z

# v ← ⊸(LF TS PA) x
# v
a ← ⍢(≡SB ×⊸⊸(LF TS PA)|>0 GA) x
/+♭SB a x
