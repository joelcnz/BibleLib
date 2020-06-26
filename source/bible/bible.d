module bible.bible;

//#Rom 6 23 - 23 and Rom 6 23 - 6 23 and Rom 6 23 - Rom 6 23 => all display Rom 6:23-7:23
//debug = 5;

//#this would be good to use

//g_bible.argReference(g_bible.argReferenceToArgs(g_forChapter[index]))
//#hack!
//#Need more work
//#untested
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
//#eg 'Gen 1' -- get whole chapter
//#clear the text file

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
	int m_retValue;

	Book[] m_books;
	int _book, _chapter, _verse, _book2, _chapter2, _verse2; //#Need more work

	enum ReferanceType {/* Joel 1 1: */ three, /* Joel 1 1 - 3: */ five, /* Joel 1 */ two, /* Joel 1 1 - 2 3: */ six, /* Joel 1 1 - Amos 1 3: */ seven}
	//int chapter, chapters, 
	enum NA = -1; // invalid book

	int retValue() { return m_retValue; } //#this would be good to use

	// -1 will be -2 and -2 -3
	int parseNumber(in int max, int number) { //pure {
		if (number < 0) {
			number++;
			int n = max - (number * -1);
			
			return n;
		} else if (number > max) {
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

	/// eg John 3:16-17
	string getTitle(int book, int chapter, int verse, int book2, int chapter2, int verse2) {
		return m_books[book].m_bookTitle ~ " " ~ text(chapter + 1, ":") ~
			m_books[book].m_chapters[chapter].m_verses[verse].m_verseTitle ~
				(verse2 > verse ? "-"~(chapter2 == chapter ? (verse2+1).to!string : "") : "");
	}

	auto expVers(in string fileNameIn, in string fileNameOut, in string txtIn = "") {
		import std.file : readText;
		import std.string : indexOf, split, stripRight;

		string result;

		auto last_g_wrap = g_wrap;
		g_wrap = false;
		scope(exit)
			g_wrap = last_g_wrap;
		string text;
		string[] lines;
		if (txtIn == "")
			lines = readText(fileNameIn).split("\n");
		else
			lines = txtIn.split("\n");
		if (! lines.length) {
			return "Empty file!";
		}
		foreach(i, ref line; lines) {
			string eline;
			long tend = line.indexOf("->");
			if (tend == -1)
				eline = line.stripRight;
			else
				eline = line[0 .. cast(size_t)tend].stripRight;
			string verses = argReference(eline.split, /* feed back */ false);
			if (verses != "")
				//line = "|_" ~ line ~ " <> " ~ verses[0 .. (eline == "" ? 0 : $ - 1)];
				line = line[(tend == -1 ? eline.length : tend) .. $] ~ " <> " ~
					verses[0 .. (eline == "" ? 0 : $ - (verses[$ - 1] == '\n' ? 1 : 0))];

			text ~= line;
			if (i != lines.length - 1)
				text ~= "\n";
		}
		result = text;

		if (txtIn == "")
			File(fileNameOut, "w").write(text);

		return result;
	}

	int bookNumberFromTitle(string bookTitle, bool feedBack = false) {
		if (bookTitle[$ - 1].isDigit || bookTitle[0] == '-') {
			int n;
			try {
				n = bookTitle.to!int;
			} catch(Exception e) {
				return NA;
			}
			return n;
		}

		int bookNumber = NA;
		
		import std.range;
		if (bookTitle.length > 2 && bookTitle[0 .. 2] == "|_") /* then */ bookTitle = bookTitle.drop(2);
		if (feedBack)
			writeln("Book title: [", bookTitle, "]");
		if (bookTitle.length < 3)
			return NA;
		
		foreach(i, book; m_books)
			if (book.m_bookTitle.length >= bookTitle.length
				&& book.m_bookTitle[0 .. bookTitle.length].toLower == bookTitle.toLower) {
				if (feedBack)
					mixin(trace("book.m_bookTitle"));
				bookNumber = cast(int)i + 1;
				break;
			}
			
		if (bookNumber == NA) {
			if (feedBack) {
				debug(10) writeln("No book match for '", bookTitle, "'");
			}

			return NA;
		}
		
		return bookNumber;
	}

@trusted:
	///Psal 150 5 - Prov 1 2
	//#just split
	string[] argReferenceToArgs(string str) {
		return str.split;
	}

	/// Enter verse ref (eg. 'Psal 32 1 - -1')
	string argReference(string[] args, bool feedBack = false) {
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
				if (feedBack)
					37.gh;
				bookNumber = bookNumberFromTitle(args[0], feedBack); // eg 1 args[0] 'Genesis'
				if (bookNumber == NA)
					return "";
					//return args.join(" ");
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

	/// Align numbers from 1-# to 0-#
	void reduceNumbers(ref int book, ref int chapter, ref int verse, ref int book2, ref int chapter2, ref int verse2) {
		foreach(id; [&book, &chapter, &verse, &book2, &chapter2, &verse2])
			--(*id);
	}
	
@safe:
	Book getBook(int bookNum) {
		//m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1

		return m_books[bookNum - 1]; // I removed the '- 1'
	}

@trusted:
	int numberOfVerses() {
		if (_book > 0 && _chapter > 0)
			return cast(int)m_books[_book - 1].m_chapters[_chapter - 1].m_verses.length;
		else
			return 0;
	}

	//#Rom 6 23 - 23 and Rom 6 23 - 6 23 and Rom 6 23 - Rom 6 23 => all display Rom 6:23-7:23
	string getVerseRange(int book, int chapter, int verse, int book2, int chapter2, int verse2, ReferanceType reft) {
		debug(6) writeln(q{string getVerseRange(int book, int chapter, int verse, int book2, int chapter2, int verse2): } ~ ` \/`);
		debug(6) writefln("book %s, chapter %s, verse %s, book2 %s, chapter2 %s, verse2 %s", book, chapter, verse, book2, chapter2, verse2);

		string verses;

		scope(failure) {
			//debug writefln("Error: get verse range: An error has happen!"
			//	"\nBook: %s, chapter: %s, verse: %s, book2: %s, chapter2: %s, verse2: %s",
			//	m_books[book].m_bookTitle, chapter + 1, verse + 1, m_books[book2].m_bookTitle, chapter2 + 1, verse2 + 1);
			return "(failure) - ";
		}
		
		debug(8) writefln("using from the last, before:" ~
			"\nBook: %s, chapter: %s, verse: %s, book2: %s, chapter2: %s, verse2: %s",
			book + 1, chapter + 1, verse + 1, book2 + 1, chapter2 + 1, verse2 + 1);

		//import jxmisc;

		book = parseNumber(66, book);
		chapter = parseNumber(cast(int)m_books[book].m_chapters.length, chapter);
		debug(8)
			mixin(trace("/* verse before */ verse"));
		verse = parseNumber(cast(int)m_books[book].m_chapters[chapter].m_verses.length, verse);
		debug(8)
			mixin(trace("/* verse after */ verse"));
		book2 = parseNumber(66, book2);
		chapter2 = parseNumber(cast(int)m_books[book2].m_chapters.length, chapter2);
		verse2 = parseNumber(cast(int)m_books[book2].m_chapters[chapter2].m_verses.length, verse2);

		debug(8) writefln("using from the last, after:" ~
			"\nBook: %s, chapter: %s, verse: %s, book2: %s, chapter2: %s, verse2: %s",
			book + 1, chapter + 1, verse + 1, book2 + 1, chapter2 + 1, verse2 + 1);

		g_info.book = m_books[book].m_bookTitle;
		g_info.chapter = chapter + 1;
		g_info.verse = verse + 1;
		g_info.verseCount = cast(int)m_books[book].m_chapters[chapter].m_verses.length;
		g_info.chapterCount = cast(int)m_books[book].m_chapters.length;
		
		auto inBook = false,
			inChapter = false,
			inVerse = false;
		
		// c for current (eg cbook - current book)
		int cbook = book;
		int cchapter = chapter;
		int cverse = verse;

		bool next;
		do {
			string verseOther;
			if (! inBook) {
				debug(10) mixin(trace("cbook"));
				//verseOther = m_books[cbook].m_bookTitle ~ " ";
				verseOther = getTitle(book, chapter, verse, book2, chapter2, verse2);

				inBook = true;
				inChapter = false;
			} else if (! inChapter) {
				inChapter = true;
				import std.conv : text;
				if (cchapter != chapter && cverse != verse + 1)
					verseOther ~= text(cchapter + 1, ":") ~
						m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verseTitle ~
							(inVerse ? " " : (verse2 > verse ? "-"~(chapter2 == chapter ? (verse2+1).to!string : "")
								: ""));
							
			}

			debug(15)
				mixin(trace("verseOther"));

			final switch(g_wrap) {
				case true:
					//doesn't work with new lines
					verses ~= wrap(verseOther ~ m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verseTitle ~
								(inVerse ? " " : " -> ") ~ m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verse ~
								'\n', g_wrapWidth, null, null, 4);
				break;
				case false:
					verses ~= verseOther ~
						(inVerse ? m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verseTitle~" " : " -> ") ~
							m_books[cbook].m_chapters[cchapter].m_verses[cverse].m_verse ~ '\n';
				break;
			}
			
			inVerse = true;
			cverse++;
			debug(10) mixin(trace("cverse"));
			//if (cverse == m_books[cbook].m_chapters[cchapter].m_verses.length) {
			if (cverse >= m_books[cbook].m_chapters[cchapter].m_verses.length) {
				inChapter = false;
				cverse = 0;
				cchapter++;
				if (cchapter == m_books[cbook].m_chapters.length) {
					cchapter = 0;
					cbook++;
					inBook = false;
				}
				inVerse = false;
			} // if (cverse

			if (reft == ReferanceType.three) // same book too, of course
				break;
			
//			enum ReferanceType {/* Joel 1 1: */ one, /* Joel 1 1 - 3: */ five, /* Joel 1 1 - 2 3: */ six, /* Joel 1 1 - Amos 1 3: */ seven}
			if (reft == ReferanceType.five || reft == ReferanceType.six || reft == ReferanceType.seven) { // possible to have same book come under multiBook
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

		return verses;
	}
}

immutable loadBibleString = `	import std.path : buildPath;

	immutable BIBLE_VER = "asv"; //"kjv"; //"asv";
	loadBible(BIBLE_VER, buildPath("..", "BibleLib", "Versions"));
`;

auto getEnd(string sample, int count) {
	return sample[$ - (1 + count) .. $ - 1];
}

@system:
@("References1")
unittest {
	mixin(loadBibleString);

	writeln(getEnd(g_bible.argReference("Joel 3 21".split), 5));
	assert(getEnd(g_bible.argReference("Joel 3 21".split), 5) == "Zion.");
}

@("References2")
unittest {
	mixin(loadBibleString);

	writeln("Joel 3 1 - -1\n", g_bible.argReference("Joel 3 1 - -1".split)[$ - 6 .. $]);
	assert(g_bible.argReference("Joel 3 1 - -1".split)[$ - 6 .. $ - 1] == "Zion.");
}

@("References3")
unittest {
	mixin(loadBibleString);
	assert(g_bible.argReference("Joel 3".split)[$ - 6 .. $ - 1] == "Zion.");
}

@("References4")
unittest {
	mixin(loadBibleString);
	assert(g_bible.argReference("Joel -1".split)[$ - 6 .. $ - 1] == "Zion.");
}

@("References5")
unittest {
	mixin(loadBibleString);
	writeln([g_bible.argReference("29 -1".split)[$ - 6 .. $ - 1]]);
	assert(g_bible.argReference("29 -1".split)[$ - 6 .. $ - 1] == "Zion.", "Surposed to be `Zion.`");
}

@("References6")
unittest {
	mixin(loadBibleString);
	writeln('>', g_bible.argReference("Joel -1 -2 - 30 -1 2".split), '<');
	debug(6)
		writeln('>', g_bible.argReference("Joel 1 -2 - 2 2".split), '<');
	assert(getEnd(g_bible.argReference("Joel 1 1 - -1 21".split), 7) == "things.");
}

@("References7")
unittest {
	mixin(loadBibleString);
	assert(getEnd(g_bible.argReference("Joel 1 1 - -1 -1".split), 7) == "things.");
}

@("References8")
unittest {
	mixin(loadBibleString);
	assert(g_bible.argReference("Joel 1 1 - Joel -1 -1".split).getEnd(7) == "things.");
}
