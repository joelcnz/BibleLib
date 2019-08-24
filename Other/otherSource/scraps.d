//#progress bar
//#clipboard
//#combo text

version(DUnit)
class BibleTests {
	mixin TestMixin;
	
	//alias g_bible this; // this; //#not work here with DUnit
	alias bible = g_bible;
	
	void testNotesReferenceExpand() {
		auto start ="I went |_John 11 35for a walk.";
		auto conversion = convertReferencesFromNotesFile(start);
		string test = "I went John 11:35 -@- Jesus wept.\nfor a walk.";

		debug(0) {
			writeln("     start>", [start], "<");
			writeln("conversion>", [conversion], "<");
			writeln("      test>", [test], "<");
		}

		assertEquals(conversion, test);
	}
	
	debug(10) {
		void testParseReferencies() {
			// Assert
			with(bible)
				assert(parseNumber( /+ number of chapters etc: +/ 10, /+ position +/ -1) == 9),
				assert(parseNumber(10, -11) == 9),
				assert(parseNumber(10, 0) == 0),
				assert(parseNumber(10, 1) == 1);
		}
		
		void testParseInput() {
			// Assert
			with(bible)
				assert(toInt("-1") == -1, "not -1"),
				assert(toInt("1") == 1, "not 1"),
				assert(toInt("a") == 1),
				assert(toInt("a.2f") == 1),
				assert(toInt("a.2-f") == 1),
				assert(toInt("") == 1);
		}
		
		void testReduceByOne() {
			int a,b,c,d,e,f;
			a = b = c = d = e = f = 1;
			bible.reduceNumbers(a,b,c,d,e,f);
			int result = a+b+c+d+e+f;
			assert(result == 0);
		}
		
		void testInputRef() {
			enum End {fromStart, fromEnd}
			with(bible) {
				string vref(string str, End end = End.fromStart) {
					string result = argReference(str.split());
					writeln("'", result, "'");

					//result = result[end == End.fromStart ? 0 : result.length - str.length
					//	.. end == End.fromStart ? str.length : result.length];

					if (end == End.fromStart)
						result = result[0 .. str.length];
					//writeln("result - '", result, "'");

					return result;
				}
				//assert(argReference("Genesis 1 1".split)[0 .. 11] == "Genesis 1:1");
				//assert(argReference("Genesis  1".split
				assert(vref("Genesis 1 1") == "Genesis 1:1");
				assert(vref("genesis 2 1") == "Genesis 2:1");
				assert(vref("Genesis -1 -1") == "Genesis 50:26");
				//assert(vref("Genesis -1") == "Genesis 50:1");
				assert(vref("Revelation -1 -1") == "Revelation 22:21");
				assert(vref("Psalms 119 -1 ") == "Psalms 119:176");
			}
		}
	} // debug 10
}

/+
//not work very far
foreach(booko; m_books[book .. book + (book2 - book) + 1]) {
	bookChange = chapterChange = verseChange = false;
	verses ~= m_books[book].m_bookTitle ~ ' ' ~ m_books[book].m_chapters[chapter].m_chapterTitle ~ ":";
	foreach(chaptero; booko.m_chapters[chapter .. chapter + (chapter2 - chapter) + 1])
		foreach(verseo; chaptero.m_verses[verse .. verse + (verse2 - verse) + 1]) {
			verses ~= verseo.m_verseTitle ~ (verseChange ? " " : " -- ") ~ verseo.m_verse ~ '\n';
			verseChange = true;
		}
}
+/

//just from within a chapter
version(OldVersion) {
	inVerse = false;
	string bookTitle = m_books[book].m_bookTitle;
	version(ModifyTitle) {
		if (bookTitle[0].isDigit()) {
			bookTitle = bookTitle[0] ~ " " ~ bookTitle[1 .. $];
		}
	}
	verses ~= bookTitle ~ ' ' ~ m_books[book].m_chapters[chapter].m_chapterTitle ~ ":";
	foreach(verseo; m_books[book].m_chapters[chapter].m_verses[verse .. verse + (verse2 - verse) + 1]) {
		verses ~= verseo.m_verseTitle ~ (inVerse ? " " : " -- ") ~ verseo.m_verse ~ '\n';
		inVerse = true;
	}
}

