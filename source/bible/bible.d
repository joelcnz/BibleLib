module bible.bible;

//#not sure about this
//debug = 5;

//#this would be good to use

//#doesn't work with new lines
//#not sure about this
//g_bible.argReference(g_bible.argReferenceToArgs(g_forChapter[index]))
//#hack!
//#Need more work
//#untested
//#may brake program
//#just split
//#not work!
//#error message
//#New stuff for the full Jyble
//#works with this too
//#info at arg place
//#newer
//#chapter not limited, and crash!
//#but what about "1Joh 2 3 - -1", the "-"'s get removed
//#not work
//#eg 'Gen 1 1 -' -- get whole chapter
//#clear the text file

//version = DUnit; // dep
//version = OldVersion; //#works with this too
version = ModifyTitle; // '1John' to '1 John'

import std.stdio;
import std.string;
import std.array: split, replace;
import std.file;
import std.conv;
import std.ascii;

//import dunit;
import bible.base;
import jmisc;

@safe:
class Bible {
	bool m_retValue;

	Book[] m_books;
	int _book, _chapter, _verse, _book2, _chapter2, _verse2; //#Need more work

	enum ReferanceType {/* Joel 1 1: */ three, /* Joel 1 1 3: */ four, /* Joel 1 1 - 3: */ five, /* Joel 1 */ two, /* Joel 1 1 - 2 3: */ six, /* Joel 1 1 - Amos 1 3: */ seven}
	//int chapter, chapters, 
	enum NA = -1; // invalid book

	bool retValue() { return m_retValue; } //#this would be good to use

	string headInfo() const {
		import std.string: format;
		return "";
	}

	// -1 will be -2 and -2 -3
	int parseNumber(in int max, int number) { //pure {
		if (number < 0) {
			number++;
			int n = max - (number * -1);
			
			return n;
		} else if (number > max){
			return max;
		}

		return number;
	}
	
	int toInt(in string str) {
		int ret;
		m_retValue = true;
		try {
			ret = str.to!int;
		} catch(Exception e) {
			ret = 1;
			m_retValue = false;
		}
		return ret;
	}

	//g_bible.expVers(args[0], "exp_" ~ args[0]);
	void expVers(in string fileNameIn, in string fileNameOut) {
		import std.file: readText;
		import std.string: indexOf, split, stripRight;
		import std.ascii: newline;

		auto last_g_wrap = g_wrap;
		g_wrap = false;
		scope(exit)
			g_wrap = last_g_wrap;
		string text;
		auto lines = readText(fileNameIn).split(newline);
		if (! lines.length) {
			writeln("Empty file!");
			return;
		}
		foreach(i, ref line; lines) {
			string eline;
			long tend = line.indexOf("->");
			if (tend == -1)
				eline = line.stripRight;
			else
				eline = line[0 .. cast(size_t)tend].stripRight;
			writeln(">", eline.split, "<");
			string verses = argReference(eline.split, /* feed back */ true);
			writeln(">", verses, "<");
			if (verses != "")
				line = "|_" ~ line ~ " <> " ~ verses[0 .. (eline == "" ? 0 : $ - 1)];

			text ~= line;
			if (i != lines.length - 1)
				text ~= newline;
		}

		File(fileNameOut, "w").write(text);
		writeln(text);
	}

	int bookNumberFromTitle(string bookTitle, bool feedBack = true) {
		if (bookTitle[$ - 1].isDigit || bookTitle[0]== '-')
			return bookTitle.to!int;

		int bookNumber = NA;
		
		import std.range;
		if (bookTitle.length > 2 && bookTitle[0 .. 2] == "|_") /* then */ bookTitle = bookTitle.drop(2);
		
		foreach(int i, book; m_books)
			if (book.m_bookTitle.length >= bookTitle.length
				&& book.m_bookTitle[0 .. bookTitle.length].toLower == bookTitle.toLower) {
				bookNumber = i + 1;
				break;
			}
			
		if (bookNumber == NA) {
			if (feedBack) {
				debug writeln("No book match for '", bookTitle, "'");
			}

			return NA;
		}
		
		return bookNumber;
	}

@trusted:
	string[] getReference(string[] args) {
		//import misc.base;
		//1Joh 1 1 -> house
		//to:
		//1Joh 1 1
		//1Joh 1 1 - -1 -- rocks
		//to:
		//1Joh 1 1 - -1
		import std.string;
		string[] newArgs;
		string input = args.join(" ");
		debug(5) mixin(trace("input"));
		foreach_reverse(i, a; input) {
			debug(5) mixin(trace("i", "a"));
			if (std.ascii.isDigit(a)) {
				newArgs = input[0 .. i + 1].split;
				break;
			}
		}
		debug(5) mixin(trace("newArgs"));
 		
		return newArgs;
	}

