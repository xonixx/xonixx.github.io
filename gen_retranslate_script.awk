BEGIN {
  MD = ARGV[1]
#  print MD
  Text = ""
  PartNo = 0
  PerPart = 4000
  TempFolder = "temp"
  RetranslateScript = TempFolder "/retranslate.sh"
  Retranslated = TempFolder "/" MD
  system("[ ! -d " TempFolder " ] && mkdir " TempFolder)
  print "#!/bin/sh\nrm " Retranslated > RetranslateScript
}

/```/ {
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
function createPartIfNeeded(   part,part1,part2) {
  if (length(Text) > PerPart){
    printf "%s", Text > (part = TempFolder "/" MD "__part" PartNo ".md")
    print "./soft/trans -brief -i " part " -o " (part1 = part "__1.md") " en:ru" >> RetranslateScript
    print "./soft/trans -brief -i " part1" -o " (part2 = part "__2.md") " ru:en" >> RetranslateScript
    print "cat " part2 " >> " Retranslated >> RetranslateScript
    print "" >> RetranslateScript
    PartNo++
    Text = ""
  }
}