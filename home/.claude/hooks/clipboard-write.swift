import AppKit
import Foundation

let data = FileHandle.standardInput.readDataToEndOfFile()
guard let md = String(data: data, encoding: .utf8), !md.isEmpty else { exit(0) }

do {
  let attr = try NSAttributedString(
    markdown: md,
    options: .init(interpretedSyntax: .full)
  )
  let htmlData = try attr.data(
    from: NSRange(location: 0, length: attr.length),
    documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
  )
  guard let html = String(data: htmlData, encoding: .utf8) else { exit(1) }

  let pb = NSPasteboard.general
  pb.clearContents()
  pb.setString(html, forType: .html)
  pb.setString(md, forType: .string)
} catch {
  exit(2)
}