	///Psal 150 5 - Prov 1 2
	//#just split
	string[] argReferenceToArgs(string str) {
		return str.split;
	}

	/// Enter verse ref (eg. 'Psal 32 1 - -1')
	string argReference(string[] args, bool feedBack = true) {
		//args = getReference(args); //#may brake program

		try {
			if (feedBack)
				debug(5) writeln("args: ", args);
			int bookNumber, chapterNumber, verseNumber,
				bookNumber2, chapterNumber2,verseNumber2;

			// eg. Joel 1
			if (args.length == 2) {
				bookNumber = bookNumberFromTitle(args[0], feedBack); // eg args[0] might be 'Genesis' or '1' (which is also Genesis)
				if (bookNumber == NA)
					return "";
				chapterNumber = args[1].to!int;
				
				//args ~= "1 \n- \n-1".split; //["1", "-", "-1"]; //#hack!
				args ~= "1 - -1".split;
				//return getVerseRange(bookNumber - 1, chapterNumber - 1, verseNumber - 1,
				//					 bookNumber - 1, chapterNumber - 1, verseNumber2 - 1, ReferanceType.two);
			}
			
			// Psalm 32 -1 -- first main
			if (args.length == 3) {
				if (feedBack)
					debug(4)
						mixin(trace("/* argReference */ args"));

				bookNumber = bookNumberFromTitle(args[0], feedBack); // eg args[0] might be 'Genesis' or '1' (which is also Genesis)
				if (bookNumber == NA)
					return "";
				chapterNumber = args[1].parse!int;
				verseNumber = args[2].parse!int;
				
				if (feedBack)
					debug(5) writefln("Entered (single verse): book %s, chap %s, ver %s", bookNumber, chapterNumber, verseNumber);
				
				return getVerseRange(bookNumber - 1, chapterNumber - 1, verseNumber - 1,
									 bookNumber - 1, chapterNumber - 1, verseNumber - 1, ReferanceType.three);
			}

			//#not sure about this
			// Psal 32 1 -1
			if (args.length == 4) {
				bookNumber = bookNumberFromTitle(args[0], feedBack); // eg args[0] 'Genesis'
				if (bookNumber == NA)
					return "";
				chapterNumber = args[1].to!int;
				verseNumber = args[2].to!int;
				verseNumber2 = args[3].to!int;

				return getVerseRange(bookNumber - 1, chapterNumber - 1, verseNumber - 1,
									 bookNumber - 1, chapterNumber - 1, verseNumber2 - 1, ReferanceType.four);
			}
			
			// Psal 32 1 - -1 - main second
			if (args.length == 5) {
				bookNumber = bookNumberFromTitle(args[0], feedBack); // eg args[0] 'Genesis'
				if (bookNumber == NA)
					return "";

				chapterNumber = args[1].to!int;
				verseNumber = args[2].to!int;
				verseNumber2 = args[4].to!int;

				return getVerseRange(bookNumber - 1, chapterNumber - 1, verseNumber - 1,
									 bookNumber - 1, chapterNumber - 1, verseNumber2 - 1, ReferanceType.five);
			}
			
			//   0   1 2 3 4  5
			// Psal 32 1 - 2 -1 (Psalms 32:1-2:22)
			if (args.length == 6) {
				bookNumber = bookNumberFromTitle(args[0], feedBack); // eg 1 args[0] 'Genesis'
				if (bookNumber == NA)
					return "";
				chapterNumber = args[1].to!int;
				verseNumber = args[2].to!int;
				chapterNumber2 = args[4].to!int;
				verseNumber2 = args[5].to!int;

				return getVerseRange(bookNumber - 1, chapterNumber - 1, verseNumber - 1,
									 bookNumber - 1, chapterNumber2 - 1, verseNumber2 - 1, ReferanceType.six);
			}

			//  0    1  2 3  4  5 6
			//Psalm 150 5 - Prov 1 2 -- the '-' gets removed at the moment
			//Error: ./run Joel 1 1 - Joel -1 -1 -> misses the last verse
			if (args.length == 7) {
				bookNumber = bookNumberFromTitle(args[0], feedBack); // eg args[0] might be 'Genesis'
				if (bookNumber == NA)
					return "";
				chapterNumber = args[1].to!int;
				verseNumber = args[2].to!int;

				bookNumber2 = bookNumberFromTitle(args[4], feedBack);
				chapterNumber2 = args[5].to!int;
				if (bookNumber == NA)
					return "";
				verseNumber2 = args[6].to!int;
				
				debug(5) writeln("book2: ", bookNumber2," chap2: ", chapterNumber2, " verse2: ", verseNumber2);

				return getVerseRange(bookNumber - 1, chapterNumber - 1, verseNumber - 1,
									 bookNumber2 - 1, chapterNumber2 - 1, verseNumber2 - 1, ReferanceType.seven);
			}
		} catch(Exception e) {
			writeln("Invaild input!");
		}

		return "";
	}

