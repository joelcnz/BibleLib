module bible.base;

//#Bomb (ASV) ignoring the fact that it's a xml file
//g_bible.argReference(g_bible.argReferenceToArgs(g_forChapter[index]))
//#Hmm..
//#at the moment it only works for 'god' or so
//#how does this work
//#go through the whole Bible
//#the 2 is the |_ pieces
//#not sure about the seg bit
//#makes SongOfSolomon
//#old stuff

//version = asvtrace;

//version = ESV; // ESV Bible enabled
//version = EndOfBlock;
//version = MakeABlock;
version = normal;

import std.stdio;
import std.string;
import std.file;
import std.conv;
import std.typecons; // may remove
import std.regex: regex, match;
import std.ascii;
import std.algorithm;
import std.range;
import std.typecons;

//import jeca.misc;

import arsd.dom;
//import ini.all;

//public import blbible, blbook, blchapter, blverse, blmisc, blmisco;
public import bible.bible, bible.book, bible.chapter, bible.verse; //, bible.misc; //, bible.info;

import jmisc;

Document g_document;
Bible g_bible;
Info g_info;
bool g_wrap = false;
int g_wrapWidth = 35;

dchar[] g_word;
string[] g_forChapter;

struct Info {
	string bibleVersion,
		   book;
	int chapter,
		verse,
		verseCount,
		chapterCount;
	
	string toString() const {
		import std.conv: text;

		if (book == "")
			return text("Bible: ", bibleVersion);
		return text("Bible: ", bibleVersion, "\n",
					"Book: ", book, "\n",
					"Chapter: ", chapter, "\n",
					"Verse: ", verse, "\n",
					"Total chapter verses: ", verseCount, "\n",
					"Total chapters: ", chapterCount, "\n",
					'-'.repeat(3));
	}
}

void loadBible(in string ver, in string from) {
	import std.path : buildPath;
	import std.string : toUpper;

	switch(ver.toUpper) {
		default: writeln(ver, " unrecognised Bible version"); break;
		case "KJV":
			import bible.kjv;
		
			g_info.bibleVersion = "King James Version";
			writeln(g_info.bibleVersion);
			auto kjv = new jkBible(readText(buildPath(from, "kjvtext.txt")));
			kjv.convertToJyble();
		break;
		/+
		case "ESV":
			g_info.bibleVersion = "English Standard Version";
			writeln(g_info.bibleVersion);
			loadXMLFile();
			parseXMLDocument();
		break;
		+/
		case "ASV":
			g_info.bibleVersion = "American Standard Version";
			writeln(g_info.bibleVersion);
			setupASV(readText(buildPath(from, "asv.xml")));
		break;
	}
}

string[] bl_vers, bl_verRefs;

void loadCrossRefs(in string fileName = "../BibleLib/CrossRefs/cross_references.txt") {
	import std.stdio : File;
	import std.range : enumerate;
	import std.string : split, indexOf, replace;
	import std.algorithm : canFind;
	
	string[] vers, verRefs;
	immutable TAB_LABELS_LINE = 1;
	foreach(i, line; File(fileName, "r").byLine.enumerate(0)) {
		if (TAB_LABELS_LINE != i) {
			auto s = line.split;
			auto ver = s[0];
			auto vref = s[1];

			[&ver,&vref].each!((ref v) => (*v) = (*v).replace(".", " "));

			if (vref.canFind("-")) {
				auto end = vref[vref.indexOf('-') + 1 .. $];
				end = end[end.lastIndexOf(" ")+1..$];
				vref = vref[0..vref.indexOf("-")] ~ " - " ~ end;
			}

			vers ~= ver.idup;
			verRefs ~= vref.idup;
		} // if TAB_LABELS_LINE not equal to i
		i += 1;
	}

	bl_vers = vers;
	bl_verRefs = verRefs;
}

// Like '2 John ..' -> '2John ..'
string fixMultiBooks(string raw) {
	for(int i; i<raw.length; i++) {
		if (raw[i]=='|' && i+3<raw.length && raw[i+1]=='_' && raw[i+2].isDigit() && raw[i+3]==' ') {
			raw=raw[0..i+3]~raw[i+4..$]; 
		}
	}

	return raw;
}