//#combo text
version(old) {
		string argReference(string[] args) {
		writeln(q{string argReference(string[] args) ~  `\/`});
		writeln("args ", args);
		if (args.length == 0) {
			writeln("I'm afraid that's quite out of the question!");
			return "";
		}

		// eg Psal 32 1 - -1
		if (args.length == 1) {
			writeln("not whole books yet");
			return "";
		}

		//args = "1 John 5 7".split();
		//writeln(args);
		if (args[0].length == 1) {
			string num = args[0];
			args[1]=num~args[1];
			args = args[1..$];
			//writeln(args);
		}

		enum NA = -1;
		int bookNumber;
		if (args[0].toLower() == "book") {
			bookNumber = parseNumber(66 + 1, toInt(args[1])); //#note the '+ 1', because it is what the user put
			args = args[1 .. $]; // pop the front
		}
		else {
			bookNumber = bookNumberFromTitle(args[0]); // eg args[0] eg 'Genesis'
			if (bookNumber == -1)
				return "";
		}
		
		int chapterNumber;

		if (bookNumber != 0) {
			chapterNumber = parseNumber(
									m_books[bookNumber - 1].m_chapters.length + 1,
									toInt(args[1]));
		} else {
			return "";
		}
		
		//writeln("bookNumber: ", bookNumber, " chapterNumber: ", chapterNumber);
		//#why m_verses.length + 1
		size_t verseNumber, verseNumber2;

		/* eg Gen 1 */
		if (args.length == 2) {
			args.length += 3;
			args[2]="1";
			args[$-2]="-";
			//#chapter not limited, and crash!
			args[$-1]=(m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length).to!string();
		}
	
		if (args.length > 2) {
			size_t vnum;
			try {
				vnum = parseNumber(m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1
					, toInt(args[2]));
			if (bookNumber <= m_books.length
				&& chapterNumber <= m_books[bookNumber - 1].m_chapters.length
				//&& toInt(args[2]) <= m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length) {
			) {
				verseNumber = parseNumber(m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1
					, toInt(args[2]));
			}
			else debug
				writeln("<zap>");
			} // try
			catch(Error er) { writeln("Error has happened!"); } //#error message
		}
		else
			//whole chapter
			verseNumber = 1,
			verseNumber2 = m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1;

		//#eg 'Gen 1 1 -' -- get whole chapter
		//if (args.length == 4)
		//	args ~= (m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1).to!string;
		if (args.length > 4)
			verseNumber2 =
				parseNumber(m_books[bookNumber - 1].m_chapters[chapterNumber - 1].m_verses.length + 1, toInt(args[4]));
		
		// '- 1' before this and not after this
		size_t dummyBook, dummyChapter;
		reduceNumbers(bookNumber, chapterNumber, verseNumber, dummyBook, dummyChapter, verseNumber2);
		
		string result;
		if (args.length < 5) {
			if (args.length == 2)
				result = getVerseRange(bookNumber, chapterNumber, verseNumber, bookNumber, chapterNumber, verseNumber2);
			else
				result = getVerseRange(bookNumber, chapterNumber, verseNumber, bookNumber, chapterNumber, verseNumber);
		}
		else
			result = getVerseRange(bookNumber, chapterNumber, verseNumber, bookNumber, chapterNumber, verseNumber2);
		
		if (1==2)
			writeln(result);

		//#info at arg place
		/*
		string book;
		int chapter,
		chapterCount,
		verseCount;
		*/

		import std.stdio: writeln;
		writeln();

		g_info = Info(
			getBook(cast(int)(bookNumber + 1)).m_bookTitle, // string book
			cast(int)(chapterNumber + 1), // int chapter
			cast(int)(m_books[bookNumber].m_chapters.length), // int chapter count
			cast(int)(m_books[bookNumber].m_chapters[chapterNumber].m_verses.length) // int verse count
		);

		return result;
	}
} // version old

