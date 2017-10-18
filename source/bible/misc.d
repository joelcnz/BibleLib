module bible.misc;
//#here
/+
 + Questions to ask at http://forum.gtkd.org/groups/GtkD/
 + 
 + How to use timer, what about the main loop?
 + Special thanks to Adam Ruppe 20 Oct 2011 d.learn and his xml module arsd.dom
 +
 +/
//#current stuff
//#stuff at the start (in the terminal when the the program is run)
//#do info
//#crash site!
//#write
//#added a new line
//#overrides
//#a hack
//#crashes some times, must try another way
//#here
//#is this even seen
//#More key pressing stuff
//#Coal face here
//#need work
//#What a donkey!
//#timer
//#hmm, maybe use another way (GtkD way)
//#need to deal with ext
//#this function is overloaded
//#cursor selection
//#cursor selection 2
//#fail and dumbish
//#ScrollWindow
//#resizing textView and adding scroll bars
//#Gui
//#new line <
//#maybe disabled
//#note the '+ 1', because it is what the user put
//#untested
//#why m_verses.length + 1
//#only handles a range of verses

// Added Ctrl+S/R/D (save changes/set focus to reference/set focus to notes)

//version = doDebug; //#write
version = BooksTemp;

//version = CodeBlock;
//version = BrickVerses;
//version = Gui; // GtkD
//version = ESV; // ESV enabled

version = backUp;

/+
//#current stuff
extern(C) char* readline(const(char)* prompt);
extern(C) void add_history(const(char)* prompt);

pragma(lib, "readline");
pragma(lib, "curses");
//#current stuff end
+/
immutable moreImports = "import std.algorithm, std.string, std.range, std.ascii;";

version(CodeBlock)
	mixin(moreImports);

version(BrickVerses)
	mixin(moreImports);

import std.stdio;
import std.string;
import std.array: split, replace;
import std.file;
import std.conv;
import std.process;
import std.range;
import std.datetime;

version(Gui) {
import gtk.Main;
import gtk.MainWindow;
import gtk.Grid;
import gtk.ComboBoxText;
import gtk.Entry;
import gtk.Label;
import gtk.Button;
import gtk.TextTagTable;
import gtk.TextBuffer;
import gtk.TextView;
import gtk.Clipboard;
import gdk.Atoms;
import gtk.Adjustment;
import gtk.ScrolledWindow;
import gtk.ViewPort;
import gtk.TextIter; // probably idle
import gtk.TextMark; // idle
import gtk.AccelGroup;
import gtk.MenuItem;
import gtk.Window;
import gtk.Widget;

import gdk.Event;
import gdk.Keysyms;
} // version

//import dunit;
import arsd.dom: Document, Element;

//import jeca.misc; // but maybe not for coping and pasting Windows only stuff

//import ini.all;

//import kjv;
import bible.base;

version(Gui)
	pragma(lib, "GtkD");

//import jeca.all;
//mixin(Jeca.pragmalibs);
	
string BibleVersion;

//alias jEvent = gdk.Event;