	void reduceNumbers(ref int book, ref int chapter, ref int verse, ref int book2, ref int chapter2, ref int verse2) {
		foreach(id; [&book, &chapter, &verse, &book2, &chapter2, &verse2])
			--(*id);
	}
	
@safe:
	string getReference(int bookNum, int chapterNum = 0, int verseNum = 0) {
		return "";
	}

	Book getBook(int bookNum) {
		//m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1

		return m_books[bookNum - 1]; // I removed the '- 1'
	}

@trusted:
	int numberOfVerses() {
		return cast(int)m_books[_book - 1].m_chapters[_chapter - 1].m_verses.length;
	}

	string getVerseRange(int book, int chapter, int verse, int book2, int chapter2, int verse2, ReferanceType reft) {
		debug(5) writeln(q{string getVerseRange(int book, int chapter, int verse, int book2, int chapter2, int verse2): } ~ ` \/`);
		debug(5) writefln("book %s, chapter %s, verse %s, book2 %s, chapter2 %s, verse2 %s", book, chapter, verse, book2, chapter2, verse2);
		scope(failure) {
			//debug writefln("Error: get verse range: An error has happen!"
			//	"\nBook: %s, chapter: %s, verse: %s, book2: %s, chapter2: %s, verse2: %s",
			//	m_books[book].m_bookTitle, chapter + 1, verse + 1, m_books[book2].m_bookTitle, chapter2 + 1, verse2 + 1);
			return "";
		}
		
		debug(5) writefln("using from the last, before:" ~
			"\nBook: %s, chapter: %s, verse: %s, book2: %s, chapter2: %s, verse2: %s",
			book, chapter + 1, verse + 1, book2 + 1, chapter2 + 1, verse2 + 1);

		//import jxmisc;

		book = parseNumber(66, book);
		chapter = parseNumber(cast(int)m_books[book].m_chapters.length, chapter);
		debug(5)
			mixin(trace("/* verse before */ verse"));
		verse = parseNumber(cast(int)m_books[book].m_chapters[chapter].m_verses.length, verse);
		debug(5)
			mixin(trace("/* verse after */ verse"));

		g_info.book = m_books[book].m_bookTitle;
		g_info.chapter = chapter;
		g_info.verse = verse + 1;
		g_info.verseCount = cast(int)m_books[book].m_chapters[chapter].m_verses.length;
		g_info.chapterCount = cast(int)m_books[book].m_chapters.length;

		book2 = parseNumber(66, book2);
		chapter2 = parseNumber(cast(int)m_books[book].m_chapters.length, chapter2);
		verse2 = parseNumber(cast(int)m_books[book].m_chapters[chapter].m_verses.length, verse2);
		
		auto inBook = false,
			inChapter = false,
			inVerse = false;
		string verses;
		
		// c for current (eg cbook - current book)
		int cbook = book;
		int cchapter = chapter;
		int cverse = verse;

		bool next;
		do {
			string verseOther;
			if (! inBook) {
				debug(5) mixin(trace("cbook"));
				verseOther = m_books[cbook].m_bookTitle ~ " ";


				inBook = true;
				inChapter = false;
			}
			if (! inChapter) {
				inChapter = true;
				import std.conv : text;
				verseOther ~= text(cchapter + 1, ":");
			}

			debug(4)
				mixin(trace("verseOther"));

			final switch(g_wrap) {
				case true:
					//#doesn't work with new lines
					verses ~= wrap(verseOther ~ m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verseTitle ~
								(inVerse ? " " : " -> ") ~ m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verse ~
								'\n', g_wrapWidth, null, null, 4);
				break;
				case false:
					verses ~= verseOther ~ m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verseTitle ~
								(inVerse ? " " : " -> ") ~ m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verse ~
								'\n';
				break;
			}
			
			inVerse = true;
			cverse++;
			debug(5) mixin(trace("cverse"));
			//if (cverse == m_books[cbook].m_chapters[cchapter].m_verses.length) {
			if (cverse >= m_books[cbook].m_chapters[cchapter].m_verses.length) {
				inChapter = false;
				cverse = 0;
				cchapter++;
				if (cchapter == m_books[cbook].m_chapters.length) {
					cchapter = 0;
					cbook++;
					inBook = false;
					//#not sure about this
					if (cbook == 67) {
						debug writeln("Error!");
						break;
					}
				}
				inVerse = false;
			} // if (cverse

			if (reft == ReferanceType.three) // same book too, of course
				break;
			
//			enum ReferanceType {/* Joel 1 1: */ one, /* Joel 1 1 - 3: */ five, /* Joel 1 1 - 2 3: */ six, /* Joel 1 1 - Amos 1 3: */ seven}
			if (reft == ReferanceType.five) { // possible to have same book come under multiBook
				if (next)
					break;
				if (cverse == verse2)
					next = true;
			}
				
		} while(!(cbook == book2 && cchapter == chapter2 && cverse == verse2 + 1));
		
		append("glean.txt", verses);
		
		//#untested
		_book = book + 1;
		_chapter = chapter + 1;
		_verse = verse + 1;
		_verse2 = verse2 + 1;

/+
			result = text(	"Book: ", book, "\n",
							"Chapter: ", chapter, "\n",
							"Total chapters: ", chapterCount, "\n",
							"Total current chapter verses: ", verseCount,"\n",
							'-'.repeat(3), "\n");
+/
		g_info.chapter = _chapter;
		//g_info.
		
		return verses;
	}
}