struct Segment {
	size_t st, ed;
	
	void print(string raw) {
		debug(5) writeln(seg(raw));
	}
	
	string seg(string raw) {

		return raw[st .. ed];
	}
}

size_t segs(size_t st, string data) {
	string result;
	string seg;
	bool dash = false;
	size_t ed = st + 1;
	for(;;) {
		char dat = data[ed];

		// if char not in pattern then terminate
		//if (! dat.inPattern(std.ascii.digits ~ " -"))
		import std.ascii: digits;
		if (! (digits ~ " -").canFind(dat))
			break;
		ed++;
		if (ed == data.length)
			break;
	}
	char dat;

	do 
		--ed;
	while(! data[ed].isDigit());
	ed++;

	return ed - st;
}

/+
string convertReferencesFromNotesFile(string raw) {
	// collect tags and book titles
	auto r = regex(`[|][_]\w+`, "g");
	Segment[] seg;
	string[] verses;
	int i = 0;
	foreach(c; match(raw, r)) {
//		if (! any!((a) => a.isAlpha())(c.hit))
//			continue;
		size_t ed = c.pre.length + c.hit.length;
		ed += segs(ed, raw);
		seg ~= Segment(c.pre.length + 2, ed); //#the 2 is the '|_' pieces
		//seg[$-1].print(raw);
		auto parts = seg[$-1].seg(raw).split();
		//writeln(">",parts.join(" "),"<");

		if (parts.length > 1) {
			auto reveal = g_bible.argReference(parts);
			verses ~= reveal;
		}
		else
			seg.length--;
	}

	string goTogether() {
		string result;

		result = raw[0 .. seg[0].st - 2];
		debug(5)
			writeln("start>", result, "<");
		foreach(i, s; seg) {
			debug(5)
				writeln("verses>", verses[i], "<");
			string verse = verses[i]; //"|_" ~ verses[i];
			if (i + 1 < seg.length) {
				result ~= verse ~ raw[s.ed .. seg[i + 1].st - 2];
				debug(5)
					writeln("inter>", verse ~ raw[s.ed .. seg[i + 1].st - 2], "<");
			}
			else {
				result ~= verse ~ raw[s.ed .. $];
				debug(5)
					writeln("end>", verse ~ raw[s.ed .. $], "<");
			}
		}
		
		return result;
	}

//	writeln(result);

//	foreach(verse; verses)
//		writeln('#', verse, '#');

	//return result;
	return goTogether();
}
+/

