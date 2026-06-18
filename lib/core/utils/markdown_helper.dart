class MarkdownHelper {
  static String appendCursor(String text, bool isStreaming) {
    return isStreaming ? '$text▍' : text;
  }
}
