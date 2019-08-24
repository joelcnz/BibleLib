//#drag drop
//#verse:
		with( lSave = new Label )
		{
			text="&Save Above Text:";
			bounds = Rect( tBigBox2.left,tBigBox.bottom+4, toEdBox, 20 );
			parent=this;
		}
		// Add a TextBox
		with(tSave = new TextBox)
		{
			text="untitled";
			bounds = Rect( 4+lSave.right, lSave.top-4, 150, 20 );
			multiline = false;
			acceptsReturn = false;
			parent = this;
		}
		with( bSave = new Button )
		{
			location = Point( tSave.right+4,tSave.top-4 );
			text="Save &It";
			parent = this;
			
			click ~= &this.do_Save;
		}
		
//#load text
		with( lLoad = new Label )
		{
			text="Load to Above Te&xt:";
			bounds = Rect( lSave.left,tSave.bottom+4, toEdBox, 20 );
			parent=this;
		}
		
		// Add a TextBox
		with(tLoad = new TextBox)
		{
			text=""; // =notesFile
			bounds = Rect( 4+lLoad.right, lLoad.top-4, 150, 20 );
			multiline = false;
			acceptsReturn = false;
			parent = this;
		}
		with( bLoad = new Button )
		{
			location = Point( tLoad.right+4,tLoad.top-4 );
			text="&Load It";
			parent = this;
			
			click ~= &this.do_Load;
		}
		
				tLoad.text=replace( ofd.fileName, Application.startupPath~`\`, "" );

    void do_Load(Object sender, EventArgs ea)
    {
	    with ( tLoad )
	    {
		    int p;
		    if ( (p=rfind( text,"." ))==-1 )
		      text=text~".txt";
	      if ( ! exists( text ) )
	        return;
	      tBigBox2.text=cast(char[])read( text );
      }
    }

    void do_Save(Object sender, EventArgs ea)
    {
	    with ( tSave )
	    {
		    int p;
		    if ( (p=rfind( text,"." ))==-1 )
		      text=text~".txt";
	      if ( text.length!=0 && tBigBox2.text.length!=0 )
	        write( text, cast(char[])tBigBox2.text );
      }
    }

	_frm~="The Book of "~_frmKeys[0]~"\n\n";
	_frm~="Chapter "~_frmKeys[1]~"\n";
	_frm~=_frmKeys[2]~" "~_frmKeys[3]~"\n";
		
  char[] to;
  switch( k )
  {
    case 0: // Book text (title)
      to=bkt;
    break;
    case 1: // chapter number
      to=atos( chn );
    break;
    case 2: // verse_number
      to=atos( vrn );
    break;
    case 3: // verse text
      to=vrt;
    break;
    case 4: // book number
      to=atos( bkn );
    break;
  }
	      
/*
writefln( "got here" );


%BOOK_NAME%
%CHAPTER_NUMBER%
%VERSE_NUMBER%
%VERSE_TEXT%

1)[The Book of %BOOK_NAME%
  ]
  
2)[
  Chapter %CHAPTER_NUMBER%
  ]
  
3)[%VERSE_NUMBER% %VERSE_TEXT%
  ]

..
[format]
book = \nThe Book of %BOOK_NAME%\n\n
chapter = Chapter %CHAPTER_NUMBER%\n
verse =  %VERSE_NUMBER% %VERSE_TEXT%\n
..

*/

		char[] cdat=cast(char[])read( CFG_file );
		
		char[][] sects, nmes;
		sects~="Format";
		nmes~="book";
		nmes~="chapter";
		nmes~="verse";
		
		int st,st2;
		foreach( char[] s;sects)
		  if ( (st=cdat.find( s ))!=-1 )
		    foreach( char[] n;nmes )
		      if ( (st2=cdat[st..$].n)!=-1 )
		      {
			      st2=cdat[ st2..$ ].find( " " );
			      st2++;
			      _frm~=cdat[ st2 .. cdat[st2..$].find("\n") ];
			      _frm[$-1]=replace( _frm[$-1],`\n`,"\n" );
		      }


    _frm.length=8;
    _frm[0]="\nThe Book of "; _frm[1]="\n"; // (if new) book
    _frm[2]="\nChapter "; _frm[3]="\n"; // (if new) chapter
    _frm[4]=""; _frm[5]=" "; // Verse Number Number
    _frm[6]=""; _frm[7]="\n"; // Verse
    
		char[] tx="The Book of %\n%\nChapter %\n% % %%\n%";
		_frm=split( tx,"%" );
		
  // lay out
  // "Ref: 1 John (3):[11] - -<¶ For this is the message..>-"
  //  111112222223345556678888899999999999999999999999999911
  //                                       

//#verse: {
                  // chapter(s)
                  if ( (p=args[i+2].find( "-" ))!=-1 )
                  {
                    ch=atoi( args[i+2][0..p] );
                    b.fixNumber( ch );
                    if ( p!=args[i+2].length-1 )
                    {
                      chl=atoi( args[i+2][p+1..$] );
                      b.fixNumber( chl );
                      chl-=ch;
                    }
                  }
                  else
                  {
                    ch=atoi( args[i+2] );
                    b.fixNumber( ch );
                    chl=1;
                  }

                  //verse(s)
                  if ( (p=args[i+3].find( "-" ))!=-1 )
                  {
                    vr=atoi( args[i+3][0..p] );
                    b.chps[ch-1].fixNumber( ch );
                    if ( p!=args[i+3].length-1 )
                    {
                      vrl=atoi( args[i+3][p+1..$] );
                      b.chps[ch+chl-1].fixNumber( vrl );
                      vrl-=vr;
                    }
                  }
                  else
                  {
                    vr=atoi( args[i+3] );
                    b.chps[ch-1].fixNumber( vr );
                    vrl=1;
                  }
//#verse: }

//#drag drop
		void label_mouseDown(Object sender, MouseEventArgs ea)
		{
			tBigBox2.doDragDrop(Data(cast(ubyte[])"Oh Stink"), DragDropEffects.COPY);
		}
		void label_dragOver(Object sender, DragEventArgs ea)
		{
			// Check if the currently dragging data supports text.
			if(ea.data.getDataPresent(DataFormats.text))
			{
				// Set the drag effect to copy if it's allowed.
				// This will remove the NO cursor and indicate you can drop.
				ea.effect = ea.allowedEffect & DragDropEffects.COPY;
			}
		}
		void label_dragDrop(Object sender, DragEventArgs ea)
		{
			// Check if the currently dropped data supports text.
			if(ea.data.getDataPresent(DataFormats.text))
			{
				ubyte[] text;
				text = ea.data.getData(DataFormats.text).getText(); // Get the data as text.
				
				// The text is ANSI so make sure it's all ASCII before treating
				// it as UTF-8, or use fromAnsi() from dfl.utf.
				// Future versions of DFL will do automatic conversions.
				char[] str;
				str = fromAnsi(cast(char*)text, text.length);
				
				(cast(Label)(sender)).text = str;
			}
		}
		
			mouseDown ~= &label_mouseDown; // Prepares text to be dropped on a drop target.
			allowDrop = true;
			
			dragOver ~= &label_dragOver; // Checks if the data can be dropped on the label.
			dragDrop ~= &label_dragDrop; // Handles when the data is dropped.
