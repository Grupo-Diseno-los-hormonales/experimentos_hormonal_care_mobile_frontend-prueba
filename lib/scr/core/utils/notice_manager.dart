class NoticeManager {
  static String? currentNotice;

  static void setNotice(String notice) {
    currentNotice = notice;
  }

  static void clearNotice() {
    currentNotice = null;
  }
}