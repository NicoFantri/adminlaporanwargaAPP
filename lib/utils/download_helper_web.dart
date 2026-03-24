import 'dart:html' as html;

Future<void> downloadFile(List<int> bytes, String fileName) async {
  // Convert bytes to a blob
  final blob = html.Blob([bytes]);
  // Create an object URL for the blob
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // Create a hidden anchor element
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..style.display = 'none';
    
  // Add to the DOM, click it, and remove it
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  
  // Cleanup the object URL
  html.Url.revokeObjectUrl(url);
}
