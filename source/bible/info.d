/+
// see base.d
module bible.info;

struct Info {
    string _bookName;
    int _numOfChapters;
    int _numOfVerses;

    auto toString() {
        import std.conv: text;

        return text("Book name: ", _bookName, "\n",
            "Number of chapters: ", _numOfChapters, "\n",
            "Number of verses: ", _numOfVerses);
    }
}
+/