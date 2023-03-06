BEGIN {
  MD = ARGV[1]
  print MD
  Text = ""
  PartNo = 0
  PerPart = 1000
}

/```/ {
#  print "!!!"
  if (InsideCode) {
    InsideCode = 0
    addText("X")
  } else InsideCode = 1
  addText($0)
  next
}

!InsideCode {
  addText($0)
  createPartIfNeeded()
}

END {
  createPartIfNeeded()
}

function addText(s) { Text = Text "\n" s }
function createPartIfNeeded() {
  if (length(Text) > PerPart){
    printf "%s", Text > MD "__part" PartNo ".md"
    PartNo++
    Text = ""
  }
}