//#Bomb (ASV) ignoring the fact that it's a xml file
void setupASV(in string data) {
	import std.string : indexOf, split;
    import std.file : readText;
    //import dxml.parser;
    import std.conv : to;

    struct VerseData {
        string id;
        int b, c, v;
        string t;
    }
    VerseData[] verses;

	auto bookNames = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth",
		"1Samuel", "2Samuel", "1Kings", "2Kings", "1Chronicles", "2Chronicles", "Ezra", "Nehemiah", "Esther",
		"Job","Psalms", "Proverbs", "Ecclesiastes", "SongofSolomon", "Isaiah", "Jeremiah", "Lamentations",
		"Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
		"Zephaniah", "Haggai", "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans",
		"1Corinthians", "2Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians",
		"1Thessalonians", "2Thessalonians", "1Timothy", "2Timothy", "Titus", "Philemon", "Hebrews", "James",
		"1Peter", "2Peter", "1John", "2John", "3John", "Jude", "Revelation"];

	import std.datetime.stopwatch;
	StopWatch sw;
	sw.start;

	size_t i;
    auto ls = data.split("\n");
    i = 5;
    while(true) {
        VerseData ver;
        auto line = ls[i];
        //writeln(line);
        immutable code = line[line.indexOf(`"id">`) + 5 .. line.indexOf(`"id">`) + 5 + 8];
        //writeln("[", code, "]");
        ver.id = code;
        ver.b = code[0 .. 2].to!int;
        ver.c = code[2 .. 2 + 3].to!int;
        ver.v = code[2 + 3 .. 2 + 3 + 3].to!int;
        i += 4;
        line = ls[i];
        //writeln("Ver line: [", line, "]");
        ver.t = line[line.indexOf(`"t">`) + 4 .. $ - 8];
        //writeln("Ver: [", ver, "]");
		verses ~= ver;
        if (ver.b == 66 && ver.c == 22 && ver.v == 21)
            break;
        i += 4;
    }

	g_bible = new Bible;

	int b, c, v;
	size_t j;
	break0: do {
		b = verses[j].b;
		g_bible.m_books ~= new Book(bookNames[b-1]);
		version(asvtrace)
			mixin(trace("g_bible.m_books[$-1].m_bookTitle"));
		do {
			c = verses[j].c;
			g_bible.m_books[$-1].m_chapters ~= new Chapter(c.to!string);
			version(asvtrace)
				mixin(trace("j g_bible.m_books[$-1].m_chapters[$-1].m_chapterTitle".split));
			do {
				v = verses[j].v;
				g_bible.m_books[$-1].m_chapters[$-1].m_verses ~= new Verse(v.to!string);
				g_bible.m_books[$-1].m_chapters[$-1].m_verses[$-1].verse = verses[j].t;
				version(asvtrace)
					mixin(trace(("j g_bible.m_books[$-1].m_chapters[$-1].m_verses[$-1].m_verseTitle" ~
						" g_bible.m_books[$-1].m_chapters[$-1].m_verses[$-1].verse").split));
				j += 1;
				if (j == verses.length)
					break break0;
			} while(verses[j].v != 1);
		} while(verses[j+1].c != 1);
	} while(true);

	writeln("Time: ", sw.peek().total!"msecs");
}

void loadXMLFile() {
	writeln( "Loading xml file.." );
	immutable fileName = "esv.xml";
	import std.file : exists;
	assert(exists(fileName), "Not aloud to use the file specified..");
    g_document = new Document(readText(fileName));
}

void parseXMLDocument() {
	writeln( "Processing xml loaded document file.." );

    // the document is now the bible
    g_bible = new Bible;

    auto books = g_document.getElementsByTagName("b");
    foreach(i, book; books) {
       //auto nameOfBook = book.n; // "Genesis" for example. All xml attributes are available this same way

		//book.n = book.n.replace(" ", ""); //#makes SongOfSolomon
		alias b = book;
		debug(5) writeln([b.attrs.n]);
		if (b.attrs.n[1] == ' ')
			b.attrs.n = b.attrs.n[0] ~ b.attrs.n[2 .. $];
		g_bible.m_books ~= new Book(b.attrs.n);

       auto chapters = book.getElementsByTagName("c");
       foreach(chapter; chapters) {
            auto verses = chapter.getElementsByTagName("v");
            
         	g_bible.m_books[$ - 1].m_chapters ~= new Chapter( chapter.attrs.n );

            foreach(verse; verses) {
                 auto v = verse.innerText;

				g_bible.m_books[$ - 1].m_chapters[$ - 1].m_verses ~= new Verse( verse.attrs.n );
				g_bible.m_books[$ - 1].m_chapters[$ - 1].m_verses[$ - 1].verse = v;
//                 // let's write out a passage
                //writeln(g_bible.m_books[$ - 1].m_bookTitle, " ", chapter.n, ":", verse.n, " ", v); // prints "Genesis 1:1 In the beginning, God created [...]
            }
       }
    }
    
}

/+
void convertReferencesFromFile() {
	File file = File("glean.txt", "w"); //#clear the text file
	file.close();
    foreach(reference; File("source.txt", "r").byLine)
		g_bible.argReference(reference.idup.split);    
}

void convertReferencesFromUserInput() {
	writeln("Enter Bible reference ('q' to quit):");
	string[] input;
	bool done = false;
    while(! done) {
		g_bible.argReference(input = readln().split()); //"Gen 1 1 - 2".split);
		if (input.length > 0 && input[0] == "q")
			done = true;
	}
}

