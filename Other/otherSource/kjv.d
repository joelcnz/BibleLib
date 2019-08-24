//#usage

//#how to remove a character in a string?
//#helper functions
//#ini
//#contract try
//#drawing not work
//#fstForm
//#rich text
//#working
//#formatVerRef
//#new
//#path
//#save changes
//#load from config file
//#format box
//#dfl LabEtcMan
//#dfl LabEtc
//#get Verse Ref
//#useSystemOp
//#tool tips
//#main
//#doArgs
//#jec init
//#verse
//#DotDraw
//#span

// www.dprogramming.com - DFL

module kjv;

private
{
//	import allegro;
/+
version ( Jec )
{
	import jec.all;
}
version ( usingDfl )
{
  import dfl.all;
  import wildcard.wildcard; // why does this work and ini not?
}

//#ini
import ini.all; // new
//pragma(lib, "ini");
+/

import std.ascii;
import std.file;
//  import std.stream; // not seeming to work at exe'tion
import std.stdio;
import std.random;
import std.string;
import std.process;
import std.c.stdlib;
import std.c.math;
import std.conv;
import std.path;
// import std.recls;
import std.array;

alias std.random rnd;

//   char* pch;
//   string CHT;
public Bible kjv;
  
  enum Frm { book,chapter,verse };
  enum Mgui { vref,phfind,fileName, phfindHits };
  
  string CFG_file=buildPath("BGate","config.ini");
} // private

bool strHasNum( string s )
{
  foreach( char c;s )
    if ( isDigit(c) )
      return true;
  return false;
}

bool strNoOther( string s,string[] sa )
{
  int c;
  foreach( string t;sa )
    if ( t.indexOf(s)==-1 )
      if ( c++>0 )
        return false;
  return true;
}

// find keys and replace them with there counterparts
//                                  int bkt, int cht, int vrt
string[] getFormated( string[] frm,string[] frmKeys,
                      string bkt, int bkn, int chn, int vrn, string vrt )
{  
	string[] t;
	string[] ins;
	ins~=bkt;         // 0
	ins~=to!(string)( chn ); // 1
	ins~=to!(string)( vrn ); // 2
	ins~=vrt;         // 3
//	ins~=to!string( bkn ); // 4 -

	//go thru each format string
  foreach( string f;frm )
  {
    string tm;
    tm=f;
    
//     writefln( " from: [%s]", tm );
    // check for keys, and replace any with counterpart
    foreach( int i,string k;frmKeys )
      if ( f.indexOf( k )!=-1 )
      {
	      tm=replace( tm, k,ins[i] );
      }
//     writefln( "   to: [%s]", tm );
    t~=tm;
  }
  
  return t;
} //

class Bible
{
  Book[] bks;
  
  string[] _frm,
           _frmKeys,
           _mgui;

      //flags
  bool prntChapNums,
      prntVerNums,
      prntVerTxt;
      
  int lstBkn,
      lstChn,
      lstVrn;
      
//#formatVerRef
	string[] formatVerRef( string[] a )
	{
		string[] n;
		n=a;
		
// 		foreach( string s;a )
// 		  replace( n,
		
		return n;
	}
	
//  string
  //bit ;
  void fixBook( ref int b )
  {
    while ( (b<0 ? b*-1 : b) > bks.length )
    { b-=(b<0 ? bks.length*-1 : bks.length);
    }


    int n;
    n=b;
    if ( b<0 )
      b=cast(int)bks.length+n+1;
  }
  
  int getFixChapterNum( int bkn, int c )
  {
	  if ( ! InBounds( bkn ) )
 	    return 1;
	  int r=c;
	  bks[bkn-1].fixChapter( r );
	  return r;
  }
  int getFixVerseNum( int bkn, int chn, int v )
  {
	  if ( ! InBounds( bkn ) )
	    return 1;
	  bkn--;
 	  if ( ! bks[bkn].InBounds( chn ) )
 	    return 1;
	  chn--;
// 	  if ( InBounds( bkn ) || bks[bkn].InBounds( chn )  )
// 	    return 1;
	  int r=v;
	  bks[bkn].chps[chn].fixVerse( r );
	  
	  return r;
  }
/*
  int getBkNumFromHeader( string svar )
  {
    foreach( int bkNum,Book b;bks )
      if ( b.headerFind( svar ) )
        return bkNum;
    return -1;
  }
*/
  
  bool InBounds( int book ) { return ( book>=1 && book<=bks.length ); }

  void ReSetRedun()
  {
    lstBkn=lstChn=lstVrn=-999;
  }