version(Gui) {
class Gui : MainWindow {
private:
	Grid _grid;
	Label _refLabel, _statusLabel, _notesLabel;
	ComboBoxText _books, _chapters, _verses;
	Entry _refEntry, _saveAsNotesEntry;
	Button _convertRef, _convertBatch, _saveNotesCurrent, _readingCurrent, _saveAsNotesCurrent;

	GtkClipboard* _gtkClipboard;
	Clipboard _clipboard;

	TextTagTable _textTagTable, _textRefsTagTable, _notesTagTable, _readingTagTable;
	TextBuffer _textBuffer, _textRefsBuffer, _notesBuffer, _readingBuffer;
	TextView _textView, _textRefs, _notesView, _readingView;

	ScrolledWindow _readingScrollWinNotes,
			_scWinRefs,
			_scWinNotes,
			_quickVerseScrollWinNotes;

	TextIter _notesTextIter;
	
	int _currentBookNum, //#not yet
		_currentNumOfChaps,
		_currentNumOfVerses;
	
	StopWatch _saveTicker; //#hmm, maybe use another way (GtkD way)

	AccelGroup _accelGroup;
	//MenuItem _menuItemCtrlS, _menuItemCtrlV;

	int _notesViewPos;

	StopWatch _timer;
	
	Info _info;
public:
	this() {
		super("Jyble ("~BibleVersion~") - Brought to you by, Joel Ezra Christensen :-)");

		_accelGroup = new AccelGroup();
		addAccelGroup(_accelGroup);

		//new MenuItem(&onSave, "_Save", "file.save", true, acelGroup, 's');

		_saveTicker.start;

		_clipboard = Clipboard.get(atomIntern("CLIPBOARD", false));
		
		move(0,0);
		setResizable(true); // has been false, for some time
		_grid = new Grid();
		add(_grid);

			//doComboBoxTextBooks(_books = new ComboBoxText());
		version(BooksTemp) {
		_books = new ComboBoxText();
		_books.setWrapWidth(3);
		foreach(i; iota(22)) {
			_books.appendText(g_bible.m_books[i].m_bookTitle);
			_books.appendText(g_bible.m_books[i+22].m_bookTitle);
			_books.appendText(g_bible.m_books[i+44].m_bookTitle);
		}
		_grid.attach(_books,0,0,1,1);
		}

		version(ChapterSelect) {
		_chapters = new ComboBoxText;
		_chapters.setWrapWidth(5);
		_grid.attach(_chapters,0,1,1,1);
		_chapters.addOnChanged((chapter) {
			if (chapter.getActiveText.length) {
				_refEntry.setText = _refEntry.getText ~ chapter.getActiveText;

				_currentNumOfVerses = g_bible.getBook(g_bible.bookNumberFromTitle(_books.getActiveText)).m_chapters[_currentNumOfChaps - 1].m_verses.length;
				int fith = _currentNumOfVerses / 5;
				_verses.removeAll();
				foreach(c; iota(fith+5)) {
					if (c < _currentNumOfVerses) {

						void addNum(int colum, int n) {
							if (n < _currentNumOfVerses)
								_verses.appendText((n+1).to!string);
							else
								_verses.appendText("");
						}

						int col;

						addNum(  col, c+fith*0);
						addNum(++col, c+fith*1);
						addNum(++col, c+fith*2);
						addNum(++col, c+fith*3);
						addNum(++col, c+fith*4);
					}
				}
			}
		} );
		} // chapter select

		version(VerseSelect) {
		_verses = new ComboBoxText;
		_verses.setWrapWidth(5);
		_grid.attach(_verses,0,2,1,1);
		_verses.addOnChanged((verse) {
			_refEntry.setText = _refEntry.getText ~ " " ~ verse.getActiveText;
		} );
		} // verse select

		_books.addOnChanged( (books) {
			if  (books.getActiveText != null) {
				_refEntry.setText = books.getActiveText ~ " ";

        		version(ChaptersVerses) {
				_currentNumOfChaps = g_bible.getBook(g_bible.bookNumberFromTitle(_books.getActiveText)).m_chapters.length;
				int fith = _currentNumOfChaps / 5;
				_chapters.removeAll();
				foreach(c; iota(fith+5)) {
					if (c < _currentNumOfChaps) {

						void addNum(int colum, int n) {
							if (n < _currentNumOfChaps)
								_chapters.appendText((n+1).to!string);
							else
								_chapters.appendText("");
						}

						foreach(col; 5.iota) {
							int n = c+fith*col;
							
							if (n < _currentNumOfChaps)
								_chapters.appendText((n+1).to!string);
							else
								_chapters.appendText("");
						}
						
//							addNum(col, c+fith*col);
						/+
						int col;

						addNum(  col, c+fith*0);
						addNum(++col, c+fith*1);
						addNum(++col, c+fith*2);
						addNum(++col, c+fith*3);
						addNum(++col, c+fith*4);
						+/
					}
				}
				
				debug writeln(_currentNumOfChaps); //#write
        		} // version ChaptersVerses
			} else {
				_refEntry.setText = "";
				//writeln("Book textbox is empty."); //#write
			}
			setFocus(_refEntry);
			int len = _refEntry.getText.length;
			//#cursor selection
			_refEntry.selectRegion(len,len);
		} );

		_refLabel = new Label("Full Reference:");
		_refLabel.setAlignment(0.5f,1f);
		_grid.attach(_refLabel, 0,3,1,1);

		_refEntry = new Entry();
		_refEntry.setPlaceholderText("(reference here)");
		_grid.attach(_refEntry, 0,4,1,1);
		_refEntry.addOnActivate( (a) {
			convertRef();
		} );

		_convertRef = new Button("Look Up Reference", &convertRef);
		_grid.attach(_convertRef, 0,5,1,1);

		_statusLabel = new Label("Program running");
		_grid.attach(_statusLabel, 0,6,1,1);

		version(none) {
			//char[200] doWidth;
			//doWidth[] = '-';
			_grid.attach(new Label('-'.repeat.take(200).to!string), 1,0,1,1);
		}

		_textTagTable = new TextTagTable();
		_textBuffer = new TextBuffer(_textTagTable);
		_textView = new TextView(_textBuffer);
		_textView.setLeftMargin(5);
		_textView.setRightMargin(5);
		_textView.setWrapMode(GtkWrapMode.WORD); // CHAR // WORD_CHAR
		//_textView.setJustification(Justification.JUSTIFY_FILL); //#this works

//#Coal face here
		addOnKeyPress(&ctrlSCallback);
		addOnKeyPress(&ctrlRCallback);
		addOnKeyPress(&ctrlDCallback);

		//#ScrollWindow
		_readingScrollWinNotes = new ScrolledWindow;
		_readingScrollWinNotes.add(_textView);
		_readingScrollWinNotes.setMinContentWidth(300);
		_readingScrollWinNotes.setMinContentHeight(700);

		_grid.attach(_readingScrollWinNotes, 2,0,1,200);
		//writeln(_textView.getInputPurpose()); //#write

		_textRefsTagTable = new TextTagTable();
		_textRefsBuffer = new TextBuffer(_textRefsTagTable);
		_textRefs = new TextView(_textRefsBuffer);
		_textRefs.setWrapMode(GtkWrapMode.WORD_CHAR);
		_textRefsBuffer.setText = loadTextFile("refscurrent");

		_scWinRefs = new ScrolledWindow;
		_scWinRefs.add(_textRefs);
		_grid.attach(_scWinRefs, 0,7,1,1);
		_scWinRefs.setMinContentHeight(150);

		_convertBatch = new Button("Convert Batch", &convertBatchRefs);
		_grid.attach(_convertBatch, 0,8,1,1);

		//_notesLabel = new Label("Notes:");
		//_grid.attach(_notesLabel, 0,9,1,1);

		_notesTagTable = new TextTagTable();
		_notesBuffer = new TextBuffer(_notesTagTable);
		_notesView = new TextView(_notesBuffer);
		_notesView.setWrapMode(GtkWrapMode.WORD_CHAR);
		_notesView.setLeftMargin(5);
		_notesView.setRightMargin(5);
		_notesBuffer.setText = loadTextFile("notescurrent"); //~"\n\n";
		_notesTextIter = new TextIter();
		_notesBuffer.getEndIter(_notesTextIter);
		_scWinNotes = new ScrolledWindow;
		_scWinNotes.add(_notesView);
		_scWinNotes.setMinContentWidth(300);
		_scWinNotes.setMinContentHeight(700);
		_grid.attach(_scWinNotes, 1,0,1,200);
		
		_readingTagTable = new TextTagTable();
		_readingBuffer = new TextBuffer(_readingTagTable);
		_readingView = new TextView(_readingBuffer);
		_readingView.setLeftMargin(5);
		_readingView.setRightMargin(5);
		_readingView.setWrapMode(GtkWrapMode.WORD_CHAR);
		_readingScrollWinNotes = new ScrolledWindow;
		_readingScrollWinNotes.add(_readingView);
		_readingScrollWinNotes.setMinContentWidth(300);
		_readingScrollWinNotes.setMinContentHeight(700);
		//_grid.attach(new ScrolledWindow,3,0,1,200);
		_grid.attach(_readingScrollWinNotes,3,0,1,200);

		_saveNotesCurrent = new Button("Save Notes", &saveNotesCurrent);
		_grid.attach(_saveNotesCurrent, 0,10,1,1);
		
		Button _convertRef, _convertBatch, _saveNotesCurrent, _readingCurrent, _saveAsNotesCurrent;

		_saveAsNotesEntry = new Entry();
		_saveAsNotesEntry.setPlaceholderText("(eg 'backup')");
		_saveAsNotesEntry.setText = "backup";
		_grid.attach(_saveAsNotesEntry, 0,11,1,1);

		_saveAsNotesCurrent = new Button("Save Notes As..", &saveAs);
		_grid.attach(_saveAsNotesCurrent, 0,12,1,1);

		_readingCurrent = new Button("Full Reading", &readingExecute);
		_grid.attach(_readingCurrent, 0,13,1,1);
		
		showAll();
	}
	
	void saveAs(Button b = null) {
		saveNotesCurrent(_saveAsNotesEntry.getText);
	}
	
	void readingExecute(Button b = null) {
		with(g_bible) {
			string text = argReference(argReferenceToArgs(_refEntry.getText) );
			
			//#do info
			if (text.length) {
				_readingBuffer.setText(g_info.toString ~ text);
				//_readingView.scrollToMark(new TextMark("reading", 0), 0.0, 0, 0,0); //#fail and dumbish
				_statusLabel.setText = "Full Reading";
			} else {
				_statusLabel.setText = "No Reading to copy";
			}
		}
	}

	//#crash site!
	void convertRef(Button b = null) {
		with(g_bible) {
			string text = argReference(argReferenceToArgs(_refEntry.getText));
			//info = Info();
			if (text.length) {
				_textBuffer.setText(text);
				_clipboard.setText(text);

				//writeln('[', text, ']', " - copied to the clipboard"); //#write //#crash possiblity when not using DOS prompt
				_statusLabel.setText = "Reference copied";
				string hasText = _textRefsBuffer.getText.length ? _textRefsBuffer.getText~"\n" : ""; //#new line <
				_textRefsBuffer.setText(hasText ~ _refEntry.getText);
			} else {
				_statusLabel.setText = "No reference to copy";
			}
		}
	}

	void convertBatchRefs(Button b = null) {
		version(doDebug)
				writeln("convertBatchRefs");//#write
		string allRefs = _textRefsBuffer.getText, collection;

		foreach(line; allRefs.split("\n")) { //#new line <
			with(g_bible) {
				line = replace(line, "|_", ""); // remove extra "|_"
				
				string test = argReference(argReferenceToArgs(line));
				
				if (test.length) {
					collection ~= test ~ "\n"; //#new line <
					//version(doDebug)
					//	writeln(text ~ "\n"); //#write
				}
			}
		}
		
		if (collection.length) {
			version(doDebug)
					writeln("collection sets");
			_textBuffer.setText(collection);
			_clipboard.setText(collection);
			
			version(doDebug)
				writeln("collection sets - done");

			//writeln('[', collection, ']', " - copied to the clipboard");
			_statusLabel.setText = "Batch copied";
		} else {
			_statusLabel.setText = "No batch to copy";
		}
	}

	void saveBatchRefs(Button b = null) {
		auto file = File("refscurrent.txt", "w");
		scope(success) {
			file.close();
			_statusLabel.setText = "Refs Saved"; //#is this even seen
		}

		//string text = _textRefsBuffer.getText;
		string text;
		foreach(line; _textRefsBuffer.getText.splitLines()) {
			text ~= line ~ "\n";
		}
			/+
		if (text.length > 1 && text[$-2..$] == "\n\n") {
			text = text[0..$-2];
		}
		+/
		//writeln([text]); //#write
		
		file.write(text);
	}

	//#this function is overloaded
	void saveNotesCurrent(Button b = null) {
		//#timer
		_timer.reset;
		_timer.start;
		saveNotesCurrent("notescurrent.txt");
//#here
		saveBatchRefs();
	}
	
		/+
1. Press save
2. get the oldest file
		 +/

	void saveNotesCurrent(string fileName) {
		string backupFileName;
		
	  version(Crashes) {
		SysTime mintime = SysTime(long.max);
		foreach(i; iota(10)) {
			auto name = text("backup", (i <= 9 ? "0" : ""), i, ".txt");
			debug writeln("auto name");

			if (i == 0)
				backupFileName = name;
			//getTimes(name, dummy, test); //#What a donkey!
			
			SysTime test;
			
			if (exists(name)) {
				writeln("Enter exists");
				test = timeLastModified(name); //#crashes some times, must try another way
			} else {
				test = SysTime(long.max);
				auto f = File(name, "w");
//				f.write();
				f.close();
			}
			
			debug writeln(`name: "`, name,`" test: `, test, "\nmintime: ", mintime, "\n");

			if (test < mintime) {
				mintime = test;
				backupFileName = name;
			}
		}
	  } // version
				
		//backupFileName = "backup.txt";
		backupFileName = format("backup%02s.txt", std.random.uniform(0, 100)); //#a hack
		
		auto file = File(std.path.setExtension(fileName, "txt"), "w"); //#need to deal with ext ?
		version(backUp) auto backupFile = File(std.path.setExtension(backupFileName, "txt"), "w"); //#need to deal with ext ?
		scope(success) {
			file.close();
			version(backUp) backupFile.close();
			//_statusLabel.setText = text("Notes Saved #", uniform(0,26)); //#need work
			_statusLabel.setText = text("Notes Saved");
		}

		string text = _notesBuffer.getText;

		/+
		//#I think this is an artifact
		if (text.length > 1 && text[$-2..$] == "\n\n") {
			text = text[0..$-2];
		}
		+/

		file.write(text~"\n"); //#added a new line
		version(backUp) backupFile.write(text);
	}

	private string loadTextFile(in string fileName) {
		string text;

		foreach(line; File(fileName~".txt", "r").byLine()) {
			text ~= line~"\r\n";
		}
		
		if (! text.length)
			return "";
		
		return text[0..$-2];
	}

	bool ctrlDCallback(Event ev, Widget w)
	{
		if (ev.key.state == GdkModifierType.CONTROL_MASK &&
		    ev.key.keyval == GdkKeysyms.GDK_d) {
			
			setFocus(_notesView);
			_statusLabel.setText = text("Got Notes focus");
			
			return true;
		}
		
		return false;
	}

	bool ctrlRCallback(Event ev, Widget w)
	{
		if (ev.key.state == GdkModifierType.CONTROL_MASK &&
		    ev.key.keyval == GdkKeysyms.GDK_r) {

			setFocus(_refEntry);
			_statusLabel.setText = text("Got Ref focus");
			
			return true;
		}
		
		return false;
	}

	//#More key pressing stuff
	bool ctrlSCallback(Event ev, Widget w)
	{
		if (ev.key.state == GdkModifierType.CONTROL_MASK &&
		    ev.key.keyval == GdkKeysyms.GDK_s) {
			
			saveNotesCurrent();
			_statusLabel.setText = text("Notes'n'Refs Saved"); //#overrides

			return true;
		}
		
		return false;
	}
}

} // version