//#old stuff
    //bible.print;
    //bible.argReference(args[1 .. $]); //"Gen 1 1 2".split);
void genListOfBookTitlesAndNums() {
	foreach(i, book; g_bible.m_books) {
		writefln("%2s - %s", i + 1, book.m_bookTitle);
	}
}

// I don't think this is even needed!
void generateEnumOfBooks() {
	string result = "enum BookId {\n";
	foreach(i, book; g_bible.m_books) {
		result ~= "\tb" ~ book.m_bookTitle ~ " = " ~ to!string(i + 1) ~ ",\n";
	}
	result = result[0 .. $ - 2] ~ "};";
	writeln(result);
}

auto message(R)(R range, string message = "<>") {
	writeln(message);

	return range;
}

void stripAndpack(ref string text) {
	import std.string: strToLower = toLower;
	import std.algorithm: canFind;
	import std.ascii: lowercase;

	text = text
		.message("To lowercase")
		.strToLower
		.message("remove non letters")
		.filter!(a => lowercase.canFind(a)) //a.inPattern(std.ascii.lowercase))
		.message("Convert to string")
		.to!string
		.message("Made it!");

	writeln("End of function: ", __PRETTY_FUNCTION__);
}

//#at the moment it only works for 'god' or so
// finds the first letter x times, finds counts to the second letter, then uses the number counted to do the rest
string equalDistanceLetterSequence(string str, in size_t bookNumber, in size_t startLetter = 1) {
	writeln("Add verses..");
	string text;
	auto book = g_bible.m_books[bookNumber]; // Eg Genesis
		foreach(chapter; book.m_chapters) {
			foreach(verse; chapter.m_verses) {
				text ~= verse.verse;
			}
		}
	writeln("Make lower case and remove non-letters");
	stripAndpack(text);
		
	//                        1  1  1 1 1 1
	//0 1 2  3  4 5 6  7  8 9 0  1  2 3 4 5
	//a b c [1] d e f [2] g h i [3] k l m n
	/*
		1. find the first of str
		2. find the second of str counting the spaces
		3. check if it works
		4. if it does not, the look for the next second letter (repeat from 2)
		5. print the stuff
	*/
	
	/*
		1. go from the start
		2. check each text + len, with str[l]
	*/
	writeln("Try and find code (can be slow here, you can use Ctrl +C, if you don't want to wait)");
	string strOrg;
	string result;
	enum Ret {success, fail}
	Ret ret;
	Ret check(in size_t st, in size_t len, in string text) {
		size_t tc = st, sc = 0; // Text Current, String Current
		while(tc < text.length && sc < str.length) {
			if (len == 1 || text[tc] != str[sc]) {
				result = "";
				
				return ret = Ret.fail;
			}
			if (tc + len < text.length) {
				result ~= (len > 80 ? "\n" : "") ~ "\n" ~ strOrg[sc] ~ text[tc + 1 .. tc + len];
			} else {
				return ret = Ret.fail;
			}
			tc += len;
			sc += 1;
		}
		
		return ret = Ret.success;
	}
	
	size_t findFrom(in char ch, in size_t st, in string text) {
		foreach(i; st .. text.length) {
			if (text[i] == ch) {
				debug(5) mixin(trace("text[st .. i + 1]"));
				return i;
			}
		}

		return text.length - 1; //#Hmm..
	}

	strOrg = str;
	str = str.toLower;
	size_t first;
	for(int i; i < startLetter; i++) {
		first = findFrom(str[0], first + 1, text);
	}
	if (first == text.length) {
		writeln("Cannot complete");
		return "";
	}

	size_t second = first;
	size_t limit = text.length;
	do {
		second = findFrom(str[1], second + 1, text);
		limit -= 1;
	} while(limit > 0 && check(first, second - first, text) == Ret.fail);
	
	if (ret == Ret.success) {
		writeln(result);
		writeln("\nSuccess!\n", "Distance: ", second - first);
	} else {
		writeln("Failed!");
	}
	
	return "";
}
+/

