import std/os
import std/strformat

proc tocImpl(token:string) =
  # tocを取得
  let tocPath = "/usr/local/bin/gh-md-toc"
  if not fileExists(tocPath):
    let commands = @[
      &"wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc -O {tocPath}",
      &"chmod +x {tocPath}",
    ]

    for command in commands:
      discard execShellCmd(command)

  # マークダウン一覧を取得
  # README.mdと、documents以下
  let dirs = @["./", "documents"]
  var documents:seq[string]

  for dir in dirs:
    for f in walkDirRec(dir, {pcFile}):
      if f[^3..^1] == ".md":
        let filePath = getCurrentDir() / f
        documents.add(filePath)

  for path in documents:
    let command = &"GH_TOC_TOKEN={token} gh-md-toc --insert --no-backup {path}"
    discard execShellCmd(command)


when isMainModule:
  import cligen
  dispatch(tocImpl)
