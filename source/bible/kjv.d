module bible.kjv;

import std.stdio;
import std.ascii;
import std.conv;
import std.string;

import bible.base;

class jkBible {
  kjBook[] bks;
  
  this(string text) {
    string seg;
    // bnpos - book number pos, bksz - book size
	  int p, st, sz;
    int bn; // bn - book number

    p = 1333; // skip infomation
    
    text ~= "\nBook "; // for finding the end of last book

    import std.stdio, std.string;

    // create books, adding headers
    do
    {
      seg = text[p .. $];
      st = cast(int)seg.indexOf("Book ");
      sz = cast(int)seg[st + 1 .. $].indexOf("Book ");
      p += sz + 1;

      bks ~= new kjBook(seg[st .. st + 1 + sz]);

      bn++;
    } while (bn < 66);
  }
  
  void convertToJyble() {
    g_bible = new Bible;
    foreach( kjBook b;bks ) {
      b.header = b.header["book ## ".length .. $];
      if (b.header[1] == ' ')
        b.header = b.header[0] ~ b.header[2 .. $];
      g_bible.m_books ~= new Book(b.header);
      int ci = 1;
      foreach( kjChapter c;b.chps ) {
        g_bible.m_books[$ - 1].m_chapters ~= new Chapter(ci.to!string);
        ci += 1;
        int vi = 1;
        foreach( kjVerse v;c.vrs ) {
          g_bible.m_books[$ - 1].m_chapters[$ - 1].m_verses ~= new Verse(vi.to!string);
          vi += 1;
          g_bible.m_books[$ - 1].m_chapters[$ - 1].m_verses[$ - 1].verse = v.verse;
        }
      }
    }
  }
}

class kjBook
{
  int bkn;
  string header;
  kjChapter[] chps;

  void fixChapter( ref int c )
  {
    while ( (c<0 ? c*-1 : c) > chps.length )
    { c-=(c<0 ? chps.length*-1 : chps.length);
    }

    int n;
    n=c;
    if ( c<0 )
      c=cast(int)chps.length+n+1;
  }

  this( string qtext )
  {
    string text=qtext;
    string seg, hgap;
    int c=1,p,st,chst,chn; // tbst - text body start

    st=cast(int)text.indexOf( "\n" )+1;
    header=text[ 0 .. 8 ];
    for( p=8;text[p]==' ';p++ ) { hgap~=' '; }
    header~=text[ p .. st-2 ];

    if ( isDigit(header[8]) )
    {
		//#how to remove a character in a string?
		header = header[0..9]~header[10..$];
    }

    bkn=to!int( text[ 5 .. 7 ] ); // 6 skips "Book "

    text~="\n000:000  ";
    p=st; // pos after header part
    for( ;! isDigit( text[p] );p++ ) { } // finds 001:001
    st=p; // 1st chapter
    chn=1;

    do
    {
      chst=st;

      do
      {
        p=st+7; // skip over ###:###
        for( ;! isDigit( text[p] );p++ ) { } // find end of verse

        st=p; // next start pos

        c=to!int( text[ st .. st+3 ] );
      } while ( c==chn );

      if ( c!=0 )
      {
        seg=text[ chst .. p ]; // slice
        debug(parsing)
			writefln("seg: [%s]", seg);
        chps~=new kjChapter( seg );
        chn++; // inc to next chapter
      }

    } while ( c != 0 );


    seg=text[ chst .. p ]; // slice
    chps~=new kjChapter( seg );

//    delete text;
  }
  bool InBounds( int chap ) { return ( chap>=1 && chap<=chps.length ); }
  int getBookNum() { return bkn; }
  void Print()
  {
    writefln( "Book %d - '%s'",bkn,header );
  }

  bool headerFind( string f )
  {
    string ss=header[5..$];
    if ( ss.indexOf( f  )!=-1 )
      return true;
    else
      return false;
  }
}

class kjChapter
{
  int chpn;
  kjVerse[] vrs;

  void fixVerse( ref int v )
  {
    while ( (v<0 ? v*-1 : v) > vrs.length )
    { v-=(v<0 ? vrs.length*-1 : vrs.length);
    }

    int n;
    n=v;
    if ( v<0 )
      v=cast(int)vrs.length+n+1;
  }

  int getChapterNum() { return chpn; }

  bool InBounds( int vs ) { return ( vs>=1 && vs<=vrs.length ); }

  this( string text )
  {
		debug(parsing)
		writefln("this(string text): [%s]", text);
	  
    chpn=to!int( text[ 0 .. 3 ] );

	debug(parsing)
		writefln( "Chapter: [%s]", text[ 0 .. 3 ]);

    // create verses
    bool inverse;
    string vrt;
    int vst, vrn; // vst - verse start, chp - chapter number, vrn - verse number
    text~="\n000:000 "; // avoid having to use i==text.length-1
    for(int i=0;;)
    {
		debug(parsing)
			mixin(traceLine("text[i]","i"));
      if ( isDigit( text[i] ) )
      {
        if ( ! inverse )
        {
			immutable v = "text[ i+4 .. i+7 ]";
			debug(parsing)
				writefln("not in verse [%s]", mixin(v));
          vrn=to!int( mixin(v) );
          if ( vrn==0 )
          {
            i=cast(int)text.length;
            break; // break
          }

          i+=7; // skip ###:###
          if ( i >= text.length-1 ) i=cast(int)text.length-2;
          vst=i;
          inverse=true;
        }
        else if ( inverse )
        {
			debug(parsing)
				writefln("in verse [%s]", text[ vst .. i ]);
          vrt=text[ vst .. i ];
          vrs~=new kjVerse( vrn,vrt );
          inverse=false;
        }
      } /* if isDigit */ else {
            i++;
		}
    } // for
  } // this
  void Print()
  {
    writefln( "Chapter %d",chpn );
  }
}

class kjVerse
{
  int vern;
  string verse;

  int getVerseNum() { return vern; }

  this( int vn, string v )
  {
    vern=vn;
    v=strip(v);
    v=replace( v,"\r\n        "," " );
//    v="["~v~"]";

    verse=v;
  }

  void Print()
  {
    writefln( "Verse '%d' '%s'",vern,verse );
  }
}