  this( string text )
  {
	  // format
   	_frmKeys~="%BKT%";
		_frmKeys~="%CHN%";
		_frmKeys~="%VRN%";
		_frmKeys~="%VRT%";

		string cfgfile = buildPath("..", "..",CFG_file);
		assert(exists(cfgfile));
		loadIni(cfgfile);
    
    string seg;
    long len=text.length,n;
    // bnpos - book number pos, bksz - book size
	uint p, st, sz;
    int bn; // bn - book number

    p=1333; // skip infomation
    
    
    text~="\nBook "; // for finding the end of last book
    // create books, adding headers
    do
    {
      seg=text[ p .. $ ];
      st=cast(int)seg.indexOf( "Book " );
      sz=cast(int)seg[ st+1 .. $ ].indexOf( "Book " );
      p+=sz+1;

      bks~=new Book( seg[ st .. st+1+sz ] );

      bn++;
    } while ( bn<66 );


//    delete text;
  }
  
//#load from config file
	void loadIni( string cfile )
	{
		_frm.length=0;
			
		Ini ini;
	
		ini=new Ini( cfile );
		string section;
		
		section="format";
		_frm~=ini[section]["book"];
		_frm~=ini[section]["chapter"];
		_frm~=ini[section]["verse"];
		
		section="main_gui";
		_mgui~=ini[section]["vref"]; //_mgui[ vref ]
		_mgui~=ini[section]["phfind"];
		_mgui~=ini[section]["filename"];
		_mgui~=ini[section]["phfindHits"];
		
		foreach( ref f;_frm )
		  f=replace( f,"@nl@","\n" );
		  
		  delete ini;
	}
	
	void setMguiTxt( string[] mgui )
	{
		_mgui=mgui;
	}
	
//#contract try
	void setMguiTxt( int index,string mgui )
//{
		in
		{
			assert( index>=0 && index<_mgui.length );
		}
		body
		{
			_mgui[index]=mgui;
		}
//		if ( index>=0 && index<_mgui.length )
//		{
//			_mgui[index]=mgui;
//		}
//	}
	
	string getMguiTxt( int key )
	{
		if ( key>=0 && key<_mgui.length )
		  return _mgui[key];
		  
		 assert(0);
	}
		
			
//#save changes
	void saveIni( string cfile )
	{
		Ini ini;
	
		ini=new Ini( cfile );
		string section;
		string[] frm;
		frm=_frm;
		section="format";
		foreach( ref f;frm )
		  f=replace( f,"\n", "@nl@" );
		  
		ini[section]["book"]=frm[0];
		ini[section]["chapter"]=frm[1];
		ini[section]["verse"]=frm[2];
		
		ini.save();
		
		delete ini;
	}
	
  string getAll()
  {
    string t;
    int qb,qc;
    foreach( Book b;bks )
      foreach( Chapter c;b.chps )
        foreach( Verse v;c.vrs )
        {
          if ( qb!=b.getBookNum )
            t~="\n{"~b.header~"}\n";
          if ( qc!=c.getChapterNum )
            t~="\nChapter "~to!string( c.getChapterNum )~"\n";
          t~=to!string( v.getVerseNum )~" "~v.verse~"\n";
          qc=c.getChapterNum;
          qb=b.getBookNum;
        }
    return t;
  }
  
  int getBookNumFrmHeaderTx( string fh )
  {
	  foreach( int bn,Book b;bks )
	    if ( b.headerFind( fh ) )
  	    return bn+1;
    return -1;
  }
  string getBookHeaderTxFrmNu( int n )
  {
	  n--;
	  if ( ! InBounds( n ) )
	    return bks[ n ].header;
	  else
	    return "No book no."~to!string( n+1 );
  }
  string getBookHeaderTxFrmTx( string fh )
  {
	  foreach( Book b;bks )
	    if ( b.headerFind( fh ) )
  	    return b.header;
	  else
	    return `Header txt not found - "`~fh~`"`;
	assert(0);
  }
  
  string _getVerseFrmRef( int book,int chapter,int verse )
  {
	  string t;
//	  t~=
     return "";
  }

//#get Verse Ref  
  string getVerseFrmRef( int book,int chapter,int verse )
  {
    string t;

    if ( ! InBounds( book ) && book>0 ) return "";
    fixBook( book );
    if ( ! bks[book-1].InBounds( chapter ) && chapter>0 ) return "";
    bks[book-1].fixChapter( chapter ); // new 5 / 3 / 05
    if ( ! bks[book-1].chps[ chapter-1 ].InBounds( verse ) && verse>0 ) return "";
    bks[book-1].chps[ chapter-1 ].fixVerse( verse );

/*

The Book of %
%
 %
     
*/
    string[] frmd=getFormated( _frm,_frmKeys,
                             bks[book-1].header[ 8 ..$ ],
                             book, chapter, verse, // ref numbers
                             bks[book-1].chps[ chapter-1 ].vrs[ verse-1 ].verse );
    if ( book!=lstBkn )
      t=frmd[ Frm.book ];
    if ( chapter!=lstChn )
      t~=frmd[ Frm.chapter ];
    t~=frmd[ Frm.verse ];
//    string[] frm=_frm;
    
//enum Frm {};
/+
    if ( book!=lstBkn )
      t=frm[0]~bks[book-1].header[ 8 ..$ ]~frm[1];
    if ( chapter!=lstChn )
      t~=frm[2]~to!string( chapter )~frm[3];
    t~=frm[4]~to!string( bks[book-1].chps[ chapter-1 ].vrs[ verse-1 ].getVerseNum )~frm[5];
    t~=frm[6]~bks[book-1].chps[ chapter-1 ].vrs[ verse-1 ].verse~frm[7];
+/
    
//     if ( book!=lstBkn )
//       t="\nThe Book of "~bks[book-1].header[ 8 ..$ ]~"\n";
//     if ( chapter!=lstChn )
//       t~="\nChapter "~to!string( chapter )~"\n";
//     t~=to!string( bks[book-1].chps[ chapter-1 ].vrs[ verse-1 ].getVerseNum );
//     t~=" "~bks[book-1].chps[ chapter-1 ].vrs[ verse-1 ].verse~"\n";
    
    lstBkn=book;
    lstChn=chapter;
    lstVrn=verse;
    
    return t;
  }
  int getBookNum( string r )
  {
    int bkn;
    
    

    return bkn;
  }

