
BEGIN {
  MD = ARGV[1]
  print MD
  Text = ""
  PartNo = 0
  PerPart = 1000
}

{
  Text = Text "\n" $0
  createPartIfNeeded()
}

END {
  createPartIfNeeded()
}

function createPartIfNeeded() {
  if (length(Text) > PerPart){
    printf "%s", Text > MD "__part" PartNo ".md"
    PartNo++
    Text = ""
  }
}