void resetVerseTags() {
	foreach(i, book; g_bible.m_books)
		foreach(i2, chapter; book.m_chapters)
			foreach(i3, ref verse; chapter.m_verses)
				verse.m_tagged = true;
}

enum WordSearchType {wholeWords, wordParts}

string wordSearch(string[] words, WordSearchType wordSearchType) {
	import std.string, std.algorithm;
	import std.conv: to;

	string info = "Type: " ~ wordSearchType.to!string ~ ", Search: " ~ words.join(" ") ~ "\n";
	string hits;
	string result;
	int count;
	bool caseSensitive = false;

	if (words.length && words[0] == "%caseSensitive")
		caseSensitive = true;
	
	if (caseSensitive)
		words = words[1 .. $];
	else
		// fix any tall popies
		foreach(ref word; words)
			word = word.toLower;

	g_forChapter.length = 0;
	foreach(i, book; g_bible.m_books) { // go through books
		foreach(i2, chapter; book.m_chapters) { // go through each chapter of the books
			foreach(i3, ref verse; chapter.m_verses) { // go through each verse of the chapters
				if (verse.m_tagged == false)
					continue;
				bool canFindWords = true;
				string ver;

				if (caseSensitive)
					ver = verse.verse;
				else
					ver = verse.verse.toLower;

				foreach(word; words) { // check to see that all the words are in the verse
					if (! ver.canFind(word)) {
						canFindWords = false;
						break;
					}
				}
				if (canFindWords) {
					bool doit = true;
					foreach(word; words) { // go through each word checking, possibly checking if they are whole words that are found
						size_t p = ver.indexOf(word);
						with(WordSearchType) // for the case's
							final switch(wordSearchType) {
								case wholeWords:
									bool noLeftLetter = (p == 0 || ! lowercase.canFind(ver[p - 1]));
									bool noRightLetter = (p + word.length == ver.length ||
										(p + word.length < ver.length && ! lowercase.canFind(ver[p + word.length])));
									
									if (noLeftLetter && noRightLetter) {
										//doit = true;
										} else doit = false;
								break;
								case wordParts:
									if (p == -1)
										doit = false;
								break;
							} // switch
					} // foreach word
					if (doit) {
						count += 1;
						//mixin(trace("word"));
						result ~= format!"%s) %s %s:%s -> %s\n"
								 	   (count, book.m_bookTitle, chapter.m_chapterTitle, verse.m_verseTitle, verse.verse);
						g_forChapter ~= format!"%s %s"(book.m_bookTitle, chapter.m_chapterTitle);
					} else {
						verse.m_tagged = false;
					}
				} // if canFindWords
				else
					verse.m_tagged = false;
			}
		}
	}
	hits = format!"Hits: %s\n"(count);

	return info ~ hits ~ result ~ info ~ hits;
}

string phraseSearch(string phrase) {
	import std.string, std.algorithm;
	
	string caseSen = "%caseSensitive ";
	bool caseSensitive = false;
	if (phrase.startsWith(caseSen)) {
		phrase = phrase[caseSen.length .. $];
		caseSensitive = true;
	}

	string result;
	int count;
	g_forChapter.length = 0;
	foreach(bi, book; g_bible.m_books) {
		foreach(ci, chapter; book.m_chapters) {
			foreach(di, ref verse; chapter.m_verses) {
				if (verse.m_tagged == false)
					continue;
				auto ver = verse.verse;
				if (! caseSensitive)
					ver = ver.toLower;
				if ((caseSensitive && ver.canFind(phrase)) ||
					(! caseSensitive && ver.canFind(phrase.toLower))) {
					count += 1;
					result ~= format!"%s) %s %s:%s -> %s\n"
						(count, book.m_bookTitle, chapter.m_chapterTitle, verse.m_verseTitle, verse.verse);
					g_forChapter ~= format!"%s %s"(book.m_bookTitle, chapter.m_chapterTitle);
				} else
					verse.m_tagged = false;
			}
		}
	}
	auto info = format!"Phrase: '%s'\nHits: %s\n"(phrase, count);
	result = info ~ '\n' ~ result ~ info;

	return result;
}