  bool strNoOther( string s )
  {
    int c;
    foreach( Book b;bks )
      if ( b.headerFind(s) )
        if ( c++>0 )
          return false;
    return true;
  }
}

class Book
{
  int bkn;
  string header;
  Chapter[] chps;

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
        chps~=new Chapter( seg );
        chn++; // inc to next chapter
      }

    } while ( c != 0 );


    seg=text[ chst .. p ]; // slice
    chps~=new Chapter( seg );

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

class Chapter
{
  int chpn;
  Verse[] vrs;

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
          vrs~=new Verse( vrn,vrt );
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

class Verse
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

//#main
int mainq( string[] args )
{
  kjv=new Bible( cast(string)read( `kjvtext.txt` ) );

	debug(parsing)
		writeln("Got passed new Bible!");

  string t;
  t=doArgs( args );

version ( usingDfl )
{
	int result = 0;
	
	try
	{
		Application.run(new fstForm( args ) );
	}
	catch(Object o)
	{
		msgBox(o.toString(), "Fatal Error", MsgBoxButtons.OK, MsgBoxIcon.ERROR);
		
		result = 1;
	}
	
	kjv.saveIni( CFG_file );
	
	return result;
}
  if ( t )
  {
version ( Jec )
{
//#jec init
	Init( args );
	

	DeInit();	
}
else
{
//#useSystemOp
	version( useSystemOp )
	{
    string op;
    op="notepad "~ofile;
    system( "pause" );
    system( op );
  }
}
  }
/*
  do
  {

  } while ( ! keypressed() );
*/

//   DeInit();

  return 0;
}

//#doArgs
string doArgs( string[] args )
{
  int c=cast(int)args.length;
version ( usingDfl )
{} else
{
  if ( c==1 )
  {
//#usage
    writefln( "Usage: examples\n"
//             12345678901234567890123456789012345678901234567890123456789012345678901234567890..
              "\n"
              "'bgt forBcv: -1 -1' ----------------- List every last verse in each book\n"
              "                                      (without the quotes)\n"
              "'bgt verse: Joh 3 16' --------------- List verses found in John and 1 John\n"
              "X-not yet -> 'bgt verse: Joh 2-3 16-17' ---------- List more verses\n"
              "'bgt verse: \"1 Joh\" 3 16' ----------- List verse found in just 1 John\n"
              "'bgt find: \"Lord God\" --------------- does a phrase search (lists verses\n"
              "                                      containing phrase)\n"
              "'bgt find: forever until' ----------- lists verses containing either or words\n"
              "                                      in them\n"
              "'bgt bookfind: G' ------------------- will list headers for Genesis Galatians\n"
              "'bgt book: bookfind: G' -------------- will list the whole books of Genesis and\n"
              "                                      Galatians\n"
              "'bgt file: fnd1 find: \"Lord God\"' --- writes output to 'fnd1.txt' file (instead\n"
              "                                      of 'gleaned.txt')\n"
              "'bgt append: find: \"Lord God\"' ------- writes output onto the end of\n"
              "                                      'gleaned.txt', instead of resetting it\n"
              "\n"
              "Note: Output is stored in 'gleaned.txt' text file (unless the parameter 'file:'\n"
              "      is used )"
              );

    return "quit";
  }
}

  static bool doAppend=false,stats=false;
  static string t,ofile="gleaned.txt";
  int hits;
  
  t.length=0;
  
with ( kjv )
{
  // flags
  bool book,chapter;
  if ( c>1 )
    foreach(ref int i,string a;args )
    {
      switch ( a )
      {
        case "file:":
          if ( i+1<c )
          {
            ofile=args[++i]; // set new file name, and increment to next arg
            if ( ofile.indexOf( "." )==-1 )
              ofile~=".txt";
          }
        break;
        case "append:":
          doAppend=true;
        break;
        case "stats:":
          stats=true;
        break;
        case "chapter:":
          chapter=true;
        break;
        case "book:":
          book=true;
        break;
        case "listHeaders:":
          for( int b=1;b<=66;b++ )
          {
            writefln( "Header no. %d - `%s`", b,bks[b-1].header[0..$] );
          }
        break;
//#verse
        case "verse:":
          if ( i+3<c )
          {
	          string[] ags;
	          ags=formatVerRef( args[i..$] );
	          ags=args;
	          
            hits=0;
            
            string theader,tbook,tchapter,tverse;
            string theader2,tbook2,tchapter2,tverse2;
            theader=ags[i+1];

            int bk; // book number
            int ch,chl; // chapter no. and no. of chaps
            int vr,vrl; // verse no. and no. of verses
            int p;
            
            int bk2,ch2,vr2;

            bool span=false; // eg Joh 3 16 - Joh 4 8

            /*
            Probs:
            eg. "1 Joh" "Joh"
            */
            /*
            1. egs 'Joh 1-3 5-8' / 'Joh 5 8' / 'Joh 5 8-10' / 'Joh 5-6 1'
            2. egs 'Gen 1 1 - Rev -1 -1' // span true
            */

            debug ( verseRef )
              writefln( `------------------------------` );

            // Book Num (1)
            bk=getBookNumFrmHeaderTx( ags[i+1] );
            
            debug ( verseRef )
                writefln( `(1): Book: '%s' BookNum: %d`, theader,bk );
            
            // Chapter (1) and 
            ch=getFixChapterNum( bk,to!int( ags[i+2] ) );
            chl=ch;
            
            debug ( verseRef )
              writefln( `(1): Book: '%s' BookNum: %d, Chap: %d`, theader,bk,ch );

            // Verse Num (1) and
            vr=getFixVerseNum( bk,ch,to!int( ags[i+3] ) );
            vrl=vr;
            
            debug ( verseRef )
              writefln( `(1): Book: '%s' BookNum: %d, Chap: %d, Ver: %d`, theader,bk,ch,vr );
            
            if ( i+5<c && ags[i+4]=="-" )
            {
	            int o;
	            o=i;
              span=true;
//#working
              if ( ! strHasNum( ags[i+5] ) )
              {
                // Psa -1 1 - Pro 2 4
                theader2=ags[o+5];
              }
              else
              {
                // eg Psa 1 1 - 4    : 4 verses
                //* or Psa 1 1 - 2 3  : from ch 1 vr 1 to ch 2 vr 3
                theader2=theader;
                o--;
              }
             
              bk2=getBookNumFrmHeaderTx( theader2 );
              
              debug ( verseRef )
                writefln( `(2): Book: '%s' BookNum: %d,`, theader2,bk2 );
              // Psa -1 1 - Pro 2 4
              // eg Psa 1 1 - 4    : 4 verses
              //* or Psa 1 1 - 2 3  : from ch 1 vr 1 to ch 2 vr 3
              if ( i+7<c )
              {
                // Psa -1 1 - Pro 2 4
                //* or Psa 1 1 - 2 3  : from ch 1 vr 1 to ch 2 vr 3
                ch2=getFixChapterNum( bk2,to!int( ags[o+6] ) );
              }
              else
              {
                // eg Psa 1 1 - 4    : 4 verses
                ch2=ch;
                o--;
              }
              debug ( verseRef )
                writefln( `(2): Book: '%s' BookNum: %d, Chap: %d`, theader2,bk2,ch2 );
              vr2=getFixVerseNum( bk2,ch2,to!int( ags[o+7] ) );
              debug ( verseRef )
                writefln( `(2): Book: '%s' BookNum: %d, Chap: %d, Ver: %d`, theader2,bk2,ch2,vr2 );
            }
//#span
            if ( span )
            {
              for( int bn=bk;bn<=bk2;bn++ )
              {
                int chs,vrs, // suffix 's' = start number
                    chln,vrln; // suffix 'ln' = length number
                if ( bn==bk )
                  chs=ch;
                else
                  chs=1;
                if ( bn==bk2 )
                  chln=ch2;
                else
                  chln=150;
                for( c=chs;c<=chln;c++ )
                {
	                if ( c==chs )
	                  vrs=vr;
	                else
	                  vrs=1;
	                if ( c==ch2 )
	                  vrln=vr2;
	                else
	                  vrln=300;
                  for( int v=vrs;v<=vrln;v++ )
                  {
                    int w=cast(int)t.length;
                    t~=getVerseFrmRef( bn, c,v );
                     if ( t.length==w )
                       break;
                      hits++;
                  } // for v
                } // for c1
              } // for book num
            } // if span
            else if ( book )
            {
              for( c=1;c<=150;c++ )
                for( int v=1;v<=300;v++ )
                  t~=getVerseFrmRef( bk,c,v );
            }
            else if ( chapter )
            {
              for( int v=1;v<=300;v++ )
                t~=getVerseFrmRef( bk,ch,vr );
            }
            else
              t~=getVerseFrmRef( bk, ch,vr );
            if ( stats )
              t~="\n# Verse ref '"~ags[i+1]~" "~ags[i+2]~":"~ags[i+3]~`' - '`
                ~ags[i+5]~" "~ags[i+6]~":"~ags[i+7]~"' Verse Count "~to!string( hits )~"\n\n";
          }
          ReSetRedun();
        break;
        case "allbcv:":
          for( int b=1;b<=66;b++ )
            for( c=1;c<=150;c++ )
              for( int v=1;v<=300;v++ )
                t~=getVerseFrmRef( b,c,v );
          if ( stats )
            t~="\n# All the Bible\n\n";
        break;
       case "forBcv:":
         if ( i+2<c )
          for( int b=1;b<=66;b++ )
          {
            t~=getVerseFrmRef( b,to!int( args[i+1] ), to!int( args[ i+2 ] ) );
          }
       break;
         case "all:":
          if ( book )
            t~=getAll();
        break;
        case "find:":
          if ( i+1<c )
          {
            foreach( string f;args[ i+1 .. $ ] )
              if ( f.indexOf( ":" )==-1 )
              {
                hits=0;
                foreach( Book b;bks )
                  foreach( Chapter ch;b.chps )
                    foreach( Verse v;ch.vrs )
                      if ( v.verse.indexOf( f )!=-1 )
                      {
//                           if ( book )
//                             for( int c;c<=150;c++ )
//                               for( int v=1;v<=300;v++ )
//                                 t~=getVerseFrmRef( b.bkn,c,v );
//                           else
                        int w=cast(int)t.length;
                        t~=getVerseFrmRef( b.getBookNum,ch.getChapterNum,v.getVerseNum );
                        if ( t.length>w )
                          hits++;
                      }
                 if ( stats )
                   t~="\n# find Hits for '"~f~"' "~to!string( hits )~"\n\n";
                 kjv.setMguiTxt( Mgui.phfindHits, "Hits: "~to!string( hits ) );
              }
              else
                break;
            }
          ReSetRedun();
        break;
        case "bookfind:":
          if ( i+1<c )
          {
            hits=0;
            foreach( string f;args[ i+1 .. $ ] )
              if ( f.indexOf( ":" )==-1)
              {
                foreach( Book b;bks )
                  if ( b.headerFind( f ) )
                  {
                    if ( book )
                      for( c=1;c<=150;c++ )
                        for( int v=1;v<=300;v++ )
                          t~=getVerseFrmRef( b.bkn,c,v );
                    else
                      t~=b.header~"\n";
                    int w=cast(int)t.length;
                    if ( t.length>w )
                      hits++;

                  }
              }
              else
                break;
            if ( stats )
              t~="\n# No. Books "~to!string( hits )~"\n\n";
          }
        break;
        default:
        break;
      } // switch
    } // foreach
  ReSetRedun();
} // with kjv
// version ( usingDfl )
// {} else
{
  t=replace( t,"\n","\r\n" ); // for notepad and stuff
  if ( ! doAppend )
    std.file.write( ofile,cast(string)t );
  else
    append( ofile,cast(string)t );
}
  return t;
} // doArgs

version ( usingDfl )
{
//#dfl LabEtc
class LabEtc
{
	fstForm fform;
	ToolTip toolTip;
	Label label;
	TextBox textbox;
	Button button;
	void delegate(Object sender, EventArgs ea) do_Button;
	
	/+
	void do_apply(Object sender, EventArgs ea)
	{
		..
		writefln( "applied" );
	}
	eg. new LabEtc( ..
	                  ..
	                  ..
	                  "Apply",&do_apply );
	+/
	
	// label text, pos and dimentions
	// textbox text, pos and dimentions
	// button text, & delegate
	this( fstForm frm,
	      string ltext, int lx,int ly,int lw,int lh,
	      string ttext, int tx,int ty,int tw,int th,
	      string btext, void delegate(Object sender, EventArgs ea) bFunction )
	{
		fform=frm;
		if ( btext.length )
			with ( button = new Button )
			{
			  if ( bFunction )
			  {
			    do_Button=bFunction;
			    button.click~=do_Button;
		    }
		  }
	}
	
	/*
	new LabEtc(frm,"Enter &Verse Ref:",Rect(4,8,toEdBox,20),
	               kjv.getMguiTxt( Mgui.vref ),Rect( lEnterRef.right, lEnterRef.top-2, 150, 20 ),
	               "Crank &Ref(s)",Point( tEnterRef.right+4,tEnterRef.top-2 ),&this.do_SetRefs );
								 
	
		with( lEnterRef = new Label )
		{
			text="Enter &Verse Ref:";
			bounds = Rect( 4,8, toEdBox, 20 );
			parent=this;
		}
		// Add a TextBox
		with(tEnterRef = new TextBox)
		{
			text=kjv.getMguiTxt( Mgui.vref );
//			"Gen -1 -5 - Ex 2 14";
			bounds = Rect( lEnterRef.right, lEnterRef.top-2, 150, 20 );
			multiline = false;
			acceptsReturn = false;
			parent = this;
		}
		with( bSetRef = new Button )
		{
			location = Point( tEnterRef.right+4,tEnterRef.top-2 );
			text="Crank &Ref(s)";
			parent = this;
			
			click ~= &this.do_SetRefs;
		}
	*/
}

//#dfl LabEtcMan
class LabEtcMan
{
	void Add() { }
}

//#fstForm
class fstForm: Form
{
	string _fileName,_rootPath,_docPath,_formatPath;
	
	// LabEtc[] labes;
	// Set tooltips.
	ToolTip tt;
	
	Label lEnterRef
	      ,lFind
	      ,lBigBox
	      ,lBigBox2
	      
        ,lFormatBox
        
	      ,lSave
	      ,lLoad
	      ;
  TextBox tEnterRef
          ,tFind
          ,tBigBox
          ,tBigBox2
          
          ,tFormatBox
          
          ,tSave
          ,tLoad
          ,tHits
          ;
  //#work around
  Button bSetRef
         ,bSetFnd
         
         ,bClearBigBox
         
         ,bFormatBox
         
         ,bSave
         ,bLoad
         
         ,bAppend
         
         ,bFolderL
         ,bFolderS
         ;
  int toEdBox
      ,hits
      ,refHits
      ,phFndHits;

	RichTextBox rtb;
  
	this( string[] args )
	{
		_rootPath=Application.startupPath;
		_docPath=Application.startupPath;
		_docPath~=`doc`;
		
		CFG_file=_buildPath(_rootPath,`\`,CFG_file);
		
    toEdBox=15*8;

		MainMenu mm;
		MenuItem mpop, mi;
		
		mm = new MainMenu;

		with(mpop = new MenuItem)
		{
			text = "F&ile";
			index = 0;
			mm.menuItems.add(mpop);
		}
		
		with(mi = new MenuItem)
		{
			text = "&Open Man";
			index = 0;
			click ~= &fileOpen;
			mpop.menuItems.add(mi);
		}
		
		with(mi = new MenuItem)
		{
			text = "&Save Man As.."; //\tCtrl+S";
			index = 1;
			click ~= &this.fileSave;
			mpop.menuItems.add(mi);
		}
		
		
		with(mi = new MenuItem)
		{
			text = "-";
			index = 2;
			mpop.menuItems.add(mi);
		}
		
		with(mi = new MenuItem)
		{
			text = "E&xit\tEsc";
			index = 3;
			click ~= &clickExit;
			mpop.menuItems.add(mi);
		}
		
		with(mpop = new MenuItem)
		{
			text = "&Test";
			index = 1;
			mm.menuItems.add(mpop);
		}
		
		with(mi = new MenuItem)
		{
			text = "&Nothing doing\tCtrl+N";
			index = 0;
//			click ~= &editUndo;
			mpop.menuItems.add(mi);
		}
		menu=mm;
		
		
//#]]]]]]]]]]]]]]]]]]]]]]]
		
		with( lEnterRef = new Label )
		{
			text="Enter &Verse Ref:";
			bounds = Rect( 4,8, toEdBox, 20 );
			parent=this;
		}
		// Add a TextBox
		with(tEnterRef = new TextBox)
		{
			text=kjv.getMguiTxt( Mgui.vref );
//			"Gen -1 -5 - Ex 2 14";
			bounds = Rect( lEnterRef.right, lEnterRef.top-2, 150, 20 );
			multiline = false;
			acceptsReturn = false;
			parent = this;
		}
		with( bSetRef = new Button )
		{
			location = Point( tEnterRef.right+4,tEnterRef.top-2 );
			text="Crank &Ref(s)";
			parent = this;
			
			click ~= &this.do_SetRefs;
		}
		
		with( lFind = new Label )
		{
			text="Enter Find &Phrase:";
			bounds = Rect( 4,lEnterRef.bottom+4, toEdBox, 20 );
			parent = this;
		}
		with( tFind = new TextBox )
		{
			text=kjv.getMguiTxt( Mgui.phfind );
			bounds = Rect( lFind.right, lFind.top-2, 150, 20 );
			multiline = false;
			acceptsReturn = false;
			parent = this;
		}
		with( bSetFnd = new Button )
		{
			location = Point( tFind.right+4,tFind.top-2 );
			text="Crank &Find";
			parent = this;
			
			click ~= &this.do_SetFnd;
		}

		with( tHits = new TextBox )
		{
			text=kjv.getMguiTxt( Mgui.phfindHits );
			bounds = Rect( bSetFnd.right+4, bSetFnd.top, 60, 20 );
			multiline = false;
			acceptsReturn = false;
			readOnly=true;
			parent = this;
		}
		
		with( lBigBox = new Label )
		{
			text="&Auto Box:";
			bounds = Rect( 4,lFind.bottom + 4, toEdBox, 14 );
			parent = this;
		}
		
		// Add a TextBox below the GroupBox.
		with( tBigBox = new TextBox)
		{
			bounds = Rect(4, lBigBox.bottom, 200, 300);
			multiline = true;
			scrollBars = ScrollBars.BOTH;
			readOnly=true;
			parent = this;
		}
		
		with( lBigBox2 = new Label )
		{
			text="&Manual Box:";
			bounds = Rect( 4+tBigBox.right+10,lFind.bottom + 4, toEdBox, 14 );
			
			parent = this;
		}
		with( tBigBox2 = new TextBox)
		{
 			tBigBox2.text=cast(string)read( kjv.getMguiTxt( Mgui.fileName ) );
			
			bounds = Rect( 4+tBigBox.right+10, tBigBox.top, 200, 300);
			multiline = true;
			scrollBars = ScrollBars.BOTH;
			
			acceptsReturn = true;
		
			parent = this;
		}
//#format box
		with( lFormatBox = new Label )
		{
			text="Forma&t:";
			bounds = Rect( 4+tBigBox2.right+10,lBigBox2.top, toEdBox, 14 );
			
			parent = this;
		}
		with( tFormatBox = new TextBox )
		{
			with ( kjv )
			{
				string tx;
				foreach( string seg;_frm )
				{
//writefln( "_frm#=`%s`",seg );
				  tx~=seg~"|\n";
			  }
			  
        tx=replace( tx,"\n","\r\n" );
    	  text=tx;
			}
			bounds = Rect( 4+lFormatBox.left, lFormatBox.bottom+4, 200, 200);
			multiline = true;
			scrollBars = ScrollBars.BOTH;
			
			acceptsReturn = true;
		
			parent = this;
		}
		
		with( bFormatBox = new Button )
		{
			location = Point( tFormatBox.left+4,tFormatBox.bottom+4 );
			text="S&et Format";
			parent = this;
			
			click ~= &this.setFormat;
		}
		
		with( bFolderL = new Button )
		{
			bounds = Rect( tBigBox2.left,tBigBox.bottom+4, cast(int)(toEdBox/3), 20 );
			text="&Load";
			parent = this;
			
			click ~= &this.fileOpen;
		}
		
		with( bSave = new Button )
		{
			bounds = Rect( bFolderL.right+4,bFolderL.top, cast(int)(toEdBox/3), 20 );
			text="&Save";
			parent = this;
			
			click ~=&this.fileSave;
		}
		
		with( bClearBigBox = new Button )
		{
			location = Point( 4,tBigBox.bottom+4 );
			text=`&Clear above`;
			parent = this;
			
			click ~= &this.do_ClearBox;
		}
		
		with( bAppend = new Button )
		{
			location = Point( bClearBigBox.right+20,bClearBigBox.top );
			text=`Appen&d - Man`;
			parent = this;
			
			click ~= &this.do_AppendMan;
		}

   	addShortcut( Keys.ESCAPE, &shortcut_Quit);
//    	addShortcut( Keys.A, &shortcut_SelectAllBtxt );
    addShortcut( Keys.CONTROL | Keys.S, &shortcutSave );
   	addShortcut( Keys.CONTROL | Keys.R, &shortcutRich);

    
//#tool tips
		with( tt = new ToolTip )
		{
			setToolTip( lEnterRef, `Eg. 'Press 1) Alt+V  2) (this format) 'Gen 1 1', 'Gen 1 1 - 3', or 'Mal -2 -5 - Matt 3 8' 3) Alt+R` );
//			setToolTip( lFind,`` );
      setToolTip( bClearBigBox,"Clears collector box (above)" );
//      setToolTip( bSave,"Note: No warnings." );
      setToolTip( bSave,`Ctrl+S - for quick save`);
		}

  	_fileName=kjv.getMguiTxt( Mgui.fileName );
		setTitle( _fileName );
    width = tFormatBox.right+20+4; //tBigBox2.right+10+4;
    //height = bClearBigBox.bottom+26+4;
    height = bClearBigBox.bottom+44+4+ 16;
    
 		// Set default button.
//		acceptButton = bSetRef;

		//#work around
//#		addShortcut( Keys.ALT | Keys.R, &shortcutCrankVerse );
//#		addShortcut( Keys.ALT | Keys.F, &shortcutCrankFind );

		backColor = Color(205, 205, 205);
	} // this

//#	void shortcutCrankVerse(Object sender, FormShortcutEventArgs ea)
//#	{ bSetRef.performClick();	}
	
//#	void shortcutCrankFind(Object sender, FormShortcutEventArgs ea)
//#	{ bSetFnd.performClick();	}
	
//#rich text
  void shortcutRich(Object sender, FormShortcutEventArgs ea)
  {
  	Form f;

		with(f = new Form)
		{
			text = "RichTextBox";
		}
		with(rtb = new RichTextBox)
		{
			text = tBigBox.text;
			dock = DockStyle.FILL;
			font = new Font("Tahoma", cast(float)12, FontStyle.BOLD);
			backColor = Color(0xD3, 0xDB, 0xD3);
			foreColor = Color(0, 0, 0);
		}
		rtb.parent = f;
		
		Application.run(f);
  }
	
	void setTitle( string title )
	{
		text="Bible Gate Program - "~title;
	}

	private
	{
		void setFormat(Object sender, EventArgs ea)
		{
			with ( tFormatBox )
			{
				string[] frm;
				string tx;
				tx=text;
        tx=replace( tx,"\r\n","\n" );
				frm.length=3;
				frm=split( tx,"|\n" );
				with ( kjv )
				{
					_frm=frm;
				}
			}
		}
		
// 		void shortcut_SelectAllBtxt(Object sender, FormShortcutEventArgs ea)
// 		{
// 		  bigBox.selectAll();
// 	  }
		void fileOpen(Object sender, EventArgs ea)
		{
// Application.startupPath   'f:/prog/dpro/bgate
			OpenFileDialog ofd;
			ofd = new OpenFileDialog;
			ofd.filter = "Text Documents (*.txt)|*.txt|All Files|*.*";
			ofd.defaultExt = "txt";
			ofd.fileName=_fileName;
			if(DialogResult.OK == ofd.showDialog())
			{
				tBigBox2.text=cast(string)read( ofd.fileName );
				kjv.setMguiTxt( Mgui.fileName,_fileName=ofd.fileName );
				setTitle( _fileName );
			}
		}
		void fileSave(Object sender, EventArgs ea)
		{
			SaveFileDialog sfd;
			sfd = new SaveFileDialog;
			sfd.filter = "Text Documents (*.txt)|*.txt|All Files|*.*";
			sfd.defaultExt = "txt";
//#path
			sfd.initialDirectory( _docPath );
			sfd.fileName=_fileName;
			if(DialogResult.OK == sfd.showDialog())
			{
        std.file.write( sfd.fileName, cast(string)tBigBox2.text );
        kjv.setMguiTxt( Mgui.fileName,_fileName=sfd.fileName );
//        _fileName=sfd.fileName;
        setTitle( _fileName );
			}
			sfd.initialDirectory( _rootPath );
	  }

    void do_AppendMan(Object sender, EventArgs ea)
    {
	    tBigBox2.text=tBigBox2.text~tBigBox.text;
    }
    
    void shortcutSave(Object sender, FormShortcutEventArgs ea)
    {
			if( exists( _fileName ) &&
			    DialogResult.YES != msgBox( "Replace\n\'"~
			                                _fileName~
			                                "\'\nfile?",
				"Ctrl+S - Check Point..", MsgBoxButtons.YES_NO, MsgBoxIcon.QUESTION))
			{
				return; // Abort.
			}
			else
			{
        std.file.write( _fileName, cast(string)tBigBox2.text );
      }
    }
    
    void clickExit(Object sender, EventArgs ea)
    {
	    doExit();
    }
    void doExit()
    {
	    writefln( CFG_file );
			Ini ini=new Ini( CFG_file );
			writefln( "FileName: ",_fileName );
			
			string section;
			section="main_gui";
			ini[section]["vref"]=tEnterRef.text;
			ini[section]["phfind"]=tFind.text;
			ini[section]["filename"]=_fileName;
			
			ini.save();
			
			delete ini;
			
			Application.exitThread();
    }
    
		void shortcut_Quit(Object sender, FormShortcutEventArgs ea)
		{
			doExit();
		}	
		
		void do_SetRefs(Object sender, EventArgs ea)
		{
			string[] args;
			
			args~="dummy";
			args~="verse:";
			args~=split( tEnterRef.text," " );
// 			writefln( "tEnterRef.text-`",tEnterRef.text,"` ","args[1]-`",args[1],"`" );
      string t;
      t~=tBigBox.text~doArgs( args );
			tBigBox.text=t;
		}
		
		void do_SetFnd(Object sender, EventArgs ea)
		{
			if ( ! tFind.text )
			  return;
			string[] args;
			
			args~="dummy";
			args~="find:";
			args~=tFind.text;
			//args~=split( tEnterRef.text," " );
//			writefln( "tEnterRef.text-`",tEnterRef.text,"` ","args[1]-`",args[1],"`" );
      string t;
      t~=tBigBox.text~doArgs( args );
			tBigBox.text=t;
			tHits.text=kjv.getMguiTxt( Mgui.phfindHits );
		}
		void do_ClearBox(Object sender, EventArgs ea)
		{
			tBigBox.text="";
		}
	}
	
	//#drawing not work
	protected override void onPaint(PaintEventArgs ea)
	{
		super.onPaint(ea);

		/*		
		auto Pen p1 = new Pen(Color(255, 255, 255));
		ea.graphics.drawLine(p1, 0, 0, 800, 0 );
		auto Pen p2 = new Pen(Color(180, 180, 180));
		ea.graphics.drawLine(p2, 0, 1, 800, 1 );
		*/
//		ea.graphics.drawLine(); // Color(255, 255, 255),new Point(0,0),new Point(800,0)); // 0, 0, 800, 0 );
//		ea.graphics.drawLine(Color(180, 180, 180),); // 0, 1, 800, 1 );
	}
} // fstform
} // using DFL