version(take1) {
	// "1 Joh 2:3-4"(<- maybe not deal with this) - "1Joh 2 3 - 4" //#but what about "1Joh 2 3 - -1", the "-"'s get removed
	string[] argReferenceToArgs(string str) {
		mixin(trace("/* in string[] argReferenceToArgs(string str) { */ str"));
		string bookTitle;
		bool alpha = false;
		foreach(i, c; str) {
			if (alpha == false && c.isAlpha()) {
				alpha = true;
			}

			if (alpha && (i+1 == str.length || c == ' ') ) {
				break;
			}

			if (c != ' ') {
				bookTitle ~= c;
			}
		}

		size_t[] inNum(string s) {
			char[] cs = s[bookTitle.length .. $].dup;
			//int count;

			//#New stuff for the full Jyble
			foreach(i, ref c; cs) {
				if (i + 1 < cs.length && c == '-' && cs[i+1].isDigit()
					&& i > 0 && ! cs[i-1].isDigit())
					continue;
				if (! c.isDigit()) {
					c = ' ';
				}
			}
			
			auto str = cs.idup;
			auto result = str.split().to!(size_t[]);
			mixin(trace("result"));

			return result;
		}

		auto nums = inNum(str);

		string s;
		foreach(i, n; nums) {
			if (i == 2 && nums.length>2) {
				s ~= " - ";
			}
			s ~= n.to!string() ~ " ";
		}

		//#work here
		auto result = (bookTitle~" "~s).split();

//		mixin(trace("result"));

		return result;
	}
} // take 1

//_chapters.insert(0, null, c.to!string);