string getBibleText() {
	import std.conv;
	string result;
	foreach(i, book; g_bible.m_books) {
		result ~= "\n" ~ text(book.m_bookTitle, "\n");
		foreach(i2, chapter; book.m_chapters) {
			foreach(i3, verse; chapter.m_verses) {
				result ~= format!"chapter %s:%s %s\n"(i2, i3, verse.verse);
			}
		}
	}
	return result;
}

//#go through the whole Bible
//void printWholeBible(alias fun)() {
void printWholeBible() {
	writeln("printWholeBible\n");

	dchar[] block;

	version(all) {
		foreach(i, book; g_bible.m_books) {
	//		writeln("book ", i);
			write("\r", 66-i, ' '); stdout.flush;
			foreach(i2, chapter; book.m_chapters) {
	//			writeln("chapter ", i2);
				foreach(i3, verse; chapter.m_verses) {
					version(MakeABlock)
						block ~= stripAndpack(verse.verse);

					version(Normal) {
						writefln!"verse %s %s"(i3, verse.verse);
					}

					//writeln(stripAndpack(verse.verse));
					//scan( stripAndpack(verse.verse) );
				}
			}
			//goto label1;
		}
		
		version(MakeABlock) {
			write("\r  \r");
		//label1:
			writeln("Saved to 'block.txt'");
			std.file.write("block.txt", block);
			writeln(readText("block.txt"));
		}
	} // version

	version(none) {
		//block = readText("block.txt").to!(dchar[]);
		block = block.to!(dchar[]);

		scan( block );
	}
}

// the prefix 'b' is for book, variable names can't start with a digit.
enum BookId {
	bGenesis = 1,
	bExodus = 2,
	bLeviticus = 3,
	bNumbers = 4,
	bDeuteronomy = 5,
	bJoshua = 6,
	bJudges = 7,
	bRuth = 8,
	b1Samuel = 9,
	b2Samuel = 10,
	b1Kings = 11,
	b2Kings = 12,
	b1Chronicles = 13,
	b2Chronicles = 14,
	bEzra = 15,
	bNehemiah = 16,
	bEsther = 17,
	bJob = 18,
	bPsalms = 19,
	bProverbs = 20,
	bEcclesiastes = 21,
	bSongofSolomon = 22,
	bIsaiah = 23,
	bJeremiah = 24,
	bLamentations = 25,
	bEzekiel = 26,
	bDaniel = 27,
	bHosea = 28,
	bJoel = 29,
	bAmos = 30,
	bObadiah = 31,
	bJonah = 32,
	bMicah = 33,
	bNahum = 34,
	bHabakkuk = 35,
	bZephaniah = 36,
	bHaggai = 37,
	bZechariah = 38,
	bMalachi = 39,
	bMatthew = 40,
	bMark = 41,
	bLuke = 42,
	bJohn = 43,
	bActs = 44,
	bRomans = 45,
	b1Corinthians = 46,
	b2Corinthians = 47,
	bGalatians = 48,
	bEphesians = 49,
	bPhilippians = 50,
	bColossians = 51,
	b1Thessalonians = 52,
	b2Thessalonians = 53,
	b1Timothy = 54,
	b2Timothy = 55,
	bTitus = 56,
	bPhilemon = 57,
	bHebrews = 58,
	bJames = 59,
	b1Peter = 60,
	b2Peter = 61,
	b1John = 62,
	b2John = 63,
	b3John = 64,
	bJude = 65,
	bRevelation = 66}