@system:
unittest {
	//BibleVersion = "English Standard Version";
	loadXMLFile();
	parseXMLDocument();
	
	writeln(g_bible.argReference("Joel 3 21".split)[$ - 7 .. $ - 2]);

	assert(g_bible.argReference("Joel 3 21".split)[$ - 7 .. $ - 2] == "Zion.");
	writeln("Joel 3 1 - -1");
	assert(g_bible.argReference("Joel 3 1 - -1".split)[$ - 7 .. $ - 2] == "Zion.");
	assert(g_bible.argReference("Joel 3".split)[$ - 7 .. $ - 2] == "Zion.");
	assert(g_bible.argReference("Joel -1".split)[$ - 7 .. $ - 2] == "Zion.");
	assert(g_bible.argReference("29 -1".split)[$ - 7 .. $ - 2] == "Zion.");
	//assert(g_bible.argReference("Rom 8 28 - 29".split) == );
	//assert(g_bible.argReference("Joel 1 1 - -1 21".split)[$ - 7 .. $ - 2] == "Zion."); // fails
	//assert(g_bible.argReference("Joel 1 1 - -1 -1".split)[$ - 7 .. $ - 2] == "Zion."); // fails
	//assert(g_bible.argReference("Joel 1 1 - Joel -1 -1".split)[$ - 7 .. $ - 2] == "Zion."); // fails
}