version(none) {
version(DUnit) {
	void main() {
		loadXMLFile();
		parseXMLDocument();

		runTests_Tree();
	}
} else {
	// production
	void main(string[] args) {
		//#stuff at the start (in the terminal when the the program is run)
		BibleVersion = "English Standard Version";
		loadXMLFile();
		parseXMLDocument();
		writeln("#");
		writeln("##");
		writeln("###");
		writeln("####");
		writeln("#####");
		writeln("######");
		writeln("#######");
		writeln("########");
		writeln("#########");
	version(none) {
		char* line;
		string input;
		import std.string : chomp;
		while(input != "q") {
	        line = readline("D>");
			input = line.to!string.chomp;
	
			if (input.length) {
				add_history(line);
			}
			writeln(g_bible.argReference(g_bible.argReferenceToArgs(input)));
		}
	}
		version(all) {
		//import adam = terminal;
		import terminal;
//		auto terminal = adam.Terminal(adam.ConsoleOutputType.linear);
		auto ter = Terminal(ConsoleOutputType.linear);
		string input;
		bool done = false, doVerse;
		while(! done) {
			doVerse = true;
			writeln("q - quit h - help. eg Joel 1 1 - -1 -- for whole chapter");
			input = ter.getline("D>");
			writeln;
			if (input.length) {
				if (input[0] == 'q') {
					done = true;
					break;
				}
				if (input[0] == 'h') {
					writeln("q - quit\n" ~
						"sp\"<phrase>\"\n" ~
						"h - help"); //\nEvery # #");
					doVerse = false;
				}
			}
			if (doVerse)
				writeln(g_bible.argReference(g_bible.argReferenceToArgs(input)));
		} // version none
	}
	
		/+
		string str = args[1 .. $].join(" ");
		writeln('[', str, ']');
		writeln(g_bible.argReference(g_bible.argReferenceToArgs(str))); //#here
			+/

		//genListOfBookTitlesAndNums();
		//generateEnumOfBooks();
		//printWholeBible(); // book name. chapter # and ver # every verse
		
		//convertReferencesFromFile(); //#maybe disabled
		//convertReferencesFromUserInput(); //#maybe disabled
		
		//writeln(convertReferencesFromNotesFile(readText("source.txt"))); //#maybe disabled

	} // main
}
} // library