//#ELS - equal distance letter sequences
dchar[] codeScan(dchar[] text) {

	//'-'.repeat.take(80).writeln;
	//'-'.repeat(80)
	"-".replicate(80).writeln; //#repeat is shorter for this case

	void elsPro(int letterHits, dchar[] word) {
		//mixin(traceLine("letterHits word".split));

		//alias jtoLower = std.uni.toLower;
		//word = word.map!(a => a.jtoLower).to!dstring.dup;
		dchar[] word2 = word.dup;
		foreach(char a; word)
			word2 ~= std.ascii.toLower(a);
		word = word2.to!dstring.dup;

		//writeln(text);

		int beginning;

		void findnth() {
			int start;
			for(; start < text.length && word.length > 0 && letterHits; start++) // find the nth count of the first letter of word
				if (text[start] == word[0])
					letterHits--;

			beginning = start - 1;
			//writeln(text);
		}

		if (beginning < 0)
			return;

		/+
Every 7th letter marking out GOD
         11111111112222222222333333333344444444445555555555666666
12345678901234567890123456789012345678901234567890123456789012345
inthebeginninggodcreatedtheheavenandtheearthandtheearthwaswithout

inthebeG
inninggO
dcreateD

int
rbeGinn
nggOdcr
eatD 

//ESV (Jyble)
//    \./
InthebeG
inningGO
dcreateD
+/	
		findnth();

		//mixin(traceLine("text.length beginning text[beginning]".split));

		//writeln();
		// loop ends when either: success or 
		int pos = beginning, spaces;
		//const len = 1_000; //text.len;
		const len = text.length;
		//write(pos, ' ');

		spaces = 0;
		while(spaces < len / word.length && pos+1 < len &&
			  text[++pos] != word[1]) { // find second letter and the interval
			//mixin(trace("pos"));
			++spaces;
		}
		spaces++;

	if (! spaces < 3) {
		
			//mixin(traceLine("text[beginning..beginning+spaces*word.length]"));

		//mixin(traceLine("pos text[pos] spaces".split));

		bool success = true;
		for(int p, stride = beginning; p < word.length /+ , stride + spaces < text.length +/ ; p++, stride += spaces) {
				//mixin(traceLine("beginning"));
		//mixin(traceLine("beginning", "p", "spaces", "stride", "text[stride]", "word[p]"));
				if (text[stride] != word[p]) {
					success = false;

					break;
				}
			}

		if (success) {
			int targ;
			auto str = ' '.repeat.take(spaces-1).to!(dchar[]);
			for(int n = beginning; n < beginning + word.length * spaces; ++n) {
				if (targ == spaces || n == beginning) {
					targ = 0;
					debug(5) {
						//write('(', text[n], ')');
						writeln(
							(n-spaces+1 >= 0 ? text[n-spaces+1..n] : str),
							'(', text[n], ')',
							text[n+1..n+spaces]);
					}
				}
				//else
				//	write(text[n]);
				targ++;
			}

			debug(5) writeln();
		}
	} // if spaces < 3

	} // ELS

	//elsPro(1, "God"d.dup);

	// loop through Bible verses


	//elsPro(args[0].to!int, args[1].to!(dchar[]));
	version(EndOfBlock)
		text = text[text.length - 1100..$];
	version(all)
		text = "הִתְנַעֲרִי מֵעָפָר קוּמִי שְּׁבִי, יְרוּשָׁלִָם; התפתחו מוֹסְרֵי צַוָּארֵךְ, שְׁבִיָּה בַּת-צִיּוֹןכִּי-כֹה אָמַר יְהוָה, חִנָּם נִמְכַּרְתֶּם; וְלֹא בְכֶסֶף, תִּגָּאֵלוּכִּי כֹה אָמַר אֲדֹנָי יְהוִה, מִצְרַיִם יָרַד-עַמִּי בָרִאשֹׁנָה לָגוּר שָׁם; וְאַשּׁוּר, בְּאֶפֶס עֲשָׁקוֹ".to!(dchar[]);
	import std.algorithm: filter;
	import std.array: array;
	//text = removechars(text.to!(dchar[]), " "d.dup);
	text = text.filter!(a => a != ' ').array;
	writeln(text);

	import std.algorithm: each;

	//int max = 1000; //cast(int)text.length / 3;
	int max = cast(int)text.length / 3;
	iota(1,max)
	//.map!((n) { elsPro(n, g_word); /+ write("\r", n, " of ", max, ' '); +/ return n; } )
	.each!((n) { elsPro(n, g_word); });
	//.array;

	writeln();

	return text;
} // scan