//#progress bar
    foreach(i, book; books) {
		writeln('[', '-'.repeat.take(i).array, ' '.repeat.take(66-i).array, ']', '\r');
		stdout.flush();

//#clipboard
	version(none) {
		//from clipboard (I copy this for trying these clipboard functions
		string str = _clipboard.waitForText();
		writeln("Get from clip board ", [str]);
		
		_clipboard.setText("_clipboard");
		writeln("setText to clipboard and waitForText ", [_clipboard.waitForText()]);
	}


	string gen;
	version(none) {
		/+ John 3 16 - 17 -- words: 2 - hits: 7, words: 1 - hits: 28. 7's 1 +/ gen = argReference(argReferenceToArgs("John 3 16 - 17")); gen = "16 "~gen[13 .. $];
	}
			with(g_bible) {
				
				//foreach(a; 1 .. 31+1 )
				//	gen ~= argReference(argReferenceToArgs(format("Gen 1 %s", a))); // ~ "\n"; //#new line <
				/+ John 3 16 - 17 -- words: 2 - hits: 7, words: 1 - hits: 28. 7's 1 +/ gen = argReference(argReferenceToArgs("John 3 16 - 17")); gen = "16 "~gen[13 .. $];
			}
			
	writeln("Printing how many of each letter.");

	import std.range;
	import std.string;
	import std.algorithm;

	//#ELS - equal distance letter sequences
	int i;
	foreach(l; gen.stride(7)) {
		write(l);
		++i;
		if (i == 7)
			break;
	}
	.writeln();

	// these not work ?
	//gen = removechars(gen, digits.to!dstring);
	version(none) {
	auto g2 = gen;
	gen = "";
	foreach(c; g2)
		if (inPattern(c, std.ascii.letters~" "))
			gen ~= c;
	}

	string gen2;
	bool[dchar] unq;
	foreach(h; gen)
		if (h !in unq) {
			gen2 ~= h;
			unq[h] = true;
		}
	writeln(gen, '\n', gen2);

	struct Lst {
		string tx;
		ulong cnt;
	}
	Lst[] lst;
	ulong[ulong] repeats;
	foreach(h; gen2) {
		repeats[count(gen, h)]++;
		lst ~= Lst(text(h, " (", count(gen, h), ")  ").to!string, count(gen, h));
	}

	sort!"a.cnt < b.cnt"(lst);
	foreach(p; lst)
		writeln(p.tx);

	foreach(c; iota(7, 127, 7)) {
		if (count(repeats.values, c) > 0) {
			write(c, "'s: ", count(repeats.values, c), '\n');
		}
	}

	version(none)
	foreach(h; gen2) {
		auto c = count(gen, h);

		if (c % 7 == 0)
			write(c, "'s (#): 7 x "); (c/7).writeln;
	}

	ulong[string] words;
  	foreach(word; gen.split) {
		words[word]++;
	  	//writeln(word);
	}

	struct KeyVals {
		ulong value;
		string word;
	}
	KeyVals[] kvs;
	foreach(word, value; words) {
		kvs ~= KeyVals(value, word);
	}

	sort!"a.value < b.value"(kvs);
	ulong[ulong] num;
	foreach(kv; kvs) {
		num[kv.value]++;
		writeln(kv.value, ' ', kv.word);
	}

	struct Snum {
		ulong k;
		ulong v;
	}
	Snum[] snum;
	foreach(kv, value; num) {
		snum ~= Snum(kv, value);
	}
	sort!"a.v < b.v"(snum);
	foreach(sn; snum) {
		writeln("words: ", sn.k, " hits: ", sn.v);
	}
}
		version(none) {
		/+
		 + 1. Text file comes up.
		 + 2. Enter referances, exit
		 + 3. Add the '|_' to each verse referance, and the result comes up from where you can copy
		 +/
		string inputTextFile = "input.txt", outputTextFile = "result.txt";
		system("mp "~inputTextFile);
		string inputTextFileData;
		foreach(line; File(inputTextFile, "r").byLine()) {
			if (line.length > "|_".length) {
				inputTextFileData ~= "|_"~line; //~"\n";
			}
			else {
				inputTextFileData ~= '\n';
			}
		}
		inputTextFileData = fixMultiBooks(inputTextFileData);
		string converted = inputTextFileData.convertReferencesFromNotesFile();
		setTextClipboard(converted);
		auto f = File(outputTextFile, "w");
		f.write(converted);
		f.close();
		system("mp "~outputTextFile);
		} // version
		} // not Gui
	}

	/+
	// in Bible class
	void print() {
		writeln( getVerse( BookId.Genesis, 1, 1 ) );
		writeln( getVerse( BookId.Genesis, 1, 2 ) );
		writeln( getVerse( 66, 1, 2 ) );
		
		foreach( i, book; m_books )
			if ( book.m_bookTitle == "Psalms" ) {
				writeln( getVerse( i+1, 118, 8 ) ); // book.m_bookTitle,118, 8);
				break;
			}
		
		listVerses();
		
		writeln(getVerse(67,  1,  1)),
		writeln(getVerse(1, 999, 1)),
		writeln(getVerse(1,   1, 999));
	}
	+/

	/+
	// from the Bible class
	void listVerses() {
		string[] verseList;
		foreach( book; m_books )
			foreach( chapter; book.m_chapters )
				foreach( verse; chapter.m_verses )
					verseList ~= text(
						book.m_bookTitle, ' ',
						chapter.m_chapterTitle, ":",
						verse.m_verseTitle, ' ',
						verse.m_verse );
		//foreach( verse; verseList )
		//	writeln( verse );
		writeln( "Verses in the ESV: ", verseList.length );
		
		int total = 0;
		foreach( v; verseList )
			total += v.length;
		writeln( "Letters etc in the ESV: ", total );
		
		writeln( "Middle verse of the ESV: ", verseList[$/2] );
	}
	+/

